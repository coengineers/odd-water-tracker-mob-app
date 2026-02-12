# Tasks: Weekly Summary + Monthly Patterns (D4)

**Input**: Design documents from `/specs/004-weekly-summary/`
**Prerequisites**: spec.md (required), D1/D2/D3 providers and repositories complete

**Tests**: Included — the feature specification requires widget tests for WeeklyBarChart, WeeklyStatsRow, and CalendarHeatmap, plus integration tests for WeeklyScreen and MonthlyScreen (SC-001 through SC-010). Tests are written alongside implementation.

**Organization**: Tasks are grouped by phase. Phase 1 adds Riverpod providers. Phase 2 creates presentation widgets. Phase 3 rewrites screen stubs. Phase 4 writes all tests. Phase 5 handles polish and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths included in descriptions

---

## Phase 1: Riverpod Providers

**Purpose**: Add data providers that WeeklyScreen and MonthlyScreen consume.

- [x] T001 [US1-3] Modify `lib/providers/water_providers.dart` — add `weeklySummary` provider: fetches `getWeeklySummary(today)` from `waterStatsRepositoryProvider`. Add `monthlyTotals` provider: fetches `getMonthlyTotals(now.year, now.month)` from `waterStatsRepositoryProvider`. Both annotated with `@riverpod`.
- [x] T002 [US1-3] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/providers/water_providers.g.dart` with `weeklySummaryProvider` and `monthlyTotalsProvider`.

**Checkpoint**: New providers compile. `flutter analyze` passes.

---

## Phase 2: Presentation Widgets

**Purpose**: Create the three reusable widgets used by WeeklyScreen and MonthlyScreen.

- [x] T003 [P] [US1] Create `lib/widgets/weekly_bar_chart.dart` — `WeeklyBarChart` StatelessWidget. Params: `Map<String, int> dailyTotals`, `int targetMl`. Uses fl_chart `BarChart` with 7 bars for last-7-days (ending today), 0 for missing dates. Bar colour: `AppColors.primary` (below target), `AppColors.success` (at/above). Horizontal dashed reference line at `targetMl` via `ExtraLinesData`. X-axis: abbreviated day names (Mon–Sun). Y-axis: auto-scaled ml (max = max(target, maxValue) × 1.15). `Semantics` label "Weekly water intake bar chart".
- [x] T004 [P] [US2] Create `lib/widgets/weekly_stats_row.dart` — `WeeklyStatsRow` StatelessWidget. Params: `Map<String, int> dailyTotals`, `int targetMl`. Computes average (sum ÷ 7, integer division) and days-hit count (where value ≥ targetMl, out of 7). Row with `spaceAround` alignment showing two `_Stat` column widgets with value (textPrimary) and label (textSecondary).
- [x] T005 [P] [US3-4] Create `lib/widgets/calendar_heatmap.dart` — `CalendarHeatmap` StatefulWidget (for tooltip state). Params: `Map<String, int> dailyTotals`, `int targetMl`, `int year`, `int month`. Day-of-week headers row (M T W T F S S). `GridView.count(crossAxisCount: 7)` with leading empty cells for month offset (Monday-based). Cell colour by intensity (5 levels of primary opacity, `bgSurfaceHover` for 0). Check icon for days at/above target. Tap day → show tooltip Card below grid; tap again → dismiss; tap different day → switch.

**Checkpoint**: All three widgets compile. `flutter analyze` passes.

---

## Phase 3: Screen Rewrites (depends on Phase 2)

**Purpose**: Replace stub content in WeeklyScreen and MonthlyScreen with real chart/heatmap UI.

- [x] T006 [P] [US1-2,5] Rewrite `lib/screens/weekly_screen.dart` — Watch `weeklySummaryProvider` + `dailyTargetProvider`. Use `.when()` pattern for async data. Data state: Card with `WeeklyBarChart` + Card with `WeeklyStatsRow`. Empty state (empty map): `Icons.bar_chart_outlined` (64px, muted) + "No data this week" + "Log water from the Home tab to start tracking!" (follows `daily_screen.dart` pattern). Loading/error states.
- [x] T007 [P] [US3-5] Rewrite `lib/screens/monthly_screen.dart` — Watch `monthlyTotalsProvider` + `dailyTargetProvider`. Month title: `DateFormat('MMMM yyyy')` from `intl` package. Data state: month title heading + Card with `CalendarHeatmap`, wrapped in `SingleChildScrollView` to prevent overflow. Empty state: `Icons.calendar_month_outlined` (64px, muted) + "No data this month" + "Log water from the Home tab to start tracking!". Loading/error states.

**Checkpoint**: Both screens compile and render correctly.

---

## Phase 4: Tests (depends on Phase 3)

**Purpose**: Widget tests (isolated, no DB) and screen integration tests (in-memory DB).

### Widget tests

- [x] T008 [P] [US1] Create `test/widgets/weekly_bar_chart_test.dart` — 6 tests: renders BarChart widget; renders 7 bars; has horizontal target line at correct Y value; bar uses success colour when at/above target; bar uses primary colour when below target; has Semantics label.
- [x] T009 [P] [US2] Create `test/widgets/weekly_stats_row_test.dart` — 3 tests: correct average calculation (sum ÷ 7); correct days-hit count; shows 0 average and 0/7 for empty data.
- [x] T010 [P] [US3-4] Create `test/widgets/calendar_heatmap_test.dart` — 7 tests: shows day-of-week headers; renders correct number of day cells; shows check icon for days at target; no check icon for days below target; tap day shows tooltip card; tap same day again dismisses tooltip; tap different day switches tooltip.

### Screen integration tests

- [x] T011 [P] [US1-2,5] Create `test/screens/weekly_screen_test.dart` — 3 tests using in-memory DB + ProviderScope overrides (follows `daily_screen_test.dart` pattern): empty state on fresh DB; bar chart renders with seeded data; stats row shows correct values (avg and days-hit).
- [x] T012 [P] [US3-5] Create `test/screens/monthly_screen_test.dart` — 4 tests using in-memory DB + ProviderScope overrides: empty state on fresh DB; heatmap renders with seeded data (check icon visible); month title displayed; tap day shows tooltip.

**Checkpoint**: `flutter test test/widgets/weekly_bar_chart_test.dart test/widgets/weekly_stats_row_test.dart test/widgets/calendar_heatmap_test.dart test/screens/weekly_screen_test.dart test/screens/monthly_screen_test.dart` — all green.

---

## Phase 5: Polish & Verification

**Purpose**: Final formatting, static analysis, and full regression test.

- [x] T013 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T014 Run `flutter analyze` — zero new issues
- [x] T015 Run `flutter test` — all 103 tests green (D0–D4)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** (T001–T002): No dependencies — start immediately
- **Phase 2** (T003–T005): Depends on Phase 1 (providers must exist for screen wiring, but widgets themselves are independent)
- **Phase 3** (T006–T007): Depends on Phase 2 (screens import widgets)
- **Phase 4** (T008–T012): Depends on Phase 3 (tests reference rewritten screens)
- **Phase 5** (T013–T015): Depends on all phases complete

### Parallel Opportunities

- T003, T004, T005 can run in parallel (different widget files)
- T006 and T007 can run in parallel (different screen files)
- T008, T009, T010, T011, T012 can run in parallel (different test files)

---

## Implementation Strategy

### Recommended: Sequential by Phase

1. Phase 1: Add providers → regenerate code → compile check
2. Phase 2: Create 3 widgets → compile check
3. Phase 3: Rewrite 2 screens → compile check
4. Phase 4: Write 5 test files → all green
5. Phase 5: Format → analyze → full test suite green

### Commit Strategy

- Single commit after all phases complete (D4 is a cohesive change)

---

## Files Summary

| Action     | File                                       |
|------------|--------------------------------------------|
| Modify     | `lib/providers/water_providers.dart`       |
| Regenerate | `lib/providers/water_providers.g.dart`     |
| Create     | `lib/widgets/weekly_bar_chart.dart`        |
| Create     | `lib/widgets/weekly_stats_row.dart`        |
| Create     | `lib/widgets/calendar_heatmap.dart`        |
| Modify     | `lib/screens/weekly_screen.dart`           |
| Modify     | `lib/screens/monthly_screen.dart`          |
| Create     | `test/widgets/weekly_bar_chart_test.dart`  |
| Create     | `test/widgets/weekly_stats_row_test.dart`  |
| Create     | `test/widgets/calendar_heatmap_test.dart`  |
| Create     | `test/screens/weekly_screen_test.dart`     |
| Create     | `test/screens/monthly_screen_test.dart`    |

---

## Notes

- Two new Riverpod providers added; no new database tables or dependencies
- `fl_chart` was already in pubspec.yaml but unused until D4
- `intl` package used for `DateFormat('MMMM yyyy')` in MonthlyScreen
- Calendar heatmap uses Monday-based week (ISO standard, `DateTime.weekday - 1`)
- MonthlyScreen wraps data content in `SingleChildScrollView` to handle months with 6 rows
- Weekly stats use integer division for average (truncates, not rounds)
- All 5 test files follow existing patterns from D3's `daily_screen_test.dart`
