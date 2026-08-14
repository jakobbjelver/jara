# JARA — Just Another Running App

> **GOAL.md is the project's north star.** Every decision — feature requests, bug fixes,
> architecture changes, PR reviews — is measured against this document. When in doubt,
> re-read this. If the answer isn't here, add it here.

---

## 1. What JARA Is

JARA is an **opinionated, open-source running app** for iOS and Android. It tracks your
runs with GPS, gives you insightful analytics, and helps you understand your progress over
time. It is built by the community, for the community.

JARA is **free**. No ads, no subscriptions, no in-app purchases, no data selling.
It survives on donations that cover infrastructure costs and app store fees — nothing more.

JARA is **private**. All your run data lives on your device. There are no accounts, no
servers that store your runs, and no third-party analytics. What happens on your run stays
on your run.

JARA is **honest**. It does not gamify your runs with artificial rewards, does not sell
you "exclusive" challenges, and does not pretend to be a social network. It is a tool for
runners, not a platform for engagement metrics.

JARA is **self-improving**. Every user can report bugs or request features directly in the
app. Those reports become anonymous GitHub issues. An automated system triages them,
detects duplicates, and helps the maintainer prioritize what to build next. The maintainer
improves JARA through dedicated routes of his own — human and AI-agent dogfooding — that
feed the same pipeline (§8.6).

---

## 2. What JARA Is NOT

JARA is **not a social network**. No friends, no followers, no kudos, no feed, no
activity sharing. Your runs are yours.

JARA does **not sell you anything**. No brand affiliates, no sponsored challenges, no
"premium" tier, no in-app purchases. Free means free.

JARA has **no events, no guided runs, no challenges, no leaderboards, no prizes, no
rewards**. Run because you want to run, not because an app told you to.

JARA has **no account creation**. There is no login screen. There is no user database.
The app works fully offline and never phones home except for three things: (1) checking for
updates, (2) submitting Change Requests (which are anonymous by design), optionally with
screenshots you explicitly attach, and (3) checking the status of the Change Requests you
have submitted from this device. Nothing else is ever transmitted — no run data, no
analytics, no identifiers beyond the anonymous device token used for those requests.

JARA does **not gamify your fitness**. No XP, no levels, no badges, no streaks.
Personal records are statistics, not achievements to unlock.

---

## 3. Design Principles

### 3.1 SOLID

Every line of code follows SOLID principles. This is non-negotiable:

- **Single Responsibility**: Each class, module, and function has exactly one job.
  No god stores. No "RunManager" that does GPS + database + UI + export.
- **Open/Closed**: New features extend behavior through composition, not by modifying
  existing code. A new chart type should not touch the run recording code.
- **Liskov, Interface Segregation, Dependency Inversion**: Followed where applicable.

### 3.2 Grayscale-at-Rest

The UI is **grayscale by default**. Color appears only to convey meaning:

| Color | Meaning |
|-------|---------|
| Grayscale | Normal, idle, healthy state |
| Amber/Orange | Warnings, attention needed |
| Red | Errors, destructive actions |
| Accent (muted, theme-defined) | Active, selected, focused, interactive |

A green checkmark should never appear. A successful save is the absence of an error
indicator — not a green confirmation. The app is calm when everything works.

### 3.3 Themes Exist

Grayscale-at-rest is the default, but users can choose themes:

- **Light** (default): Grayscale on white
- **Dark**: Grayscale on black
- **Named themes**: User-selectable color palettes. Each theme defines an accent color
  and a background tint. The grayscale-at-rest principle holds across all themes — amber
  and red remain the only semantic colors.

### 3.4 No Workarounds, No Reinventing Wheels

Research before implementing. Read official docs. Use `gh_grep` for real-world examples.
If it's not documented behavior, it's a bug waiting to happen. Never commit code that
"seems to work" — know why it works.

**Prefer established packages over custom solutions.** Before writing a custom parser,
validator, exporter, or utility, search pub.dev and GitHub for an existing package that
already does it. The project values more dependencies over more custom code. Examples:

