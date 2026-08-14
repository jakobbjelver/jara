/**
 * JARA Change Request Worker
 *
 * Receives anonymous bug reports / feature requests from the JARA app,
 * rate-limits per device token, and stores them in Cloudflare D1.
 * Exposes a read + triage-status API for the Hermes triage cron job
 * (shared secret).
 *
 * Endpoints:
 *   POST   /change-request        — submit a change request (app → worker)
 *   GET    /change-requests       — list requests (triage bot, Bearer auth)
 *   PATCH  /change-requests/:id   — set triage status (triage bot, Bearer auth)
 *   GET    /change-requests/by-token?device_token=… — a device's own reports
 *           (status screen; the device token is the capability)
 *   POST   /screenshot-upload     — upload a screenshot to R2 (worker-mediated
 *           upload; returns a public unguessable URL) — see ADR-009
 *   GET    /screenshots/:id       — serve an uploaded screenshot
 *
 * Maintainer intake (SELF-IMPROVEMENT.md §4): an optional X-Jara-Maintainer
 * header carries a maintainer token. The token is hashed and looked up in the
 * MAINTAINER_TOKENS env secret (JSON: {"<sha256hex>": "agent"|"human"}).
 * Valid → source=maintainer_<role>, is_maintainer=1, rate-limit exempt.
 * Absent/invalid → source=in_app. The token is the ONLY maintainer signal.
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'POST' && url.pathname === '/change-request') {
      return handleSubmit(request, env);
    }

    if (request.method === 'GET' && url.pathname === '/change-requests') {
      return handleList(request, env, url);
    }

    if (request.method === 'GET' && url.pathname === '/change-requests/by-token') {
      return handleByToken(request, env, url);
    }

    if (request.method === 'POST' && url.pathname === '/screenshot-upload') {
      return handleScreenshotUpload(request, env);
    }

    const screenshotMatch = url.pathname.match(
      /^\/screenshots\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z0-9]+)$/i,
    );
    if (request.method === 'GET' && screenshotMatch) {
      return handleScreenshotServe(request, env, screenshotMatch[1]);
    }

    const patchMatch = url.pathname.match(/^\/change-requests\/([0-9a-fA-F-]{36})$/);
    if (request.method === 'PATCH' && patchMatch) {
      return handlePatch(request, env, patchMatch[1]);
    }

    return json({ error: 'not_found' }, 404);
  },
};

const RATE_LIMIT = 5; // max submissions per device token
const RATE_WINDOW_MS = 60 * 60 * 1000; // 1 hour

// Hardening caps (PLAN-002 §1.9). Field-level caps are the real protection;
// the body cap is generous enough for the opt-in log ring buffer (~200 lines).
const BODY_MAX_BYTES = 64 * 1024;
const CAPS = {
  device_token: 100,
  type: 10,
  title: 200,
  description: 5000,
  steps_to_reproduce: 2000,
  expected_actual: 2000,
  logs: 30 * 1024,
  app_version: 50,
  os_version: 100,
  device_model: 200,
  screen_size: 50,
  locale: 50,
  screenshot_url: 500,
};

// eslint-disable-next-line no-control-regex
const CONTROL_CHARS = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g;

function stripControlChars(value) {
  return value.replace(CONTROL_CHARS, '');
}

function cleanString(value, maxLength) {
  if (typeof value !== 'string') return null;
  const cleaned = stripControlChars(value).trim();
  if (cleaned.length === 0) return null;
  return cleaned.length > maxLength ? cleaned.slice(0, maxLength) : cleaned;
}

function requireAuth(request, env) {
  const auth = request.headers.get('Authorization') ?? '';
  const expected = `Bearer ${env.TRIAGE_SECRET ?? ''}`;
  if (!env.TRIAGE_SECRET || auth !== expected) {
    return json({ error: 'unauthorized' }, 401);
  }
  return null;
}

async function sha256Hex(value) {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Resolve the maintainer role from the X-Jara-Maintainer header.
 * Returns { role } for a valid token, null otherwise.
 */
