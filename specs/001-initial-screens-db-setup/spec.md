# Feature Specification: App-Specific Screens + Database Schema + Repositories (D1)

**Feature Branch**: `001-initial-screens-db-setup`
**Created**: 2026-02-11
**Status**: Done
**Input**: User description: "Implement D1 from /docs/PRD.md — App-specific screens + database schema + repositories"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log Water via Quick-Add (Priority: P1)

A user opens the app and taps one of the quick-add buttons (250ml,
500ml, or 750ml) to log their water intake. The entry is persisted
locally and today's progress updates immediately on the Home screen.

**Why this priority**: Fast water logging is the core value proposition
of the app. If a user cannot log water with a single tap and see the
result, the app fails its primary purpose.

**Independent Test**: Open the app, tap "250ml", verify the progress
display updates from 0/2000 to 250/2000. Restart the app and verify
the entry persists.

**Acceptance Scenarios**:

1. **Given** the Home screen is displayed with 0ml consumed,
   **When** the user taps the "250ml" quick-add button,
   **Then** a 250ml entry is persisted locally with a unique ID and
   timestamp, and the progress display updates to show "250 / 2000 ml".

2. **Given** the user has logged 250ml,
   **When** the user taps the "500ml" quick-add button,
   **Then** the progress display updates to show "750 / 2000 ml".

3. **Given** entries exist for today,
   **When** the app is restarted,
   **Then** today's total is preserved and displayed correctly on the
   Home screen.

---

### User Story 2 - View Today's Entries (Priority: P1)

A user navigates to the Daily screen to review their water intake
entries for today. Entries are listed newest-first with the amount
and time.

**Why this priority**: Users need to see what they've logged to
verify accuracy. The Daily screen is the review counterpart to the
Home screen's logging functionality.

**Independent Test**: Log several entries at different times, navigate
to Daily, verify entries appear in newest-first order with correct
amounts and times.

**Acceptance Scenarios**:

1. **Given** entries exist for today,
   **When** the user opens the Daily screen,
   **Then** the screen shows "Today: {total_ml} ml" at the top and
   lists entries newest-first as "{amount} ml" with timestamps.

2. **Given** no entries exist for today,
   **When** the user opens the Daily screen,
   **Then** the screen shows "No entries yet today" as an empty state.

---

### User Story 3 - View Streak Counters (Priority: P1)

A user sees their current streak (consecutive days meeting the daily
target) and longest streak displayed on the Home screen.

**Why this priority**: Streaks provide motivation and are prominently
displayed on the Home screen (FR-005, FR-010). They depend on the
stats repository being correctly wired to the UI.

**Independent Test**: Seed entries meeting the target for 3 consecutive
days ending today. Verify Home shows "Current Streak: 3" and
"Longest: 3".

**Acceptance Scenarios**:

1. **Given** the user has met the daily target for 3 consecutive days
   ending today,
   **When** the user opens the Home screen,
   **Then** the current streak shows 3 and the longest streak shows 3.

2. **Given** no entries exist,
   **When** the user opens the Home screen,
   **Then** both current streak and longest streak show 0.

3. **Given** a gap exists in the streak (yesterday missed),
   **When** the user meets the target today,
   **Then** the current streak shows 1 (today only), while longest
   streak reflects the historical maximum.

---

### User Story 4 - Database Schema and Persistence (Priority: P1)

The app stores water entries and user settings in a local SQLite
database via drift. The schema includes `water_entries` (id, entry_ts,
entry_date, amount_ml, created_at) and `user_settings` (id,
daily_target_ml, created_at, updated_at) tables with appropriate
constraints and indexes.

**Why this priority**: All data persistence depends on the database
schema. Without correct tables, constraints, and indexes, no
repository or UI feature can function.

**Independent Test**: Create an in-memory database, insert a water
entry, verify all fields are stored correctly. Verify the default
settings row is seeded with 2000ml target.

**Acceptance Scenarios**:

1. **Given** a fresh database,
   **When** the app initialises,
   **Then** the `water_entries` and `user_settings` tables are created
   with correct columns and constraints, and indexes on `entry_date`
   and `entry_ts` exist.

