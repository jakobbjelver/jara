-- JARA Change Requests — Cloudflare D1 schema
-- Run: wrangler d1 execute jara-change-requests --file=./schema.sql
-- NOTE: for an EXISTING remote DB, CREATE TABLE IF NOT EXISTS is a no-op —
--       apply column additions with ALTER TABLE (see PLAN-002 §3 order 0).

CREATE TABLE IF NOT EXISTS change_requests (
  id TEXT PRIMARY KEY,
  device_token TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('bug', 'feature')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  steps_to_reproduce TEXT,
  expected_actual TEXT,
  logs TEXT,
  app_version TEXT,
  os_version TEXT,
  device_model TEXT,
  screen_size TEXT,
  locale TEXT,
  screenshot_url TEXT,
  source TEXT NOT NULL DEFAULT 'in_app'
    CHECK(source IN ('in_app', 'maintainer_human', 'maintainer_agent')),
  is_maintainer INTEGER NOT NULL DEFAULT 0,
  github_issue_number INTEGER,
  github_issue_url TEXT,
  status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'triaged', 'duplicate', 'rejected')),
  created_at TEXT DEFAULT (datetime('now')),
  triaged_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_change_requests_created_at
  ON change_requests (created_at);

CREATE INDEX IF NOT EXISTS idx_change_requests_device_token
  ON change_requests (device_token, created_at);

CREATE INDEX IF NOT EXISTS idx_change_requests_status
  ON change_requests (status);

-- Screenshot upload log (ADR-009) — used for per-token upload rate limiting
-- and as an audit trail. Rows are inserted before the R2 write.
CREATE TABLE IF NOT EXISTS screenshot_uploads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_token TEXT NOT NULL,
  object_key TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_screenshot_uploads_token
  ON screenshot_uploads (device_token, created_at);