async function resolveMaintainer(request, env) {
  const token = request.headers.get('X-Jara-Maintainer');
  if (!token) return null;
  let allowlist;
  try {
    allowlist = JSON.parse(env.MAINTAINER_TOKENS ?? '{}');
  } catch {
    allowlist = {};
  }
  const hash = await sha256Hex(token);
  const role = allowlist[hash];
  if (role !== 'agent' && role !== 'human') return null;
  return { role };
}

async function handleSubmit(request, env) {
  // Content-type validation
  const contentType = request.headers.get('Content-Type') ?? '';
  if (!contentType.toLowerCase().includes('application/json')) {
    return json({ error: 'unsupported_media_type' }, 415);
  }

  // Body size cap — read as text so we can measure before parsing.
  const raw = await request.text();
  if (new TextEncoder().encode(raw).length > BODY_MAX_BYTES) {
    return json({ error: 'payload_too_large' }, 413);
  }

  let body;
  try {
    body = JSON.parse(raw);
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }

  // Sanitize + validate required fields
  const deviceToken = cleanString(body.device_token, CAPS.device_token);
  const type = cleanString(body.type, CAPS.type);
  const title = cleanString(body.title, CAPS.title);
  const description = cleanString(body.description, CAPS.description);

  if (!deviceToken) return json({ error: 'missing_device_token' }, 400);
  if (type !== 'bug' && type !== 'feature') {
    return json({ error: 'invalid_type' }, 400);
  }
  if (!title || title.length < 3) return json({ error: 'invalid_title' }, 400);
  if (!description || description.length < 5) {
    return json({ error: 'invalid_description' }, 400);
  }

  // screenshot_url must point at this worker's own /screenshots/ route —
  // the triage bot embeds it in GitHub issue bodies, so arbitrary URLs
  // are an injection vector. (SELF-IMPROVEMENT.md: containment.)
  const screenshotUrl = cleanString(body.screenshot_url, CAPS.screenshot_url);
  if (screenshotUrl) {
    const requestHost = new URL(request.url).host;
    let parsed;
    try {
      parsed = new URL(screenshotUrl);
    } catch {
      return json({ error: 'invalid_screenshot_url' }, 400);
    }
    const valid =
      parsed.host === requestHost &&
      /^\/screenshots\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z0-9]+$/i.test(
        parsed.pathname,
      );
    if (!valid) {
      return json({ error: 'invalid_screenshot_url' }, 400);
    }
  }

  // Optional structured fields (PLAN-002 §1.9)
  const stepsToReproduce = cleanString(body.steps_to_reproduce, CAPS.steps_to_reproduce);
  const expectedActual = cleanString(body.expected_actual, CAPS.expected_actual);
  const logs = cleanString(body.logs, CAPS.logs);

  // Maintainer check (SELF-IMPROVEMENT.md §4) — token is the only signal.
  const maintainer = await resolveMaintainer(request, env);
  const source = maintainer ? `maintainer_${maintainer.role}` : 'in_app';
  const isMaintainer = maintainer ? 1 : 0;

  // Rate limit per device token — maintainer traffic is exempt.
  if (!maintainer) {
    const windowStart = new Date(Date.now() - RATE_WINDOW_MS).toISOString();
    const { count } = await env.DB
      .prepare(
        `SELECT COUNT(*) as count FROM change_requests
         WHERE device_token = ? AND created_at >= ?`,
      )
      .bind(deviceToken, windowStart)
      .first();
    if (count >= RATE_LIMIT) {
      return json({ error: 'rate_limited', status: 'rejected' }, 429);
    }
  }

  // Deduplicate exact-title matches at submission time
  const duplicate = await env.DB
    .prepare(`SELECT id FROM change_requests WHERE title = ? LIMIT 1`)
    .bind(title)
    .first();
  if (duplicate) {
    return json({ id: duplicate.id, status: 'duplicate' }, 200);
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB
    .prepare(
      `INSERT INTO change_requests
        (id, device_token, type, title, description, steps_to_reproduce,
         expected_actual, logs, app_version, os_version, device_model,
         screen_size, locale, screenshot_url, source, is_maintainer,
         created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
    .bind(
      id,
      deviceToken,
      type,
      title,
      description,
      stepsToReproduce,
      expectedActual,
      logs,
      cleanString(body.app_version, CAPS.app_version),
      cleanString(body.os_version, CAPS.os_version),
      cleanString(body.device_model, CAPS.device_model),
      cleanString(body.screen_size, CAPS.screen_size),
      cleanString(body.locale, CAPS.locale),
      screenshotUrl,
      source,
      isMaintainer,
      now,
    )
    .run();

  return json({ id, status: 'received' }, 201);
}

async function handleList(request, env, url) {
  const authError = requireAuth(request, env);
  if (authError) return authError;

  const since = url.searchParams.get('since') ?? '1970-01-01T00:00:00Z';
  const limit = Math.min(parseInt(url.searchParams.get('limit') ?? '100', 10), 500);
  const status = url.searchParams.get('status'); // optional filter

  let query =
    `SELECT * FROM change_requests WHERE created_at >= ?`;
  const bindings = [since];
  if (status) {
    query += ` AND status = ?`;
    bindings.push(status);
  }
  query += ` ORDER BY created_at DESC LIMIT ?`;
  bindings.push(limit);

  const { results } = await env.DB.prepare(query).bind(...bindings).all();

  return json({ change_requests: results }, 200);
}

/**
 * Screenshot upload (ADR-009): worker-mediated R2 upload.
 *
 * The app POSTs the raw image bytes (Content-Type: image/png|jpeg|webp,
 * X-Jara-Device-Token header). The worker validates type + size (≤5 MB),
 * stores the object under an unguessable UUID key in the SCREENSHOTS
 * binding, and returns the public URL the app then sends as
 * `screenshot_url` in the change-request POST.
 */
const SCREENSHOT_MAX_BYTES = 5 * 1024 * 1024;
const SCREENSHOT_TYPES = new Map([
  ['image/png', 'png'],
  ['image/jpeg', 'jpg'],
  ['image/webp', 'webp'],
]);
const SCREENSHOT_RATE_LIMIT = 20; // uploads per token per hour

async function handleScreenshotUpload(request, env) {
  const contentType = (request.headers.get('Content-Type') ?? '')
    .split(';')[0]
    .trim()
    .toLowerCase();
  const ext = SCREENSHOT_TYPES.get(contentType);
  if (!ext) {
    return json({ error: 'unsupported_media_type' }, 415);
  }

  const deviceToken = cleanString(
    request.headers.get('X-Jara-Device-Token') ?? '',
    CAPS.device_token,
  );
  if (!deviceToken) {
    return json({ error: 'missing_device_token' }, 400);
  }

  // Per-token upload rate limit — audit table doubles as the counter.
  const windowStart = new Date(Date.now() - RATE_WINDOW_MS).toISOString();
  const { count } = await env.DB
    .prepare(
      `SELECT COUNT(*) as count FROM screenshot_uploads
       WHERE device_token = ? AND created_at >= ?`,
    )
    .bind(deviceToken, windowStart)
    .first();
  if (count >= SCREENSHOT_RATE_LIMIT) {
    return json({ error: 'rate_limited' }, 429);
  }

  const declared = parseInt(request.headers.get('Content-Length') ?? '0', 10);
  if (!Number.isFinite(declared) || declared <= 0) {
    return json({ error: 'missing_content_length' }, 411);
  }
  if (declared > SCREENSHOT_MAX_BYTES) {
    return json({ error: 'payload_too_large' }, 413);
  }

  const bytes = await request.arrayBuffer();
  if (bytes.byteLength === 0) {
    return json({ error: 'empty_body' }, 400);
  }
  if (bytes.byteLength > SCREENSHOT_MAX_BYTES) {
    return json({ error: 'payload_too_large' }, 413);
  }

  const key = `${crypto.randomUUID()}.${ext}`;
  await env.SCREENSHOTS.put(key, bytes, {
    httpMetadata: { contentType },
  });

  // Record AFTER a successful R2 write (count only real uploads).
  await env.DB
    .prepare(
      `INSERT INTO screenshot_uploads (device_token, object_key, created_at)
       VALUES (?, ?, ?)`,
    )
    .bind(deviceToken, key, new Date().toISOString())
    .run();

  const base = new URL(request.url);
  return json(
    { screenshot_url: `${base.protocol}//${base.host}/screenshots/${key}` },
    201,
  );
}