- GPX/TCX/FIT parsing → `activity_files` package (instead of custom XML parsing)
- Map location indicator → `flutter_map_location_marker` (instead of custom layer)
- Background service → `flutter_background_service` (instead of raw platform channels)
- GPS → `geolocator` (instead of raw `CLLocationManager` / `FusedLocationProvider`)

The litmus test: if you find yourself writing an XML parser, a binary format reader,
or platform-channel boilerplate, stop and search for an existing package first.

### 3.5 Forward-Looking Architecture

The V1 codebase must accommodate features planned for V1.5 and V2 without requiring
rewrites. Specifically:

- **Data model stores more than V1 displays.** Heart rate, cadence, elevation gain,
  weather conditions, and shoe tracking fields exist in the database from day one,
  even if the UI doesn't surface them until later.
- **Navigation scales.** The tab structure and screen layouts assume additional
  sections will be added. No fixed-width layouts that break when a new tab appears.
- **Run detail is scrollable sections.** Adding a heart rate zone chart or shoe mileage
  widget in V1.5 should be one new section component, not a layout refactor.
- **Settings is section-based.** Adding new settings categories requires adding a
  section, not redesigning the settings screen.
- **Export/import is format-agnostic.** Adding a new format (FIT) adds a parser/writer,
  not a rewrite of the export pipeline.
- **Feature flags.** Features expected in later versions are gated behind flags, not
  absent from the codebase. This keeps the architecture honest — if a V2 feature
  would require a different database schema, that schema exists in V1 behind a flag.

---

## 4. Feature Matrix

### V1 — Must (The Foundation)

These are required before the app is runnable and the self-improvement loop activates.

**Run Tracking:**
- GPS route recording: distance, duration, current pace, average pace, elapsed time
- Auto-pause (configurable threshold)
- Manual lap/split (tap to mark)
- Audio cues: time, distance, average pace (configurable frequency and metrics)
- Lock screen / always-on display during active run
- Background GPS (run continues when phone is locked or app is backgrounded)

**Post-Run:**
- Route map with color-coded pace overlay
- Pace over distance chart
- Elevation profile (GPS-derived)
- Splits table (per km or mile, configurable)
- Run history list with search and date filter
- Swipe-to-delete with confirmation

**Data:**
- Local SQLite database (all data on device)
- Export: GPX, TCX, CSV (individual run + bulk)
- Import: GPX, TCX (individual + bulk)
- Optional encrypted backup to iCloud (iOS) / Google Drive (Android)
- Restore from backup

**App Infrastructure:**
- In-app Change Request form: type (bug/feature), title, description, steps to reproduce, expected vs actual, optional screenshot, opt-in diagnostic logs
- Device info attached automatically (OS version, device model, app version)
- Light theme, Dark theme, plus at least 2 named color themes
- Grayscale-at-rest enforced across all themes

