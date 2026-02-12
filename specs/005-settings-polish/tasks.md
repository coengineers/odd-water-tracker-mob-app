# Tasks: Settings + Polish, QA, Release Readiness (D5)

**Input**: Design documents from `/specs/005-settings-polish/`
**Prerequisites**: spec.md (required), D0–D4 complete

**Tests**: Included — widget tests for EditTargetSheet, screen tests for SettingsScreen, integration tests covering 5 core flows (SC-004 through SC-007). Tests are written alongside implementation.

**Organization**: Tasks are grouped by phase. Phase 1 adds the Settings feature. Phase 2 adds debug tooling. Phase 3 writes all tests. Phase 4 adds accessibility semantics. Phase 5 creates release documentation. Phase 6 handles final polish and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths included in descriptions

---

## Phase 1: Settings Feature

**Purpose**: Implement edit daily target, reset all data, and rewrite settings screen.

- [x] T01 [P] [US1] Create `lib/widgets/edit_target_sheet.dart` — `EditTargetSheet` StatefulWidget following `CustomAmountSheet` pattern. Static `show()` method accepting `currentTarget`. Pre-populates TextEditingController. Validates 250–10000 ml. Button text "Save". Semantics label "Edit daily target sheet".
- [x] T02 [P] [US2] Modify `lib/repositories/settings_repository.dart` — add `resetAllData()` method that deletes all water entries and resets target to 2000.
- [x] T03 [US1-2] Rewrite `lib/screens/settings_screen.dart` — Daily Target ListTile (opens EditTargetSheet, saves via settingsRepository, invalidates dailyTarget + streaks). Reset All Data ListTile (red, confirmation dialog, resetAllData(), invalidate all 6 providers, SnackBar, pop home). About ListTile. Seed Sample Data ListTile (kDebugMode guard).

**Checkpoint**: Settings screen compiles. `flutter analyze` passes.

---

## Phase 2: Seed/Debug Tool

**Purpose**: Add debug seed data function for testing charts and streaks.

- [x] T04 [US4] Create `lib/debug/seed_data.dart` — `seedSampleData(AppDatabase)` function guarded by `kDebugMode`. Generates 2–5 entries per day for 30 days. Amounts 150–800ml randomized. Skips ~4 random days for gap testing. Uses uuid for entry IDs.

**Checkpoint**: Seed function compiles. Called from SettingsScreen.

---

## Phase 3: Tests

**Purpose**: Widget tests, screen tests, and integration tests.

### Widget tests

- [x] T05 [P] [US1] Create `test/widgets/edit_target_sheet_test.dart` — 9 tests following `custom_amount_sheet_test.dart` pattern: title, pre-populated value, Save button, empty error, below-250 error, above-10000 error, valid input returns value, boundary 250 accepted, boundary 10000 accepted.

### Screen tests

- [x] T06 [P] [US1-2] Create `test/screens/settings_screen_test.dart` — 8 tests following `home_screen_test.dart` pattern (in-memory DB + ProviderScope override): shows current target, opens edit sheet, pre-populated value, saving updates display, About section, Reset option, confirmation dialog, reset clears data.

### Integration tests

- [x] T07 Modify `pubspec.yaml` — add `integration_test: sdk: flutter` to dev_dependencies.
- [x] T08 [P] Create `integration_test/quick_add_test.dart` — Launch app, tap Glass (250ml), verify progress. Tap Bottle (500ml), verify cumulative (750ml). Navigate Daily, verify entries.
- [x] T09 [P] Create `integration_test/custom_add_test.dart` — Tap Custom, try empty submit (error), enter 330ml, submit. Verify progress.
- [x] T10 [P] Create `integration_test/delete_entry_test.dart` — Add entry, navigate Daily, tap entry, cancel delete. Tap entry again, confirm delete, verify removal.
- [x] T11 [P] Create `integration_test/charts_render_test.dart` — Seed multi-day entries. Navigate Weekly (BarChart renders). Navigate Monthly (CalendarHeatmap renders).
- [x] T12 [P] Create `integration_test/change_target_test.dart` — Seed 1500ml, change target to 1500. Verify 100% progress and streak update.

**Checkpoint**: `flutter test` — all tests green.

