```yaml
prd_version: 1.0
product: WaterLog (Local Water Tracker)
doc_owner: Greta
last_updated: 2026-02-10
status: draft
tech_stack:
  client:
    - Flutter (stable)
    - Dart
    - go_router (navigation)
    - Riverpod (state management)
    - drift (SQLite ORM + migrations)  # uses SQLite on-device
    - fl_chart (charts)
    - intl (date/time formatting)
    - uuid (ids)
  backend:
    - none (offline-first, on-device only)
repositories:
  - <repo name or url>
environments:
  - name: dev
    notes: Flutter run on simulator/emulator
  - name: prod
    notes: iOS + Android builds, local DB migrations included
```

## 1) TL;DR

* **Problem:** Most people intend to drink more water, but they forget and have no simple way to track daily intake without accounts, ads, or “fitness app” bloat.
* **Solution:** A clean, offline-first water tracker with fast logging (quick-add + custom), daily detail, weekly and monthly patterns, and streaks.
* **Success metrics (3–5):**
  * M1: User can log water in ≤ 3 seconds using a quick-add button (median).
  * M2: User can log a custom amount in ≤ 15 seconds (median).
  * M3: Home renders in ≤ 500ms with 365 days of history (cold start excluded) on mid-range devices.
  * M4: Crash-free sessions ≥ 99% in production.
  * M5: Data remains on-device (no network calls; verified via inspection).
* **Out of scope (top 3):**
  * OOS1: Accounts / sign-in / cloud sync / backups.
  * OOS2: Notifications/reminders, coaching, or “smart” hydration plans (v1 is manual logging).
  * OOS3: Tracking other beverages, electrolytes, caffeine, or “hydration score” algorithms.
* **Deliverables:** D0–D5 (Section 10)

---


### Why water?

* Water intake is a “forgotten metric”: lots of people want to drink more, but it rarely gets a dedicated, simple tracker.
* It’s universally positive and low-friction — there’s no stigma in tracking it, which makes adoption easier than sleep or time tracking.
* It’s simple enough to build and finish quickly, while still offering meaningful patterns (daily progress, weekly bars, monthly heatmap, streaks).


## 2) Goals and Non-Goals

### Goals (MUST)

* G1: Provide a frictionless way to log water intake with one tap.
* G2: Let users review today’s entries and delete mistakes quickly.
* G3: Surface basic patterns (weekly totals vs target, monthly heatmap).
* G4: Track streaks for “days hitting target” (current + longest).
* G5: Keep everything offline and stored locally on the phone.

### Non-Goals (NOT doing in v1)

* NG1: Any user identity, profiles, or cross-device sync.
* NG2: Reminders/notifications, goal coaching, or gamification beyond streaks.
* NG3: Complex beverage logging (coffee/tea/alcohol) and adjustments for exercise/weather.

---

## 3) Users and Key Flows

### Personas

* P1: Busy professional who wants quick logging with no setup.
* P2: Habit-builder who wants streak motivation and simple trends.

### Key journeys

* J1: **First use → set target → log water**
  1. Open app → Home (empty state)
  2. Set daily target (inline prompt or settings)
  3. Tap “Glass (250ml)” → progress updates immediately

* J2: **Log a custom amount**
  1. Open Home
  2. Tap “Custom”
  3. Enter amount (ml) → Add
  4. See progress ring update

* J3: **Fix a mistake**
  1. Open Daily view
  2. Tap an entry → Delete → confirm
  3. Totals and charts update

* J4: **Check progress & patterns**
  1. Open Weekly Summary → bars vs target line + weekly stats
  2. Open Monthly Patterns → calendar heatmap + tap day tooltip

---

## 4) Functional Requirements (FR)

### FR list

**FR-001: App MUST run fully offline and MUST NOT require account creation.**
* **Acceptance (BDD):**
  * Given the device is in airplane mode
    When the user opens and uses all screens
    Then all features work and no network requests are made

**FR-002: App MUST allow logging water intake via quick-add buttons (250/500/750ml) and a custom amount.**
* **Acceptance (BDD):**
  * Given the Home screen
    When the user taps “Glass (250ml)”
    Then a 250ml entry is persisted locally with a unique ID and timestamp
    And the progress indicator updates
  * Given the Custom flow
    When the user enters 330 and taps Add
    Then a 330ml entry is persisted locally with a unique ID and timestamp

