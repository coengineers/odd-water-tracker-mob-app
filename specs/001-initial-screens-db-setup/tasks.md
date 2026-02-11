# Tasks: App-Specific Screens + Database Schema + Repositories (D1)

**Input**: Design documents from `/specs/001-initial-screens-db-setup/`
**Prerequisites**: spec.md (required), /docs/PRD.md, D0 scaffold complete on `main`

**Tests**: Included — the feature specification requires unit tests for all repository methods (FR-D1-010, FR-D1-011, FR-D1-012, SC-004, SC-007) and database schema validation (SC-005).

**Organization**: Tasks are grouped by phase. Database schema (US4) comes first because all repositories depend on it. Repositories (US5) come next because all screen data depends on them. Screen implementation follows.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US6)
- Exact file paths included in descriptions

---

## Phase 1: Database Schema (Blocking Prerequisites)

**Purpose**: Define drift tables, migration from schema v1→v2, indexes, and default settings seed.

**⚠️ CRITICAL**: No repository or screen work can begin until this phase is complete.

- [x] T001 [US4] Create `lib/db/tables/water_entries.dart` — `WaterEntries` drift Table with: `id` TEXT primary key, `entryTs` TEXT NOT NULL, `entryDate` TEXT NOT NULL, `amountMl` INTEGER NOT NULL with CHECK constraint (1-5000), `createdAt` TEXT NOT NULL
- [x] T002 [P] [US4] Create `lib/db/tables/user_settings.dart` — `UserSettings` drift Table with: `id` INTEGER autoIncrement primary key, `dailyTargetMl` INTEGER NOT NULL with CHECK constraint (250-10000), `createdAt` TEXT NOT NULL, `updatedAt` TEXT NOT NULL
- [x] T003 [US4] Update `lib/db/app_database.dart` — add `WaterEntries` and `UserSettings` to `@DriftDatabase(tables: [...])`, increment `schemaVersion` to 2, implement migration from v1→v2 in `onUpgrade`, add `_createIndexes()` for `entry_date` and `entry_ts` indexes, add `_seedDefaultSettings()` for default row (id=1, daily_target_ml=2000) in `beforeOpen`
- [x] T004 [US4] Run `dart run build_runner build` to regenerate `app_database.g.dart` with new table definitions

**Checkpoint**: Database compiles with new tables. `flutter analyze` passes. In-memory DB creates tables with correct schema.

---

## Phase 2: Repository Layer

**Purpose**: Implement typed data access repositories with validation for all database operations.

- [x] T005 [US5] Create `lib/repositories/water_entry_repository.dart` — `WaterEntryRepository` class accepting `AppDatabase`, implementing: `add({required int amountMl, DateTime? entryTs})` with validation (1-5000), UUID generation, ISO timestamp formatting, entry_date derivation; `listByDate(String entryDate)` returning entries ordered by entryTs DESC; `delete(String id)` returning bool
- [x] T006 [P] [US5] Create `lib/repositories/water_stats_repository.dart` — `WaterStatsRepository` class implementing: `getTodayTotal()` using SUM aggregate; `getDailyTotals(String rangeStart, String rangeEnd)` returning `Map<String, int>`; `getWeeklySummary(String endingOnDate)` delegating to getDailyTotals with 7-day window; `getMonthlyTotals(int year, int month)` with correct month boundaries; `getStreaks(String todayDate, int targetMl)` returning `({int current, int longest})` record
- [x] T007 [P] [US5] Create `lib/repositories/settings_repository.dart` — `SettingsRepository` class implementing: `getTarget()` returning daily_target_ml (default 2000); `setTarget(int dailyTargetMl)` with validation (250-10000)

**Checkpoint**: All three repositories compile. Methods return correct types.

---

## Phase 3: Riverpod Providers

**Purpose**: Wire repositories and reactive data to the UI via Riverpod providers.