---

## Phase 4: Accessibility Polish

**Purpose**: Add Semantics labels to widgets missing them.

- [x] T13 [P] [US3] Modify `lib/widgets/progress_ring.dart` — wrap in `Semantics(label: '$percentage% of daily target, $consumed of $target ml')`.
- [x] T14 [P] [US3] Modify `lib/widgets/quick_add_button.dart` — add `Semantics(button: true, label: 'Add $label ${amountMl ?? ""} ml')`.
- [x] T15 [P] [US3] Modify `lib/widgets/streak_card.dart` — add `Semantics(label: 'Current streak $current days, Longest streak $longest days')`.
- [x] T16 [P] [US3] Modify `lib/widgets/custom_amount_sheet.dart` — add `Semantics(label: 'Custom amount entry sheet')`.

**Checkpoint**: All Semantics labels in place. `flutter analyze` passes.

---

## Phase 5: Release Documentation

**Purpose**: Create spec and release checklist documents.

- [x] T17 [P] Create `specs/005-settings-polish/spec.md` — feature specification with user stories, acceptance scenarios, requirements, success criteria.
- [x] T18 [P] Create `specs/005-settings-polish/tasks.md` — task list with phases, checkboxes, parallel markers, file paths.
- [x] T19 [P] Create `specs/005-settings-polish/RELEASE_CHECKLIST.md` — checklist and known limitations.

**Checkpoint**: Documentation complete.

---

## Phase 6: Polish & Verification

**Purpose**: Final formatting, static analysis, and full test suite.

- [x] T20 Run `dart format lib/ test/ integration_test/`
- [x] T21 Run `flutter analyze` — zero issues
- [x] T22 Run `flutter test` — all tests green
- [x] T23 Run `flutter test integration_test/` — all integration tests green

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** (T01–T03): No dependencies — start immediately
- **Phase 2** (T04): Depends on Phase 1 (settings_screen imports seed_data)
- **Phase 3** (T05–T12): Depends on Phase 1 and 2 (tests reference implementations)
- **Phase 4** (T13–T16): No dependencies — can run in parallel with Phase 1
- **Phase 5** (T17–T19): No dependencies — can run in parallel
- **Phase 6** (T20–T23): Depends on all phases complete

### Parallel Opportunities

- T01 and T02 can run in parallel (different files)
- T05, T06, T08–T12 can run in parallel (different test files)
- T13, T14, T15, T16 can run in parallel (different widget files)
- T17, T18, T19 can run in parallel (different spec files)

---

## Files Summary

| Action | File |
|--------|------|
| Create | `lib/widgets/edit_target_sheet.dart` |
| Create | `lib/debug/seed_data.dart` |
| Create | `test/widgets/edit_target_sheet_test.dart` |
| Create | `test/screens/settings_screen_test.dart` |
| Create | `integration_test/quick_add_test.dart` |
| Create | `integration_test/custom_add_test.dart` |
| Create | `integration_test/delete_entry_test.dart` |
| Create | `integration_test/charts_render_test.dart` |
| Create | `integration_test/change_target_test.dart` |
| Create | `specs/005-settings-polish/spec.md` |
| Create | `specs/005-settings-polish/tasks.md` |
| Create | `specs/005-settings-polish/RELEASE_CHECKLIST.md` |
| Modify | `lib/screens/settings_screen.dart` |
| Modify | `lib/repositories/settings_repository.dart` |
| Modify | `lib/widgets/progress_ring.dart` |
| Modify | `lib/widgets/quick_add_button.dart` |
| Modify | `lib/widgets/streak_card.dart` |
| Modify | `lib/widgets/custom_amount_sheet.dart` |
| Modify | `pubspec.yaml` |

---

## Notes

- EditTargetSheet follows CustomAmountSheet pattern exactly (same structure, different validation range and button text)
- Settings screen uses `_invalidateAll()` helper to invalidate all 6 data providers consistently
- Seed data generates randomized but realistic patterns: 2–5 entries per day, 150–800ml, ~4 skipped days
- Integration tests use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` + in-memory DB via ProviderScope override
- All Semantics labels follow existing patterns from screens (daily_screen, weekly_screen, monthly_screen)