2. **Given** a fresh database,
   **When** the app initialises,
   **Then** a default settings row with id=1 and daily_target_ml=2000
   is seeded.

3. **Given** the `water_entries` table,
   **When** an entry with amount_ml outside [1, 5000] is inserted,
   **Then** the insertion is rejected by the CHECK constraint.

4. **Given** the `user_settings` table,
   **When** daily_target_ml outside [250, 10000] is set,
   **Then** the update is rejected by validation.

---

### User Story 5 - Repository Layer (Priority: P1)

Repositories provide a clean API for data operations: adding/listing/
deleting water entries, computing daily totals and streaks, and
getting/setting the daily target.

**Why this priority**: Repositories decouple UI from database
implementation. All screen data depends on repository methods working
correctly.

**Independent Test**: Using an in-memory database, exercise each
repository method and verify correct return values and side effects.

**Acceptance Scenarios**:

1. **Given** the WaterEntryRepository,
   **When** `add(amountMl: 500)` is called,
   **Then** a WaterEntry is returned with a UUID, correct timestamp,
   derived entry_date, and amount_ml=500.

2. **Given** entries for a specific date,
   **When** `listByDate(date)` is called,
   **Then** entries are returned newest-first.

3. **Given** an existing entry,
   **When** `delete(id)` is called,
   **Then** the entry is removed and `true` is returned.

4. **Given** the WaterStatsRepository,
   **When** `getTodayTotal()` is called with entries for today,
   **Then** the sum of today's entry amounts is returned.

5. **Given** daily totals across a date range,
   **When** `getDailyTotals(start, end)` is called,
   **Then** a map of date→total is returned for the range.

6. **Given** the WaterStatsRepository,
   **When** `getStreaks(today, targetMl)` is called,
   **Then** current and longest consecutive-day streaks are returned.

7. **Given** the SettingsRepository,
   **When** `getTarget()` is called on a fresh database,
   **Then** the default value 2000 is returned.

8. **Given** the SettingsRepository,
   **When** `setTarget(3000)` is called followed by `getTarget()`,
   **Then** 3000 is returned.

---

### User Story 6 - Screen Shells for Weekly, Monthly, and Settings (Priority: P2)

Weekly Summary, Monthly Patterns, and Settings screens display
placeholder content with correct titles and basic state wiring. These
screens serve as mounting points for D4 (charts) and D5 (settings
editor).

**Why this priority**: These screens establish the routing targets
and basic layout. Full implementation is deferred but the shells must
be present and navigable.

**Independent Test**: Navigate to each screen via bottom navigation
or settings icon. Verify correct title renders and no errors occur.

**Acceptance Scenarios**:

1. **Given** the user is on any tab,
   **When** the user navigates to Weekly Summary,
   **Then** the screen renders with title "Weekly Summary" and a
   placeholder indicating chart content is coming.

2. **Given** the user is on any tab,
   **When** the user navigates to Monthly Patterns,
   **Then** the screen renders with title "Monthly Patterns" and a
   placeholder indicating heatmap content is coming.

3. **Given** the user taps the settings icon,
   **When** the Settings screen renders,
   **Then** it shows the current daily target value (2000ml default)
   with a list tile layout.

---

### Edge Cases

- What happens when multiple quick-add taps occur rapidly? Each tap
  MUST create a separate entry and the total MUST update to reflect
  all entries.
- What happens when the app is force-killed mid-write? Drift's
  transactional writes ensure atomicity — partial entries should not
  exist.
- What happens on the date boundary (midnight)? Entries use the
  timestamp's date component, so entries logged near midnight are
  attributed to the correct calendar day.
- What happens when entries span multiple days but the user views
  Daily? Only entries matching today's date are shown.
- What happens with the maximum valid entry (5000ml)? It MUST be
  accepted and displayed correctly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-D1-001**: The Home screen MUST display today's progress as
  "{consumed_ml} / {target_ml} ml" using live data from the database.