**Project Infrastructure:**
- GOAL.md (this document)
- AGENTS.md (for AI coding agents)
- CONTRIBUTING.md (for human contributors)
- GPL-3.0 license
- CI pipeline (lint, typecheck, unit tests, widget tests) on GitHub Actions
- iOS build on macOS GitHub Actions runner
- Android build on Ubuntu GitHub Actions runner
- Cloudflare Worker for Change Request collection
- Hermes cron job for daily issue triage (runs on Jakob's machine)
- Maestro smoketest suite (simulator flows committed to the repo, run on maintainer hardware)

### V1.5 — Should (Soon After)

**Run Tracking:**
- Heart rate zones (Bluetooth HRM + watch-derived)
- Cadence (steps per minute)
- Elevation gain/loss (cumulative)
- Interval training: custom intervals (distance or time), target pace alerts
- Configurable data fields during run (choose what you see)

**Post-Run:**
- Heart rate zone breakdown chart
- Cadence chart
- Personal records: 1K, 1 mile, 5K, 10K, half marathon, marathon, longest run
- Weekly / monthly / yearly mileage trends
- Calendar heatmap (like GitHub contribution graph)
- Shoe tracking: assign shoes to runs, track mileage per shoe, alerts at threshold
- Weather conditions at time of run (fetched from API, not recorded by app)

**Data:**
- Import from Strava: file import + OAuth API import
- Import from Apple Health / Google Health Connect (read workouts stored by other apps)
- Import from Garmin Connect (GPX/TCX file import)

**Training:**
- Goal setting: target weekly distance, target pace, target frequency
- Training plans: downloadable plans (Couch to 5K, 10K, half marathon, marathon)
  — NOT guided, NOT audio-coached, just a schedule you follow

**App:**
- More named color themes
- Public release on App Store and Play Store

### Won't — Ever

These will never be added. They violate the project's philosophy. A Change Request
for any of these will be closed with a reference to this section.

- Social features: friends, followers, kudos, likes, comments, activity feeds
- Account creation, login, user profiles
- Challenges, leaderboards, competitions
- Guided runs, audio coaching, "run with a coach"
- Events, race registration, starting lines
- Brand affiliates, sponsored content, promoted challenges
- Prizes, rewards, badges, streaks, XP, levels, gamification
- Ads, tracking, analytics, data selling
- Premium tier, subscriptions, in-app purchases (donations are the only payment)
- Any feature that requires a server-side user database

### V2+ — Later

- Apple Watch companion app
- Wear OS companion app
- iOS Lock Screen / Home Screen widgets
- Android widgets
- Live Activities (iOS) / ongoing notification enhancements
- Offline maps (pre-downloaded tiles)
- Nike Run Club import (documented workflow using community tools)
- Direct FIT format import
- Training load / strain / recovery metrics
- Self-hosted sync/backup service (Docker image, optional paid hosting)

---

## 5. Technical Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | **Flutter** (latest stable) | Single codebase for iOS + Android, mature ecosystem, hot reload for agentic dev, strong GPS/health plugin support |
| Language | **Dart** (strict mode) | Flutter's language, sound null safety |
| State management | **Riverpod** | Compile-safe, testable, scales from simple to complex |
| Local database | **SQLite** via `drift` (formerly moor) | Type-safe SQLite with migrations, perfect for structured run data |
| GPS / Location | `geolocator` + `background_fetch` | Battle-tested Flutter location plugins |
| Maps | `flutter_map` + OpenStreetMap tiles | No API key needed, works offline with pre-cached tiles, no Google dependency |
| Health data | `health` package | Wraps HealthKit (iOS) + Health Connect (Android) |
| Charts | `fl_chart` | Lightweight, customizable, good for pace/elevation/HR charts |
| Export/Import | `activity_files` package | Pure Dart GPX/TCX/FIT/CSV/GeoJSON parser — no custom XML code |
| Backup | Encrypted ZIP → platform file picker | User chooses where to save; iCloud/Google Drive via native file dialog |
| CI | GitHub Actions | `ubuntu-latest` for Android, `macos-15` for iOS (free + unlimited for public repos) |
| Change Request backend | Cloudflare Worker | Receives anonymous reports, stores in KV or D1, Hermes reads via API |
| Issue triage | Hermes Agent (cron, daily) | Runs on Jakob's Mac mini, reads from Cloudflare, creates GitHub issues |

### Why Not

| Rejected | Reason |
|----------|--------|
| React Native | JavaScript runtime overhead, less native feel, bridge performance issues for GPS |
| Kotlin Multiplatform | Less mature, smaller ecosystem, no single UI codebase, harder for agentic dev |
| SwiftUI + Jetpack Compose | Two codebases = double the work, double the bugs, double the agent context |
| Google Maps | Requires API key + billing account; OpenStreetMap is free and works offline |
| Firebase / Supabase | Requires account, server-side database, violates "no accounts" principle |
| `sqflite` (raw) | `drift` provides type-safe queries, migrations, and DAOs — worth the dependency |

---

## 6. Data Architecture & Privacy

### 6.1 Data Ownership

All run data lives on the user's device in a local SQLite database. JARA never transmits
run data to any server. The only network requests the app makes are:

1. **Map tiles**: Fetching OpenStreetMap tiles (anonymous, can be pre-cached)
2. **Weather**: Fetching current conditions at run time (if user enables, V1.5)
3. **Change Requests**: Sending anonymous bug reports / feature requests to the Cloudflare Worker
4. **Update check**: Checking for new app versions (App Store / Play Store handle this natively)

### 6.2 Database Schema (Forward-Looking)

The V1 schema includes columns that won't be surfaced in the UI until V1.5. This prevents
a schema migration when those features land.

```
runs
├── id (UUID, PK)
├── start_time (datetime, not null)
├── end_time (datetime)
├── distance_meters (real)
├── duration_seconds (integer)
├── avg_pace_seconds_per_km (real)
├── route_points (JSON: [{lat, lon, timestamp, elevation}])
├── laps (JSON: [{number, distance, duration, pace}])
├── elevation_gain_meters (real)        ← V1.5 UI
├── elevation_loss_meters (real)        ← V1.5 UI
├── avg_heart_rate (integer)            ← V1.5 UI
├── max_heart_rate (integer)            ← V1.5 UI
├── heart_rate_zones (JSON)             ← V1.5 UI
├── avg_cadence (real)                  ← V1.5 UI
├── shoe_id (UUID, FK, nullable)        ← V1.5 UI
├── weather_conditions (JSON, nullable) ← V1.5 UI
├── weather_temp_celsius (real)         ← V1.5 UI
├── notes (text)
├── created_at (datetime)
└── updated_at (datetime)

shoes                                ← V1.5 table (exists from V1, unused)
├── id (UUID, PK)
├── name (text)
├── brand (text)
├── model (text)
├── initial_mileage_meters (real)
├── target_mileage_meters (real)
├── retired (boolean)
├── created_at (datetime)
└── updated_at (datetime)

personal_records                     ← V1.5 table (exists from V1, unused)
├── id (UUID, PK)
├── distance_key (text: "1k", "5k", "10k", "half_marathon", "marathon")
├── run_id (UUID, FK)
├── time_seconds (integer)
├── pace_seconds_per_km (real)
├── achieved_at (datetime)
└── created_at (datetime)
```

### 6.3 Backup & Restore

- **Export**: Entire database encrypted with a user-provided password, saved as a `.jarabackup`
  file via the platform file picker. User chooses where to save it (iCloud, Google Drive,
  local files, etc.).
- **Import**: User selects a `.jarabackup` file, provides the password, database is restored.
- **No sync**: V1 does not sync between devices. Backup/restore is the transfer mechanism.
  A sync service (self-hosted Docker image + optional paid hosting) is a V2 feature.

### 6.4 Privacy Policy

A short, plain-language privacy policy will be published on the project website:

- The app does not collect, store, or transmit your run data.
- The app does not require an account.
- Bug reports and feature requests are anonymous — no personal data is attached.
- Map tiles are fetched from OpenStreetMap's CDN; see their privacy policy.
- Weather data (V1.5) is fetched from a free weather API; no personal data is sent.

---

## 7. UI/UX Principles

### 7.1 Information Architecture

```
Bottom Tab Bar
├── Run        (active run screen + start button)
├── History    (list of past runs, search, filter)
├── Analytics  (trends, charts, personal records — expands significantly in V1.5)
└── Settings   (themes, backup, export, about, Change Request)
```

The tab structure is chosen to accommodate growth:
- **Run**: Gets heart rate display, interval config, data field customization in V1.5
- **History**: Gets shoe filter, weather overlay in V1.5
- **Analytics**: Goes from 1-2 charts in V1 to 5+ charts, calendar heatmap, shoe mileage in V1.5
- **Settings**: Sections can be added indefinitely without layout changes

### 7.2 Run Detail Screen

The post-run detail screen is a vertical scroll of **sections**. Each section is an
independent widget. Adding a new metric means inserting a new section — not refactoring
a fixed grid.

```
┌─────────────────────────────┐
│ Map (color-coded by pace)   │
├─────────────────────────────┤
│ Summary stats (distance,    │
│ duration, avg pace, splits) │
├─────────────────────────────┤
│ Pace Chart                  │
├─────────────────────────────┤
│ Elevation Profile           │
├─────────────────────────────┤
│ [V1.5] Heart Rate Zones     │  ← Added as new section
├─────────────────────────────┤
│ [V1.5] Cadence Chart        │  ← Added as new section
├─────────────────────────────┤
│ [V1.5] Shoe & Weather       │  ← Added as new section
├─────────────────────────────┤
│ Export / Delete             │
└─────────────────────────────┘
```

### 7.3 Grayscale-at-Rest (detailed)

- **Backgrounds**: White (light) or near-black (dark), never tinted
- **Text**: Black-to-gray scale (light) or white-to-gray scale (dark)
- **Icons**: Gray in idle state, accent color when active/selected
- **Buttons**: Gray outline in idle, accent fill when active, red fill for destructive
- **During a run**: A single accent-colored element (elapsed time or pace ring) — the rest stays grayscale
- **Errors**: Red text + red icon. No toast with green checkmark for "saved successfully"
- **Warnings**: Amber text + amber icon. Backup never done? Small amber dot in Settings.

### 7.4 Typography & Spacing

- System font stack (San Francisco on iOS, Roboto on Android)
- Generous whitespace — the app breathes
- Consistent spacing scale (4px base unit: 4, 8, 12, 16, 24, 32, 48)
- No decorative fonts, no animated text, no confetti

---

## 8. The Self-Improvement Loop

JARA improves itself through a structured pipeline:

```
┌──────────┐     ┌──────────────────┐     ┌───────────────┐
│  User    │────▶│ Cloudflare Worker│────▶│  Hermes Cron  │
│  submits │     │  (stores in D1)  │     │  (daily triage)│
│  in app  │     └──────────────────┘     └───────┬───────┘
└──────────┘                                       │
                                                   ▼
┌──────────┐     ┌──────────────────┐     ┌───────────────┐
│  User    │◀────│  App Store /     │◀────│  GitHub PR /  │
│  updates │     │  Play Store      │     │  Issue        │
└──────────┘     └──────────────────┘     └───────┬───────┘
                                                   │
                                                   ▼
┌──────────┐     ┌──────────────────┐     ┌───────────────┐
│  Hermes  │────▶│  Human (Jakob)   │────▶│  Hermes       │
│  reviews │     │  approves/rejects│     │  implements   │
│  PR      │     └──────────────────┘     └───────────────┘
└──────────┘
```

### 8.1 In-App Change Request

A form inside the app (Settings → Report Issue / Request Feature):

- **Type**: Bug Report | Feature Request
- **Title**: Short summary
- **Description**: Free text
- **Steps to reproduce** and **Expected vs. actual** (structured fields — what
  the triage agent acts on)
- **Screenshot**: Optional (can attach from photo library)
- **Device info** (auto-attached, not shown to user): OS version, device model, app version,
  screen size, locale
- **Diagnostic logs**: recent app log lines (ring buffer), attached only with
  the user's consent via a visible toggle — never silently
- **Receipt**: after submit the user sees a report ID to reference later

Submitted to the Cloudflare Worker via a simple POST. No authentication. Rate-limited
per device (anonymous token stored locally) and per IP (Cloudflare WAF) to prevent spam.

### 8.2 Cloudflare Worker

A lightweight Worker that:
- Receives Change Requests via POST
- Rate-limits per anonymous device token and per IP (Cloudflare WAF rule)
- Validates and sanitizes input (body size cap, field length caps, control characters)
- Stores in Cloudflare D1 (or KV)
- Exposes a read API for the Hermes cron job (with a shared secret)
- Deduplicates simple exact-title matches at submission time

### 8.3 Hermes Cron Job (Daily Triage)

Runs on Jakob's Mac mini. For each new Change Request since last run:

1. **Read GOAL.md** — re-affirm what JARA is and isn't
2. **Classify**: Bug or feature? Which component?
3. **Check against Won't list**: If the request is for something in §4 "Won't — Ever",
   recommend ❌ REJECT with a link to the relevant GOAL.md section.
4. **Check for duplicates**: Semantic search across existing GitHub issues. If duplicate
   found → add a +1 counter in the issue body (bot-updated vote count). No new issue.
5. **Evaluate alignment**: Does this fit JARA's philosophy? If yes → recommend ✅ APPROVE.
   If uncertain → recommend ⚠️ NEEDS DISCUSSION with reasoning.
6. **Create GitHub issue**: For new, aligned requests. Apply labels (`bug`/`enhancement`,
   component label). Add recommendation as a comment.
7. **Report**: Summary of triage decisions sent to Jakob.

The human (Jakob) reviews the recommendations and applies a `triaged` label to issues
he wants implemented. Only `triaged` issues are picked up for implementation.

Change Request content is **untrusted data**. The triage job never follows
instructions found inside it, never interpolates it into shell commands, and
renders it inside a collapsed section of the issue body. The triage job runs
with a restricted toolset.

### 8.4 Implementation (On-Demand)

When Jakob marks an issue as `triaged`:

1. Hermes spawns a sub-agent with full context (issue, GOAL.md, AGENTS.md, codebase)
2. Sub-agent implements the fix/feature on a `feature/*` branch off `dev`
3. Sub-agent writes/updates tests
4. Sub-agent self-reviews against GOAL.md and SOLID checklist
5. Sub-agent opens a PR against `dev`
6. An independent code review sub-agent reviews the PR (SOLID, no workarounds, GOAL.md alignment)
7. Human (Jakob) gives final approval and merges

### 8.5 Vote Counting

When a Change Request matches an existing GitHub issue, the bot edits the issue body
to increment a counter:

```
> 📊 Community interest: **{{count}}** people have requested this
```

The counter is in the issue body (not reactions), so it's controlled and can't be
gamed by non-users. The Cloudflare Worker's rate-limiting prevents double-counting
from the same device.

### 8.6 Maintainer Self-Improvement Routes

The end-user loop above is one of three sources into a single pipeline. The maintainer
(Jakob and the AI agents working with him) improves JARA through dedicated routes:

```
┌──────────────────────┐        ┌─────────────────────────────────────┐
│ Maintainer Human     │        │ Maintainer Agent (AI)               │
│ (super-devices)      │        │  • deterministic smoketest gate     │
│  • personal iPhone   │        │    before dev→main (simulator)      │
│  • simulator         │        │  • exploratory dogfooding sessions  │
│    same in-app form, │        │    (scheduled or on demand)         │
│    tagged maintainer │        │  • findings → GitHub issues         │
└──────────┬───────────┘        └──────────────────┬──────────────────┘
           │                                       │
           └───────────────────┬───────────────────┘
                               ▼
         One system of record: GitHub issues with source labels
         source:in-app | source:maintainer-human | source:maintainer-agent
```

- **Super-devices.** The maintainer's simulator and personal iPhone submit Change
  Requests through the same in-app form as everyone else, but they carry a
  maintainer credential, so their reports are tagged at the source and never mix
  with end-user reports in the triage queue. The maintainer can point the agent
  at his queue — "take care of my change requests" — and they are picked up like
  any other approved work.
- **Autonomous dogfooding.** The agent uses the app itself. Deterministic Maestro
  smoketests run on the simulator and gate every release branch; exploratory
  vision-driven sessions (scheduled or triggered by the maintainer) hunt for bugs
  and feature ideas. Findings enter the pipeline as GitHub issues — the agent does
  not masquerade as an anonymous user, because it already has direct access to
  the project.
- **One pipeline, one record.** Every improvement — end-user, maintainer human,
  maintainer agent — flows through the same triage and lands in the same GitHub
  issue tracker. Source labels keep the maintainer's queue visible and
  referenceable while the public backlog stays honest and complete. Sensitive
  items that cannot be public go to a private issue tracker instead.
- **The aim.** The maintainer never has to smoke-test new features or existing
  functionality at runtime. He may still discover bugs and feature ideas by using
  his own devices — that is the maintainer-human route — but the agent carries
  the systematic testing load, and every discovery, from every source, is
  captured by the loop.
- **Honest limits.** The simulator cannot test real GPS behavior, biometric
  sensors, background-execution reality, store review, or subjective feel. Those
  are covered by the maintainer-human route on real devices — not by pretending
  the simulator is a device.

---

## 9. Development Governance

### 9.1 Branch Strategy

```
feature/* ──→ dev ──PR──→ main
                ↑            ↑
                │            │
         CI on push     CI + build on push
                         (branch ruleset blocks direct pushes)
```

- `dev` is the integration branch. All feature work happens here or on feature branches off `dev`.
- `main` is the release branch. Only PR merges from `dev` land here.
- GitHub branch ruleset on `main`: require PR, require CI to pass, block force pushes.
- No branch-guard.yml — enforced natively via GitHub branch protection rules.

### 9.2 Commit Convention

Conventional Commits: `type(scope): description`

| Type | Use |
|------|-----|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change without behavior change |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, CI, dependencies |

### 9.3 Code Review

Every PR must be reviewed before merge. The review checks:

1. **SOLID compliance** — Single responsibility, open/closed, no god classes
2. **GOAL.md alignment** — Does this change fit the project's philosophy?
3. **No workarounds** — Is every line justified by documentation or established patterns?
4. **Test coverage** — Are new behaviors tested?
5. **Forward-looking** — Does this change accommodate planned features or paint us into a corner?
6. **Grayscale-at-rest** — Does the UI follow the color principles?

Reviews can be done by:
- **AI sub-agent** (Hermes, OpenCode, Claude Code — whatever the contributor uses)
- **Human reviewer** (Jakob or other maintainers)
- **Both** (AI first pass, human approval)

### 9.4 CI/CD

| Trigger | What Runs | Where |
|---------|-----------|-------|
| Push to `dev` | `flutter analyze`, `flutter test` | GitHub Actions |
| PR to `main` | `flutter analyze`, `flutter test`, `flutter build` (dry run) | GitHub Actions |
| Pre-merge to `main` (gate) | Maestro smoketest — agent-run, procedural gate | Jakob's Mac mini |
| Push to `main` | `flutter analyze`, `flutter test`, Android build, iOS build, GitHub Release draft | GitHub Actions |
| Daily cron | Issue triage (Hermes) | Jakob's Mac mini |

### 9.5 AGENTS.md

A separate `AGENTS.md` file (created during the Foundation Phase) documents:
- How to set up the Flutter dev environment
- How to build and run the app
- Project structure and architecture
- Conventions (naming, file structure, state management patterns)
- Testing expectations
- How to run the code review agent before pushing
- Common pitfalls and gotchas

This file is written for AI coding agents (Hermes, OpenCode, Claude Code, Codex, etc.).
Contributors use whatever agent harness they prefer — Hermes is Jakob's tool, not a
project requirement.

---

## 10. Open Source Governance

### 10.1 License

**GPL-3.0**. Strong copyleft. If you modify and distribute JARA, you must share your
changes under the same license. This keeps the project genuinely open and prevents
proprietary forks that strip the privacy protections.

### 10.2 Contributing

External contributors follow the standard fork-and-PR workflow:

1. Fork the repo
2. Create a feature branch
3. Implement, following GOAL.md and AGENTS.md
4. Run the code review agent (documented in AGENTS.md)
5. Open a PR against `dev`
6. CI must pass
7. Human maintainer reviews and merges

No CLA (Contributor License Agreement) is required. Contributions are made under the
same GPL-3.0 license.

### 10.3 Maintainer

Jakob is the project maintainer. He has final say on:
- What features are accepted or rejected
- What gets merged
- Release timing
- GOAL.md amendments

As the project grows, additional maintainers may be added. The maintainer role is
earned through sustained, high-quality contributions — not assigned.

---

## 11. Project Phases

> **Status (2026-08-14):** Phase 0–2 complete. Phase 3 (V1.5 Features) is
> next. A maintainer-only tooling bridge (Portal Actions + device testing,
> tracked in `.hermes/plans/`) sits between Phase 2 and Phase 3 and is not
> a product phase.

### Phase 0: Planning ✅ (complete 2026-08-12)
- GOAL.md (this document)
- AGENTS.md draft
- Architecture decisions documented
- Hermes `jara-project` skill created

### Phase 1: Foundation ✅ (complete 2026-08-13)
- Flutter project scaffold with feature-based folder structure
- Database layer (drift + migrations + forward-looking schema)
- GPS/location layer (recording + background)
- Basic run tracking (start, pause, resume, stop, laps)
- Run history list
- Post-run detail screen (map + basic stats)
- Export GPX/TCX/CSV
- Import GPX/TCX
- Backup/restore
- 4-tab navigation shell
- Light + Dark theme + grayscale-at-rest enforcement
- Settings screen with Change Request form
- Cloudflare Worker for Change Request collection
- CI pipeline (lint, test, build)
- GitHub branch ruleset

### Phase 2: Self-Improvement Activation ✅ (complete 2026-08-14)
- Hermes `jara-project` skill
- Hermes cron job for daily triage
- Hermes implementation workflow (issue → branch → PR)
- Hermes code review workflow
- Maintainer self-improvement routes (§8.6): super-device provisioning, source-aware triage
- Maestro smoketest suite + pre-merge gate on maintainer hardware
- End-to-end test: submit Change Request → triaged → implemented → merged → deployed
- AGENTS.md finalized
- First release path: dev→main PRs + CI build workflows green (iOS + Android),
  CR screenshot upload + in-app status screen (§2), dogfooding vision loop

### Phase 3: V1.5 Features (next — PLAN-004)
- V1 polish from dogfooding findings (analytics chart issues #4/#5)
- Dogfood cron activation (daily agent exploration, findings → issues)
- As prioritized by Change Requests
- Guided by GOAL.md feature matrix (§7)
- TestFlight setup when the maintainer's Apple Developer subscription lands

### Phase 4: Public Release (future)
- App Store submission
- Play Store submission
- Public repo announcement
- Project website

### Phase 5: Ongoing Maintenance (future)
- Fully driven by the self-improvement loop
- Change Requests → Triage → Implementation → Release
- Periodic GOAL.md review and amendment

---

## 12. Non-Goals (Explicit)

These are things the project deliberately avoids, beyond the feature "Won't" list:

- **Marketing**: No growth hacking, no social media campaigns, no "launch strategy."
  The app grows by being good, not by being promoted.
- **Business model**: Donations cover costs. If donations exceed costs, the surplus
  goes to improving the project (better CI hardware, device testing farm, etc.).
  There is no profit motive.
- **Enterprise features**: No SSO, no team dashboards, no admin panels. JARA is for
  individual runners.
- **Branding**: No mascot, no "delightful" animations, no personality. The app is a
  tool, not a character.
- **Engagement**: No streaks, no notifications that say "you haven't run in 3 days!"
  The app serves the runner, not the other way around.

---

> **This document is the project's constitution.** It is amended deliberately and
> infrequently. When a decision is unclear, the answer goes here. When a new principle
> is discovered, it goes here. When the project grows, this document grows with it.