/**
 * Serve an uploaded screenshot. Keys are UUIDs — unguessable capability
 * URLs. Immutable cache headers: object keys are never rewritten.
 */
async function handleScreenshotServe(request, env, key) {
  const object = await env.SCREENSHOTS.get(key);
  if (!object) {
    return json({ error: 'not_found' }, 404);
  }
  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('Cache-Control', 'public, max-age=31536000, immutable');
  headers.set('Cross-Origin-Resource-Policy', 'cross-origin');
  return new Response(object.body, { headers });
}

/**
 * A device's own change requests — the in-app status screen. The device
 * token is the capability (the app mints it client-side; it is never
 * shown to other users). Read-only and returns only the caller's own rows,
 * so no per-token limit here — the WAF per-IP rule bounds burst traffic.
 */
async function handleByToken(request, env, url) {
  const deviceToken = cleanString(
    url.searchParams.get('device_token') ?? '',
    CAPS.device_token,
  );
  if (!deviceToken) {
    return json({ error: 'missing_device_token' }, 400);
  }

  const limit = Math.min(
    parseInt(url.searchParams.get('limit') ?? '100', 10),
    500,
  );
  const { results } = await env.DB
    .prepare(
      `SELECT id, type, title, status, screenshot_url,
              github_issue_number, github_issue_url, created_at, triaged_at
       FROM change_requests
       WHERE device_token = ?
       ORDER BY created_at DESC LIMIT ?`,
    )
    .bind(deviceToken, limit)
    .all();

  return json({ change_requests: results }, 200);
}

