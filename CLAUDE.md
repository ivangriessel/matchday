# CLAUDE.md — Premier League Predictions App

This file gives you context on the project and the intended approach.
Read it before suggesting implementations or making changes.

---

## What this app is

A weekly Premier League match predictions app for a small private group (~10–20 people).
Participants predict match outcomes before kickoff.
Points are awarded for correct results and exact scores.
A leaderboard tracks standings across the season.

This replaces a manual spreadsheet + group chat workflow run by a non-technical admin (Simon).

MVP for these specific user group, but with the goal of the app later supporting multiple groups.

Ivan is using this project as a learning exercise to improve his skills on RoR, View Component and native CSS over Tailwind workflows in RoR apps.

This app needs to be built and hosted for free. The only possible cost is a domain name if needed.

---

## Tech stack

- **Ruby on Rails 8** (current stable) with standard built-ins
- **PostgreSQL** in development AND production (keep parity with Render)
- **ViewComponent** for reusable UI components
- **Passwordless gem** for magic link authentication
- **Solid Queue** for background jobs — runs on Postgres, no Redis needed. Run it **inside Puma** (`SOLID_QUEUE_IN_PUMA=true`) so the free host needs only one service. (Chosen over Sidekiq specifically because Sidekiq requires a paid Redis instance.)
- **Resend** for transactional email (magic links + reminders), via the `resend` gem's ActionMailer integration
- **api-football.com** for fixture and result sync (Phase 2 — see caveats below)
- **Native CSS** for styling — inspired by 37signals' Fizzy approach (no utility framework)
- **RSpec** + **factory_bot** + **Capybara** (system tests for the prediction flow) for testing

Avoid introducing new dependencies unless clearly necessary. Prefer Rails conventions and built-ins.

---

## Data model

The app is multi-group from day one. Key principle:

- **Global data** (shared across all groups): `Team`, `Fixture`, and results. There is one set of Premier League fixtures for everyone.
- **Per-group data**: `Group`, `Membership`.
- **Predictions are per-user, not per-group.** A user makes ONE prediction per fixture, and it counts in every group they belong to (the Fantasy Premier League model). So `Prediction` has no `group_id`; groups only scope membership and leaderboards.

```
User
  - email
  - name
  - app_admin (boolean) — GLOBAL admin: manages teams, fixtures, results, sync.
                          (Ivan as owner; Simon for now.) Distinct from group admin.

Group
  - name
  - slug

Membership
  - user (User)
  - group (Group)
  - role (member | admin) — a GROUP admin manages that group's members and reminders
  - unique on (user, group)

Team
  - name
  - short_code
  - crest_url (optional)

Fixture
  - season (string, e.g. "2025-26")
  - gameweek (integer) — a LABEL, not a count. Never assume 10 fixtures per gameweek.
                         Stays fixed even if the match is rescheduled to another date.
  - home_team (Team)
  - away_team (Team)
  - kickoff_at (datetime)
  - home_score (integer, nullable)
  - away_score (integer, nullable)
  - status (scheduled | live | finished | postponed)

Prediction
  - user (User)
  - fixture (Fixture)
  - home_score (integer)
  - away_score (integer)
  - points (integer, nullable) — set by the scorer when a result is entered;
                                 RECALCULATED if the result is later edited
  - submitted_at (datetime)
  - locked (boolean) — true once the fixture's kickoff_at has passed
  - unique on (user, fixture)
```

### Two admin tiers

- **App admin** (`User.app_admin`) — global: manages teams, fixtures, results, and sync. Fixtures are shared data, so this must NOT be a per-group permission.
- **Group admin** (`Membership.role == admin`) — scoped to one group: manages members, sends that group's reminders. Simon is both for now.

### Leaderboards

- **Cumulative (season):** sum of `Prediction.points` across a group's members for the season.
- **Per-gameweek:** the same, filtered by `fixture.gameweek`.
- Future prizes (top scorer per gameweek, best single-gameweek score over the season) are all computable from stored `points` — no extra schema needed now.

---

## Scoring rules

- **2 points** — correct match outcome (win/draw/loss)
- **5 points** — exact correct score (includes the outcome points, not additive — max 5 per match)
- Scoring is computed by a `PredictionScorer` and stored on `Prediction.points`. When a result is entered OR edited, re-score all predictions for that fixture (enqueue a job).
- A match's points always count toward the **gameweek it was originally assigned to**, even if it's postponed and played weeks later.

## Premier League structural realities (don't design against a clean 38×10)

The real-world schedule is messy, and the data model must tolerate it:

- The season is **33 weekends + 5 midweek rounds**, not 38 tidy gameweeks. A "gameweek" can have **fewer or more than 10 fixtures**.
- **Blank gameweeks** (a team has no match that week) and **double gameweeks** (a team plays twice in one week) happen because of FA Cup / EFL Cup / European clashes.
- Fixtures are **frequently rescheduled** for TV and cup clashes; matches get **postponed** and replayed later.
- This is exactly why predictions **lock per-match at each fixture's own `kickoff_at`** — not on a single shared gameweek deadline. A postponed match simply stays open until its rescheduled kickoff. Do not introduce a per-gameweek lock.

---

## User roles

- **Participant** (`Membership.role == member`) — views fixtures, submits predictions, views their group's leaderboard
- **Group admin** (`Membership.role == admin`) — manages that group's members, sends that group's reminders
- **App admin** (`User.app_admin`) — global: manages teams, fixtures, results, triggers sync, enters results manually if the API fails, can view all predictions