**FR-003: App MUST store entries in local storage with (id, timestamp, amount_ml, entry_date).**
* **Acceptance (BDD):**
  * Given any logged entry
    When the app restarts
    Then the entry remains and appears in Daily view and aggregations

**FR-004: App MUST validate custom input.**
* **Validation rules (v1):**
  * amount_ml must be an integer
  * 1 ≤ amount_ml ≤ 5000
* **Acceptance (BDD):**
  * Given the Custom input
    When amount_ml is empty, non-numeric, or outside bounds
    Then Add is blocked and an inline validation message is shown

**FR-005: Home screen MUST show daily progress towards the target and prominent streak counters.**
* **Home shows:**
  * Circular progress indicator: consumed_ml / target_ml
  * Quick-add buttons + Custom
  * Current streak + longest streak
* **Acceptance (BDD):**
  * Given entries exist for today
    When the user opens Home
    Then Home shows today’s total consumed_ml and % progress to target
    And shows current and longest streak values

**FR-006: Daily view MUST show today’s total, progress bar, and a timestamped list of entries.**
* **Acceptance (BDD):**
  * Given entries exist for today
    When the user opens Daily view
    Then the screen shows total consumed_ml for today
    And lists entries newest-first as “{amount}ml at HH:mm”

**FR-007: Daily view MUST allow deleting an entry (with confirmation).**
* **Acceptance (BDD):**
  * Given an entry in Daily view
    When the user taps the entry and chooses Delete and confirms
    Then the entry is removed from local storage
    And today’s total and charts update accordingly

**FR-008: Weekly Summary MUST show a 7-day bar chart of daily totals and a target reference line.**
* **Acceptance (BDD):**
  * Given at least 1 day of data in the last 7 days
    When the user opens Weekly Summary
    Then a 7-day bar chart displays daily totals
    And a horizontal line indicates target_ml
    And the screen shows average daily intake for the week
    And the number of days target was hit

**FR-009: Monthly Patterns MUST show a calendar heatmap of daily totals with a “hit target” marker.**
* **Acceptance (BDD):**
  * Given data exists in the month
    When the user opens Monthly Patterns
    Then each day shows a coloured intensity based on total intake
    And days meeting/exceeding the target show a tick marker
  * Given the user taps a day cell
    Then a tooltip shows that date’s total and whether the target was hit

**FR-010: Streak tracking MUST compute consecutive days meeting/exceeding the target.**
* **Definitions (v1):**
  * A day counts as “hit” if total_ml(date) ≥ target_ml.
  * Current streak counts backwards from **today** (local date) while days are “hit”.
  * Longest streak is the max consecutive “hit” days across all history.
* **Acceptance (BDD):**
  * Given a run of hit days ending today
    When the user opens Home
    Then current_streak reflects that run length
  * Given at least one longer historical run
    Then longest_streak reflects the max run

**FR-011: App MUST provide empty states for all screens when data is insufficient.**
* **Acceptance (BDD):**
  * Given zero entries
    When the user opens Home/Daily/Weekly/Monthly
    Then an empty state prompts the user to log water (and set target if needed)

**FR-012 (SHOULD): App SHOULD allow changing the daily target in-app (no account).**
* **Acceptance (BDD):**
  * Given the user updates target_ml
    When they return to Home
    Then progress, charts, and streak calculations use the new target

---

## 5) Non-Functional Requirements (NFR)

**NFR-001 (Privacy/Security):** No data leaves the device.
* Threshold: 0 app-initiated external network requests.
* Test: Run app under a proxy / OS network monitor; confirm no requests; code scan to ensure no HTTP client usage.

**NFR-002 (Performance):**
* Threshold: Home + Daily render ≤ 500ms with 365 days of totals + ~5,000 entries (excluding cold start).
* Test: Seed DB; measure via Flutter DevTools timeline; ensure ListView.builder virtualization.

**NFR-003 (Reliability/Data Integrity):**
* Threshold: No data loss across app restarts; drift migrations preserve entries.
* Test: Create entries → restart app → verify; migration test from previous schema.