async function handlePatch(request, env, id) {
  const authError = requireAuth(request, env);
  if (authError) return authError;
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }

  const { status, github_issue_number, github_issue_url } = body;
  if (status !== 'triaged' && status !== 'duplicate' && status !== 'rejected') {
    return json({ error: 'invalid_status' }, 400);
  }
  if (
    github_issue_number !== undefined &&
    (typeof github_issue_number !== 'number' || !Number.isInteger(github_issue_number))
  ) {
    return json({ error: 'invalid_issue_number' }, 400);
  }
  if (github_issue_url !== undefined && typeof github_issue_url !== 'string') {
    return json({ error: 'invalid_issue_url' }, 400);
  }

  const existing = await env.DB
    .prepare(`SELECT id FROM change_requests WHERE id = ?`)
    .bind(id)
    .first();
  if (!existing) {
    return json({ error: 'not_found' }, 404);
  }

  const triagedAt = new Date().toISOString();
  await env.DB
    .prepare(
      `UPDATE change_requests
       SET status = ?,
           github_issue_number = COALESCE(?, github_issue_number),
           github_issue_url = COALESCE(?, github_issue_url),
           triaged_at = ?
       WHERE id = ?`,
    )
    .bind(
      status,
      github_issue_number ?? null,
      github_issue_url ?? null,
      triagedAt,
      id,
    )
    .run();

  const row = await env.DB
    .prepare(`SELECT * FROM change_requests WHERE id = ?`)
    .bind(id)
    .first();

  return json({ change_request: row }, 200);
}

function json(payload, status) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