- **FR-D1-002**: The Home screen MUST provide quick-add buttons for
  250ml, 500ml, and 750ml that persist entries immediately.
- **FR-D1-003**: The Home screen MUST display current streak and
  longest streak counters.
- **FR-D1-004**: The Daily screen MUST show today's total and list
  entries newest-first with amounts and timestamps.
- **FR-D1-005**: The Daily screen MUST show an empty state when no
  entries exist for today.
- **FR-D1-006**: The database schema MUST include `water_entries`
  table with id (TEXT PK), entry_ts (TEXT), entry_date (TEXT),
  amount_ml (INTEGER CHECK 1-5000), created_at (TEXT).
- **FR-D1-007**: The database schema MUST include `user_settings`
  table with id (INTEGER PK autoincrement), daily_target_ml (INTEGER
  CHECK 250-10000), created_at (TEXT), updated_at (TEXT).
- **FR-D1-008**: The database MUST create indexes on entry_date and
  entry_ts columns of water_entries.
- **FR-D1-009**: The database MUST seed a default settings row with
  id=1 and daily_target_ml=2000 on first launch.
- **FR-D1-010**: WaterEntryRepository MUST support add (with
  validation), listByDate (newest-first), and delete operations.
- **FR-D1-011**: WaterStatsRepository MUST support getTodayTotal,
  getDailyTotals, getWeeklySummary, getMonthlyTotals, and getStreaks.
- **FR-D1-012**: SettingsRepository MUST support getTarget (default
  2000) and setTarget (with validation).
- **FR-D1-013**: All repositories MUST be accessible via Riverpod
  providers (keepAlive: true).
- **FR-D1-014**: Weekly and Monthly screens MUST render shells with
  placeholder content for future D4 implementation.
- **FR-D1-015**: Settings screen MUST display the current daily target
  value.

### Key Entities

- **WaterEntry**: A single water intake log with id, timestamp, date,
  amount in ml, and creation timestamp. Stored in the `water_entries`
  table.
- **UserSetting**: Application-level settings (single row) storing
  the daily target in ml. Stored in the `user_settings` table.
- **Repository**: A class providing typed, validated data access
  methods over the drift database. Injected via Riverpod providers.
- **Provider**: A Riverpod provider exposing reactive data (today's
  total, entries, streaks, daily target) to the UI layer.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can log water via quick-add (250/500/750ml) and
  see the progress update immediately on the Home screen.
- **SC-002**: Logged entries persist across app restarts and are
  visible in the Daily screen.
- **SC-003**: Streak counters on Home compute correctly based on
  consecutive days meeting the target.
- **SC-004**: All repository unit tests pass: WaterEntryRepository
  (add, listByDate, delete, validation), WaterStatsRepository
  (getTodayTotal, getDailyTotals, getWeeklySummary, getMonthlyTotals,
  getStreaks), SettingsRepository (getTarget, setTarget, validation).
- **SC-005**: The database schema matches the PRD Section 6.1 data
  model with correct constraints and indexes.
- **SC-006**: Weekly, Monthly, and Settings screens render their
  shells without errors.
- **SC-007**: `flutter test` passes with all repository and database
  tests green.
- **SC-008**: `flutter analyze` passes with zero errors.

## Assumptions

- The D0 scaffold (navigation, theme, routing, database bootstrap)
  is already in place and functioning correctly.
- The database schema version is incremented from 1 (D0) to 2 (D1)
  to add the water_entries and user_settings tables via migration.
- Quick-add buttons on Home do not show a confirmation dialog — the
  entry is logged immediately on tap for maximum speed (FR-002: ≤3s).
- The Daily screen does not support entry deletion in D1 — that is
  deferred to D3. Entries are displayed as read-only list items.
- Weekly and Monthly screens are placeholders — chart and heatmap
  implementations are deferred to D4.
- Settings screen displays the target but does not support editing
  it — the editor is deferred to D5.
- Custom amount input (bottom sheet with validation) is deferred to
  D2 per the deliverables plan.
- Riverpod code generation (`riverpod_annotation` + `build_runner`)
  is used for provider definitions.
