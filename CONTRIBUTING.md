# Contributing to JARA

Thanks for wanting to help! JARA is built by the community, for the community.
This guide covers how to contribute.

## Before You Start

**Read [GOAL.md](GOAL.md) first.** It defines what JARA is and isn't. A feature
that violates GOAL.md — no matter how well implemented — will be rejected.

If you're an AI coding agent, also read [AGENTS.md](AGENTS.md).

## Ways to Contribute

1. **Report a bug** — Use the in-app Change Request form (Settings → Report Issue),
   or open a GitHub issue directly.
2. **Request a feature** — Same path. The maintainer triages everything against GOAL.md.
3. **Fix a bug or implement a feature** — Find an issue labeled `triaged`, comment
   that you're working on it, then follow the workflow below.
4. **Improve docs** — GOAL.md, AGENTS.md, and this file always need clarity.

## Development Workflow

```bash
# 1. Fork and clone
git clone git@github.com:<your-username>/jara.git

# 2. Branch off dev
git checkout dev
git checkout -b feature/my-change

# 3. Develop, following AGENTS.md conventions
flutter analyze
flutter test

# 4. Commit (conventional commits)
git commit -m "feat(scope): description"

# 5. Push and open a PR against dev
```

## Code Style

- **SOLID principles** — single responsibility, no god classes.
- **Grayscale-at-rest UI** — color only conveys meaning: amber = warning,
  red = error, accent = active/selected. Never green.
- **No reinventing wheels** — search pub.dev before writing custom parsers or utilities.
- **Domain purity** — `lib/domain/` never imports Flutter.

See [AGENTS.md](AGENTS.md) §Conventions for the full rulebook.

## Pull Request Checklist

- [ ] Analyzer passes: `flutter analyze`
- [ ] Tests pass: `flutter test`
- [ ] New behavior is tested
- [ ] No dead code, no workarounds
- [ ] UI follows grayscale-at-rest
- [ ] Change aligns with GOAL.md

## Branch Strategy

```
feature/* ──→ dev ──PR──→ main
```

No direct commits to `main`. CI runs on pushes to `dev` and PRs to `main`.

## Questions?

Open an issue, or submit a Change Request from inside the app. The maintainer
(or the triage bot) will get back to you.