**NFR-004 (Accessibility):**
* Threshold: All controls have semantic labels; supports larger text sizes where practical.
* Test: TalkBack/VoiceOver pass; check tappable targets and semantics.

**NFR-005 (Offline-first):**
* Threshold: Full feature parity in airplane mode.
* Test: Manual QA in airplane mode + integration tests.

---

## 6) Data & Contracts

### 6.1 Data model (SQLite via drift)

**water_entries**
* `id TEXT PRIMARY KEY` (uuid)
* `entry_ts TEXT NOT NULL` (ISO datetime local)
* `entry_date TEXT NOT NULL` (`YYYY-MM-DD`, derived from entry_ts in local timezone)
* `amount_ml INTEGER NOT NULL`
* `created_at TEXT NOT NULL`

Indexes:
* index on `entry_date`
* index on `entry_ts`

Constraints:
* `1 <= amount_ml <= 5000`

**user_settings** (v1 minimal; single row)
* `id INTEGER PRIMARY KEY` (always 1)
* `daily_target_ml INTEGER NOT NULL`
* `created_at TEXT NOT NULL`
* `updated_at TEXT NOT NULL`

Constraints:
* `daily_target_ml` in [250..10000] (tunable)

### 6.2 Repository contracts (local)

**WaterEntryRepository.add(amount_ml, entry_ts?)**
* If `entry_ts` omitted, use now (local).

Request (conceptual):
```json
{
  "amount_ml": 500,
  "entry_ts": "2026-02-10T11:30:00"
}
```

Response:
```json
{
  "id": "uuid",
  "entry_date": "2026-02-10"
}
```

Errors:
* `invalid_amount`

**WaterEntryRepository.listByDate(entry_date)**
**WaterEntryRepository.delete(id)**

**WaterStatsRepository.getTodayTotal()**
**WaterStatsRepository.getDailyTotals(rangeStart, rangeEnd)**  // inclusive dates
**WaterStatsRepository.getWeeklySummary(endingOnDate)**
**WaterStatsRepository.getMonthlyTotals(year, month)**
**WaterStatsRepository.getStreaks(todayDate)**

**SettingsRepository.getTarget()**
**SettingsRepository.setTarget(daily_target_ml)**

### 6.3 Permissions

* MUST NOT request microphone/contacts/location.
* MUST NOT add analytics SDKs that transmit data off-device in v1.

---

## 7) UX Spec

### Screens (5-feature mapping)

1. **Home**: progress ring + quick-add buttons + streaks.
2. **Daily**: today’s total + progress bar + entry list with delete.
3. **Weekly Summary**: 7-day bars + target line + weekly stats.
4. **Monthly Patterns**: calendar heatmap + day tooltip + target ticks.
5. **Settings (optional/modal)**: set daily target, reset data (optional), about.

### Navigation

* Bottom navigation: Home / Daily / Weekly / Monthly
* Settings accessed via top-right icon (gear) from Home (or app bar action on all tabs)

### Per-screen notes

**Home**
* Center: circular progress indicator (consumed / target).
* Buttons: Glass (250), Bottle (500), Large Bottle (750), Custom.
* Streak: “Current streak: X days” and “Longest: Y days”.
* Empty/first-run: “Set your daily target to get started” + default suggestion (configurable).

**Custom add**
* Simple modal / bottom sheet:
  * numeric input (ml)
  * Add button
  * Inline validation messages

**Daily**
* Top: “Today: {total_ml} ml”
* Progress bar to target.
* List: entries newest-first: “250ml at 09:14”
* Tap entry → details bottom sheet → Delete

**Weekly Summary**
* fl_chart bar chart:
  * x-axis: last 7 days labels (Mon–Sun or dates)
  * y-axis: ml
  * target line at target_ml
* Below chart:
  * Average per day
  * Days hit target

**Monthly Patterns**
* Calendar grid (7 columns):
  * Cell colour intensity mapped to total_ml for that date
  * Tick if total ≥ target
* Tap cell: tooltip with date + total + “Target hit” status

---

## 8) Telemetry & Ops (v1 default: none)

* No remote analytics in v1.
* Optional: local-only debug logging (dev builds only).