- [x] T008 [US5] Create `lib/providers/repository_providers.dart` — Riverpod providers (keepAlive: true) for `WaterEntryRepository`, `WaterStatsRepository`, and `SettingsRepository`, each depending on `appDatabaseProvider`
- [x] T009 [P] [US5] Create `lib/providers/water_providers.dart` — Riverpod providers: `todayTotalProvider` (async, watches waterStatsRepository), `todayEntriesProvider` (async, watches waterEntryRepository with today's date), `streaksProvider` (async, watches both waterStatsRepository and settingsRepository)
- [x] T010 [P] [US5] Create `lib/providers/settings_providers.dart` — Riverpod provider: `dailyTargetProvider` (async, watches settingsRepository)
- [x] T011 Run `dart run build_runner build` to generate `.g.dart` files for all providers

**Checkpoint**: All providers compile. `flutter analyze` passes.

---

## Phase 4: Repository Tests

**Purpose**: Unit tests for all repository methods verifying correct behaviour and edge cases.

> **NOTE: These tests validate the core data layer — they MUST all pass before screen work.**

- [x] T012 [US5] Write test `test/repositories/water_entry_repository_test.dart` — tests: add() creates entry with correct fields, add() derives entryDate from entryTs, add() uses DateTime.now() when entryTs omitted, add() throws for amountMl < 1, add() throws for amountMl > 5000, listByDate() returns entries newest-first, listByDate() returns empty list for no data, delete() removes entry and returns true, delete() returns false for non-existent id
- [x] T013 [P] [US5] Write test `test/repositories/water_stats_repository_test.dart` — tests: getTodayTotal() returns 0 with no entries, getTodayTotal() sums correctly, getDailyTotals() returns correct range, getDailyTotals() excludes outside range, getWeeklySummary() returns 7-day window, getMonthlyTotals() returns correct month, getStreaks() returns (0,0) for no data, getStreaks() calculates current streak, getStreaks() detects broken streak, getStreaks() tracks longest streak
- [x] T014 [P] [US5] Write test `test/repositories/settings_repository_test.dart` — tests: getTarget() returns 2000 default, setTarget() updates and persists, setTarget() throws for value below 250, setTarget() throws for value above 10000, setTarget() accepts boundary values 250 and 10000
- [x] T015 [US4] Write test `test/db/app_database_test.dart` — tests: initialises in-memory without errors, schemaVersion is 2, water_entries table accepts valid data, user_settings table accepts valid data, default settings row is seeded with id=1
- [x] T016 Run `flutter test test/repositories/ test/db/` — verify all repository and database tests pass

**Checkpoint**: All 23+ repository and database tests pass.

---

## Phase 5: User Story 1 — Log Water via Quick-Add (Priority: P1) 🎯 MVP

**Goal**: Home screen shows live progress and allows quick-add logging with immediate UI updates.

**Independent Test**: Tap 250ml → progress shows 250/2000. Tap 500ml → progress shows 750/2000.

### Implementation for User Story 1

- [x] T017 [US1] Update `lib/screens/home_screen.dart` — replace placeholder with `ConsumerWidget` implementation: progress Card showing "{total} / {target} ml" from `todayTotalProvider` and `dailyTargetProvider`, colour changes to green when target met; Quick Add section with three `_QuickAddButton` widgets (250/500/750ml) using `FilledButton`; streak display Card with current and longest from `streaksProvider`; `_addWater()` method that calls `waterEntryRepositoryProvider.add()` then invalidates todayTotal, todayEntries, and streaks providers
- [x] T018 [US1] Update `test/app_test.dart` and `test/router/app_router_test.dart` to accommodate screen changes (if needed)

**Checkpoint**: Quick-add buttons work. Progress updates immediately. Streaks display.

---

## Phase 6: User Story 2 — View Today's Entries (Priority: P1)

**Goal**: Daily screen shows today's total and entry list with amounts and timestamps.

**Independent Test**: Log entries, navigate to Daily, verify list shows entries newest-first.

### Implementation for User Story 2

- [x] T019 [US2] Update `lib/screens/daily_screen.dart` — replace placeholder with `ConsumerWidget` implementation: "Today: {total} ml" header from `todayTotalProvider`, `ListView.builder` from `todayEntriesProvider` showing entries with water_drop icon, amount text, and time (HH:mm) from entryTs; empty state "No entries yet today" when list is empty

**Checkpoint**: Daily screen shows today's entries correctly. Empty state works.

---

## Phase 7: User Story 6 — Screen Shells for Weekly, Monthly, Settings (Priority: P2)

**Goal**: Remaining screens render shells with correct titles and basic state wiring.

### Implementation for User Story 6

- [x] T020 [P] [US6] Update `lib/screens/weekly_screen.dart` — replace placeholder text, add Card with 250px height placeholder: "Weekly bar chart coming in D4"
- [x] T021 [P] [US6] Update `lib/screens/monthly_screen.dart` — replace placeholder text, add Card with 300px height placeholder: "Monthly heatmap coming in D4"
- [x] T022 [P] [US6] Update `lib/screens/settings_screen.dart` — replace placeholder with `ConsumerWidget` watching `dailyTargetProvider`, show ListTile with flag icon, "Daily Target" title, "{target} ml" subtitle, chevron trailing icon

**Checkpoint**: All screens render without errors. Settings shows current target value.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, cleanup, and verification.

- [x] T023 Remove `lib/repositories/.gitkeep` — no longer needed now that repository files exist
- [x] T024 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T025 Run `flutter analyze` — zero errors
- [x] T026 Run `flutter test` — all tests green
- [x] T027 Verify end-to-end: quick-add on Home → progress updates → Daily shows entries → restart preserves data

---

## Dependencies & Execution Order

### Phase Dependencies

- **Database Schema (Phase 1)**: No dependencies beyond D0 — start immediately — BLOCKS all repositories
- **Repository Layer (Phase 2)**: Depends on Phase 1 (needs tables) — BLOCKS providers and tests
- **Riverpod Providers (Phase 3)**: Depends on Phase 2 (needs repositories) — BLOCKS screen implementation
- **Repository Tests (Phase 4)**: Depends on Phase 2 (needs repositories to test). Can run in parallel with Phase 3.
- **US1 Home Screen (Phase 5)**: Depends on Phase 3 (needs providers for state)
- **US2 Daily Screen (Phase 6)**: Depends on Phase 3 (needs providers for state). Can run in parallel with Phase 5.
- **US6 Shell Screens (Phase 7)**: Depends on Phase 3 (settings provider). Can run in parallel with Phase 5/6.
- **Polish (Phase 8)**: Depends on all phases complete

### Within Each Phase

- Database tables before migration update
- Repositories before providers
- Providers before screen wiring
- Tests validate core layer before UI work

### Parallel Opportunities

- T001 and T002 can run in parallel (different table files)
- T005, T006, T007 can run in parallel (different repository files)
- T009 and T010 can run in parallel (different provider files)
- T012, T013, T014 can run in parallel (different test files)
- T020, T021, T022 can run in parallel (different screen files)

---

## Implementation Strategy

### Recommended: Bottom-Up by Layer

1. Complete Phase 1: Database Schema → Tables and migration ready
2. Complete Phase 2: Repository Layer → Data access methods ready
3. Complete Phases 3 & 4 in parallel: Providers + Tests → State management wired, data layer verified
4. Complete Phases 5, 6, 7 in parallel: All screens → UI connected to live data
5. Complete Phase 8: Polish → Clean, formatted, all tests green

### Commit Strategy

- Single commit after all phases complete ("D1 implemented")

---

## Notes

- [P] tasks = different files, no dependencies — can be launched in parallel
- [Story] label maps task to specific user story for traceability
- Schema migration from v1→v2 uses `m.createAll()` which is safe for new tables
- `beforeOpen` seeds default settings using `INSERT OR IGNORE` to avoid duplicates on subsequent launches
- Repository validation (amountMl, dailyTargetMl) is done in Dart before hitting the database, providing better error messages than SQL CHECK failures
- Riverpod providers use `@riverpod` annotation with code generation (`riverpod_annotation` + `build_runner`)
- Custom amount input (bottom sheet) is explicitly deferred to D2 per the PRD deliverables plan
- Entry deletion UI is explicitly deferred to D3 per the PRD deliverables plan