Simon is both group admin (of the founding group) and app admin for now. As more groups join, each group gets its own group admin, while fixture/result/sync stays with app admins (Ivan + Simon).

---

## Authentication

Magic link only via `passwordless` gem. No passwords. Users enter their email, receive a sign-in link, click it. This must work smoothly on mobile for older, less technical users.

### Joining a group (Phase 1)

- **Admin-adds-by-email.** A group admin enters a participant's email (and name) to create their `Membership`. There is no self-serve sign-up in the MVP — this fits a known, ~15-person private group.
- A user only ever authenticates via magic link; being added by email simply creates the membership so that, on first sign-in, they land in their group.
- **Invite links (`/join/:slug`) are deferred** to Phase 2+, when a second group actually appears.

---

## Admin interface

Simon is non-technical. He needs a simple, clearly labelled admin UI built into the app — not Rails Admin or ActiveAdmin. Keep it custom, minimal, and obvious. Priorities:

- View/edit fixtures
- Trigger manual fixture + result sync
- View who has/hasn't submitted predictions for a gameweek
- Send reminder emails manually (button) and automatically (scheduled job)

---

## Fixture and result sync

**Provider: football-data.org** (free tier). Chosen because **api-football.com's free plan does NOT serve the current season** — its free tier is restricted to seasons 2022–2024 (verified directly: requesting the live season returns `"Free plans do not have access to this season, try from 2022 to 2024."`). That makes it unusable for a live predictions app.

football-data.org free tier — confirmed fit:

- **Premier League included**, and **the current season (2025/26) is included** — the decisive difference from api-football.
- **10 requests/minute** rate limit. Fine for one scheduled sync; don't fetch per-request.
- Acceptable caveats: scores are **delayed, not real-time** (we sync nightly + post-match, so fine), and there's **no player-level data** (we don't need it).

Implementation notes:

- Write sync behind a small **provider adapter** (`FixtureSyncService` + a provider class) so swapping providers later is cheap, even though football-data.org is the committed choice now.
- Sync runs via a scheduled background job (nightly + post-match). **Note:** on Render's free tier the app sleeps when idle, so scheduled jobs won't fire while asleep — see deploy notes for the keep-warm workaround.
- **Graceful failure is mandatory** — if sync fails, fixtures and results remain fully editable by hand via the admin UI. This is why manual entry is built in Phase 1, before the API.

---

## Reminders

- Automated reminder email before each gameweek deadline (configurable lead time)
- Admin can also trigger a manual reminder from the admin UI
- Only send to users who haven't yet submitted predictions for that gameweek

---

## UI principles

- Mobile-first — most users will access on their phones
- Minimal, clean aesthetic — high contrast, generous whitespace, clear typography
- Native CSS — inspired by 37signals' Fizzy; no utility framework
- ViewComponents for anything reused: fixture card, prediction form, leaderboard row, etc.
- Plain language throughout — this is not a technical audience

---

## Build order (phases)

### Phase 1 — Core loop (build this first)

1. Models + migrations: User, Group, Membership, Team, Fixture, Prediction (multi-group schema from the start)
2. Magic link auth (passwordless); group admin adds participants by email to create memberships (no self-serve sign-up)
3. Admin (app-admin) UI: create/edit Teams and Fixtures by hand, set gameweek + kickoff. **During Phase 1 testing, Ivan (app admin) enters fixture data — NOT Simon.** Simon's spreadsheet doesn't capture kickoff times today, but the app requires them for per-match locking, so this data is intrinsic. Simon only tests result entry + the submitted/not-submitted view. Hand-entry is temporary: Phase 2 sync auto-populates fixtures, after which this UI is only an editing/fallback tool (postponements, sync failures).
4. Fixture index — list the upcoming gameweek's fixtures for the user's group
5. Prediction form — submit home/away score per fixture
6. Prediction lock — each prediction locks at its own fixture's kickoff
7. Result entry — app admin enters actual scores; PredictionScorer stores points
8. Leaderboard — cumulative + per-gameweek, ranked, scoped to the group
9. Tests alongside each step (RSpec; system test for the predict → lock → score → leaderboard loop)

### Phase 1b — Deploy for real-world testing

10. Deploy to **Render** free tier (Rails web service + managed PostgreSQL), Solid Queue in Puma
11. Custom domain — now effectively required (Resend needs a verified sending domain to email participants)
12. Smoke test the full loop with 2–3 real participants before wider rollout
13. Note Render free-tier realities for users: ~30–60s cold start after idle; Postgres expires after 90 days (plan a backup/recreate)

### Phase 2 — Automate the pain

14. Fixture/result sync via **football-data.org** behind a provider adapter + FixtureSyncService
15. Scheduled sync jobs — with a keep-warm/trigger strategy that survives Render's idle sleep (e.g. external cron pinger or Render Cron Job)
16. Reminder emails (automated before each gameweek deadline + manual trigger), only to users who haven't submitted

### Phase 3 — Polish

17. Admin dashboard refinement
18. Email design
19. Mobile UX pass

---

## Commit rules

A commit must represent a working, tested state:

1. The task is complete (no half-finished work)
2. `bundle exec rspec` passes — all tests green
3. Amend or squash into the relevant commit while changes are still local; don't leave the passwordless-migration-style loose ends once pushed

Never commit to unblock yourself. If tests are failing, fix them first.

---

## What to avoid

- Devise — use `passwordless` gem instead
- React or any JS-heavy frontend — Hotwire only
- Overengineering Phase 1 — get the core loop working first
- Scope creep — defer anything outside the current phase rather than building it now
- Optimistic estimates about complexity — be honest if something is harder than it looks
