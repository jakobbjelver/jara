-- JARA Change Requests — Cloudflare D1 schema
-- Run: wrangler d1 execute jara-change-requests --file=./schema.sql

CREATE TABLE IF NOT EXISTS change_requests (
  id TEXT PRIMARY KEY,
  device_token TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('bug', 'feature')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  app_version TEXT,
  os_version TEXT,
  device_model TEXT,
  screen_size TEXT,
  locale TEXT,
  screenshot_url TEXT,
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
