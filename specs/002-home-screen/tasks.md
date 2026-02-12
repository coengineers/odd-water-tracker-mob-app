# Tasks: Home Screen + Fast Logging UX (D2)

**Input**: Design documents from `/specs/002-home-screen/`
**Prerequisites**: spec.md (required), D1 providers and repositories complete

**Tests**: Included — the feature specification requires widget tests for each new widget and integration tests for the HomeScreen (SC-001 through SC-007). Tests are written alongside implementation.

**Organization**: Tasks are grouped by phase. Phase 1 widgets are independent and parallelizable. Phase 2 tests correspond 1:1 with Phase 1 widgets. Phase 3 integrates everything into the HomeScreen.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths included in descriptions

---

## Phase 1: New Widgets (all independent, parallelizable)

**Purpose**: Create the four extracted widgets that compose the new HomeScreen.

- [x] T001 [P] [US1] Create `lib/widgets/progress_ring.dart` — `ProgressRing` widget using `CustomPainter` with parameters: `consumed` (int), `target` (int), `size` (double, default 200), `strokeWidth` (double, default 12). Background arc uses `AppColors.bgSurfaceHover`, progress arc uses `AppColors.primary` (switches to `AppColors.success` when consumed >= target), `StrokeCap.round`. Arc starts at 12 o'clock (-pi/2), progress clamped to 1.0 for the arc. Centred text: percentage in `headlineMedium`, consumed/target in `bodySmall` + `textSecondary`.
- [x] T002 [P] [US2] Create `lib/widgets/quick_add_button.dart` — `QuickAddButton` widget with parameters: `label` (String), `icon` (IconData), `onPressed` (VoidCallback), `amountMl` (int?, optional). Column layout: icon, label, amount ("250 ml") — amount omitted when null. Styled with `AppColors.bgSurface` background, `AppSpacing.radiusLg` radius, 76px width.
- [x] T003 [P] [US3] Create `lib/widgets/custom_amount_sheet.dart` — `CustomAmountSheet` StatefulWidget with static `show(BuildContext)` returning `Future<int?>`. Uses `showModalBottomSheet` with `isScrollControlled: true`, keyboard-aware padding. Drag handle + "Custom Amount" title + `TextField` (digits only, "ml" suffix, "Enter amount" hint) + "Add" button. Inline validation: empty → "Please enter an amount", <1 → "Amount must be at least 1 ml", >5000 → "Amount must be at most 5,000 ml". Valid → `Navigator.pop(context, amount)`.
- [x] T004 [P] [US4] Create `lib/widgets/streak_card.dart` — `StreakCard` widget with parameters: `current` (int), `longest` (int). Card with Row: two columns showing value in `headlineSmall` + `AppColors.primary` and label in `bodySmall`. Extracted from existing inline streak code in HomeScreen.

**Checkpoint**: Four new widget files compile. `flutter analyze` passes. No HomeScreen changes yet.

---

## Phase 2: Widget Tests (parallelizable, can run alongside Phase 1)

**Purpose**: Test each widget in isolation.

- [x] T005 [P] [US1] Create `test/widgets/progress_ring_test.dart` — 5 tests: shows "0%" when consumed=0/target=2000; shows "25%" for 500/2000; shows "100%" when target met; shows ">100%" percentage when exceeded (arc clamped); displays "X / Y ml" text.
- [x] T006 [P] [US2] Create `test/widgets/quick_add_button_test.dart` — 3 tests: renders label, icon, and amount text; calls onPressed when tapped; omits amount text when amountMl is null.
- [x] T007 [P] [US3] Create `test/widgets/custom_amount_sheet_test.dart` — 7 tests: shows title/text field/Add button; empty input → error; amount 0 → error; amount >5000 → error; valid amount (350) → dismisses and returns value; boundary 1 valid; boundary 5000 valid.
- [x] T008 [P] [US4] Create `test/widgets/streak_card_test.dart` — 2 tests: renders current and longest streak values; shows 0 for both when no streaks.

**Checkpoint**: `flutter test test/widgets/` — all widget tests green.

---

## Phase 3: HomeScreen Integration (depends on Phase 1)

**Purpose**: Rewrite the HomeScreen to compose the new widgets and add empty state + Custom button logic.

- [x] T009 [US1-5] Rewrite `lib/screens/home_screen.dart` — Replace body with `SingleChildScrollView` containing: `ProgressRing` (from todayTotal + dailyTarget providers), "Daily Target: X ml" label, empty state text when todayTotal == 0, `Wrap` of 4 `QuickAddButton`s (Glass 250/Bottle 500/Large 750/Custom), `StreakCard` (from streaks provider). Custom button calls `CustomAmountSheet.show()` and passes result to `_addWater`. Remove old `_QuickAddButton` private class, old text-based progress Card, and old inline streak display.
- [x] T010 [US1-5] Create `test/screens/home_screen_test.dart` — 9 integration tests using in-memory DB + ProviderScope overrides: shows progress ring at 0% on fresh start; shows daily target text; displays four quick-add buttons; tapping Glass updates progress; tapping Custom opens bottom sheet; entering valid custom amount updates progress; shows empty state prompt; hides empty state after first entry; shows streak counters.

**Checkpoint**: `flutter test` — all tests green including new HomeScreen tests and existing D0/D1 tests.

---

## Phase 4: Polish & Verification

**Purpose**: Final formatting, static analysis, and full regression test.

- [x] T011 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T012 Run `flutter analyze` — zero new errors (only pre-existing info-level issues from D0/D1)
- [x] T013 Run `flutter test` — all 65 tests green

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** (T001–T004): No dependencies — start immediately, all parallel
- **Phase 2** (T005–T008): Can run alongside Phase 1 (test files reference widget files)
- **Phase 3** (T009–T010): Depends on Phase 1 (HomeScreen imports new widgets)
- **Phase 4** (T011–T013): Depends on all phases complete

### Parallel Opportunities

- T001, T002, T003, T004 can all run in parallel (different files, no dependencies)
- T005, T006, T007, T008 can all run in parallel (different test files)
- T009 and T010 are sequential (rewrite HomeScreen, then write its tests)

---

## Implementation Strategy

### Recommended: Parallel by Phase

1. Complete Phase 1: All 4 widgets in parallel → compile check
2. Complete Phase 2: All 4 test files in parallel → widget tests green
3. Complete Phase 3: Rewrite HomeScreen → integration tests green
4. Complete Phase 4: Format → analyze → full test suite green

### Commit Strategy

- Single commit after all phases complete (D2 is a cohesive change)

---

## Notes

- [P] tasks = different files, no dependencies — can be launched in parallel
- [Story] label maps task to specific user story for traceability
- No new providers, database tables, or dependencies were needed for D2
- Pre-existing `info`-level analyzer issues in `lib/db/tables/` (recursive_getters) are from D0/D1 and not addressed in D2
- The `_addWater` method is unchanged from D1 (calls repo.add, invalidates providers)
