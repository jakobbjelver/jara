/**
 * JARA Change Request Worker
 *
 * Receives anonymous bug reports / feature requests from the JARA app,
 * rate-limits per device token, and stores them in Cloudflare D1.
 * Exposes a read API for the Hermes triage cron job (shared secret).
 *
 * Endpoints:
 *   POST /change-request        — submit a change request (app → worker)
 *   GET  /change-requests       — list requests since a timestamp (triage bot)
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

    return json({ error: 'not_found' }, 404);
  },
};

const RATE_LIMIT = 5; // max submissions per device token
const RATE_WINDOW_MS = 60 * 60 * 1000; // 1 hour

async function handleSubmit(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }

  // Validate required fields
  const { device_token, type, title, description } = body;
  if (!device_token || typeof device_token !== 'string') {
    return json({ error: 'missing_device_token' }, 400);
  }
  if (type !== 'bug' && type !== 'feature') {
    return json({ error: 'invalid_type' }, 400);
  }
  if (!title || typeof title !== 'string' || title.length > 200) {
    return json({ error: 'invalid_title' }, 400);
  }
  if (!description || typeof description !== 'string' || description.length > 5000) {
    return json({ error: 'invalid_description' }, 400);
  }

  // Rate limit per device token
  const windowStart = new Date(Date.now() - RATE_WINDOW_MS).toISOString();
  const { count } = await env.DB
    .prepare(
      `SELECT COUNT(*) as count FROM change_requests
       WHERE device_token = ? AND created_at >= ?`
    )
    .bind(device_token, windowStart)
    .first();
  if (count >= RATE_LIMIT) {
    return json({ error: 'rate_limited', status: 'rejected' }, 429);
  }

  // Deduplicate exact-title matches at submission time
  const duplicate = await env.DB
    .prepare(`SELECT id FROM change_requests WHERE title = ? LIMIT 1`)
    .bind(title.trim())
    .first();
  if (duplicate) {
    return json({ id: duplicate.id, status: 'duplicate' }, 200);
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB
    .prepare(
      `INSERT INTO change_requests
        (id, device_token, type, title, description, app_version,
         os_version, device_model, screen_size, locale, screenshot_url, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
    .bind(
      id,
      device_token,
      type,
      title.trim(),
      description.trim(),
      body.app_version ?? null,
      body.os_version ?? null,
      body.device_model ?? null,
      body.screen_size ?? null,
      body.locale ?? null,
      body.screenshot_url ?? null,
      now,
    )
    .run();

  return json({ id, status: 'received' }, 201);
}

async function handleList(request, env, url) {
  // Shared-secret auth for the triage bot
  const auth = request.headers.get('Authorization') ?? '';
  const expected = `Bearer ${env.TRIAGE_SECRET ?? ''}`;
  if (!env.TRIAGE_SECRET || auth !== expected) {
    return json({ error: 'unauthorized' }, 401);
  }

  const since = url.searchParams.get('since') ?? '1970-01-01T00:00:00Z';
  const limit = Math.min(parseInt(url.searchParams.get('limit') ?? '100', 10), 500);

  const { results } = await env.DB
    .prepare(
      `SELECT * FROM change_requests
       WHERE created_at >= ?
       ORDER BY created_at DESC
       LIMIT ?`
    )
    .bind(since, limit)
    .all();

  return json({ change_requests: results }, 200);
}

function json(payload, status) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