---

## 9) Risks & Edge Cases

**Risks**
* Time/date boundaries (entries near midnight; DST) → store full timestamps; derive `entry_date` on save; display local times consistently.
* Chart/heatmap performance → pre-aggregate daily totals and cache computations in memory/state.

**Edge cases**
* Multiple entries per day are expected (typical).
* Very large single entries (e.g. 2,000ml) → allowed if within validation bounds.
* Target changes affect streak history: streaks should recompute using the current target (v1). Document this behaviour in-app.

**Open questions**
* Should target changes apply retroactively (recompute all streaks) or only from change date forward?
* Should we support editing an entry amount/time, or only delete+re-add?
* Should we offer unit toggle (ml/oz) or keep ml-only in v1?

---

## 10) Deliverables Plan (Agent Build Units)

### D0 — Flutter scaffold, navigation, and local DB bootstrap

* **Objective:** App boots with routing + tab navigation + shared UI foundations + database wiring (no feature-specific UI yet).
* **Scope:** App shell only (offline-first posture, theming, navigation, DB init).
* **Tech choices:** Flutter + go_router; Riverpod project structure; drift initialisation + migrations scaffold.
* **Artifacts:**
  * Flutter project with app theme, typography (see brand-kit.md), and reusable components folder
  * Navigation scaffold (bottom tabs + app bars) with placeholder screen widgets
  * drift database initialised (migration infrastructure in place; tables can be stubbed or empty)
  * README: run/lint/test
* **Acceptance (BDD):**
  * Given a fresh install
    When the user opens the app
    Then the app renders the shell and navigation reaches each placeholder tab without errors

### D1 — App-specific screens + database schema + repositories

* **Objective:** Establish the real WaterLog screens and persistence layer end-to-end.
* **Scope:** Section 6 tables + basic CRUD + screen shells for Home/Daily/Weekly/Monthly (+ Settings entry point).
* **Artifacts:**
  * Screen shells with layout placeholders and state wiring (no charts/heatmap polish yet)
  * drift schema: `water_entries`, `user_settings` + migrations
  * Repositories: add/list/delete + get/set target + daily total for today
  * Unit tests for validation and CRUD
* **Acceptance:** user can log a quick-add entry and see it reflected in today’s total after app restart.

### D2 — Home screen + fast logging UX

* **Objective:** Make logging feel instant and motivating.
* **Scope:** FR-002/004/005/010/011 (+ part of FR-012 for target display)
* **Implementation notes:**
  * Progress ring (consumed/target) + % label
  * Quick-add (250/500/750) + Custom modal with validation
  * Streak counters visible on Home
* **Artifacts:** UI + widget tests for quick-add and custom validation.

### D3 — Daily view + delete flow

* **Objective:** Make it easy to review and correct today’s logs.
* **Scope:** FR-006/007/011
* **Implementation notes:**
  * Query by today’s date; list newest-first
  * Tap entry → delete confirmation
  * Ensure totals update immediately
* **Artifacts:** UI + tests verifying delete impacts today total and streak.

### D4 — Weekly Summary + Monthly Patterns

* **Objective:** Visualise patterns with simple stats.
* **Scope:** FR-008/009/011
* **Implementation notes:**
  * Weekly: last 7 days bars + target reference line + “avg/day” + “days hit”
  * Monthly: calendar heatmap (intensity by total) + tick if hit target + tap tooltip
* **Artifacts:** UI + aggregation tests for weekly/monthly ranges.

### D5 — Settings + polish, QA, release readiness

* **Objective:** Target management, accessibility, performance, and regression coverage.
* **Scope:** FR-012 + NFRs + release checklist
* **Artifacts:**
  * Settings screen/modal: edit daily target; optional “reset all data” (only if explicitly included)
  * Integration tests (integration_test) for key journeys:
    * quick-add logging
    * custom add validation
    * delete entry
    * weekly/monthly render with seeded data
    * change target and confirm recalculation behaviour
  * Seed/debug tools (dev-only) to populate sample entries
  * Release checklist + known limitations (DST, target-change streak behaviour)
* **Acceptance:** Airplane-mode QA passes; no network calls observed; crash-free smoke.
