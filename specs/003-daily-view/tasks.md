# Tasks: Daily View + Delete Flow (D3)

**Input**: Design documents from `/specs/003-daily-view/`
**Prerequisites**: spec.md (required), D1/D2 providers and repositories complete

**Tests**: Included — the feature specification requires widget tests for ProgressBar and integration tests for DailyScreen (SC-001 through SC-008). Tests are written alongside implementation.

**Organization**: Tasks are grouped by phase. Phase 1 creates the ProgressBar widget. Phase 2 tests it. Phase 3 rewrites DailyScreen. Phase 4 tests DailyScreen. Phase 5 handles polish and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths included in descriptions

---

## Phase 1: ProgressBar Widget

**Purpose**: Create the linear progress bar widget used by DailyScreen.

- [x] T001 [US1] Create `lib/widgets/progress_bar.dart` — `ProgressBar` StatelessWidget with parameters: `consumed` (int), `target` (int). Full-width bar (20px height, 12px border radius). Background: `AppColors.bgSurfaceHover`. Fill: `FractionallySizedBox` clamped 0.0–1.0, `AppColors.primary` (switches to `AppColors.success` when consumed >= target). Label below: "{consumed} / {target} ml" in `bodySmall` + `textSecondary`. Semantics label for accessibility.

**Checkpoint**: Widget compiles. `flutter analyze` passes.

---

## Phase 2: ProgressBar Tests

**Purpose**: Test ProgressBar widget in isolation.

- [x] T002 [US1] Create `test/widgets/progress_bar_test.dart` — 5 tests: shows "0 / 2000 ml" when consumed=0; shows "500 / 2000 ml" for partial fill; shows success colour when target met; clamps fill when exceeded (shows "2500 / 2000 ml"); has correct Semantics label.

**Checkpoint**: `flutter test test/widgets/progress_bar_test.dart` — all green.

---

## Phase 3: DailyScreen Rewrite (depends on Phase 1)

**Purpose**: Rewrite DailyScreen with progress bar, formatted entries, delete flow, and empty state.

- [x] T003 [US1-4] Rewrite `lib/screens/daily_screen.dart` — Add watches for `dailyTargetProvider` and `waterEntryRepositoryProvider`. Layout: header "Today: {total} ml", `ProgressBar(consumed: total, target: target)`, entry list with "{amount}ml at HH:mm" format and `onTap` → `_showDeleteConfirmation()`, trailing chevron icon. Empty state: water drop icon (64px, muted), "No entries yet today" heading, "Log water from the Home tab to start tracking!" prompt. Delete flow: `AlertDialog` with "Delete Entry?" title, "Remove {amount}ml logged at {time}?" content, Cancel/Delete (red) buttons. On confirm: `repo.delete(id)` → invalidate `todayTotal`, `todayEntries`, `streaks`.

**Checkpoint**: DailyScreen compiles and renders correctly.

---

## Phase 4: DailyScreen Tests (depends on Phase 3)

**Purpose**: Integration test DailyScreen with in-memory database.

- [x] T004 [US1-4] Create `test/screens/daily_screen_test.dart` — 10 tests using in-memory DB + ProviderScope overrides: shows progress bar at 0% on fresh start; shows today total header; shows progress bar filled for logged entries; lists entries newest-first with "{amount}ml at HH:mm" format; shows empty state when no entries; hides empty state when entries exist; tapping entry shows delete confirmation dialog; cancel dismisses dialog without deleting; confirming delete removes entry and updates total; deleting last entry shows empty state.

**Checkpoint**: `flutter test test/screens/daily_screen_test.dart` — all green.

---

## Phase 5: Polish & Verification

**Purpose**: Final formatting, static analysis, and full regression test.

- [x] T005 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T006 Run `flutter analyze` — zero new errors
- [x] T007 Run `flutter test` — all tests green (D0/D1/D2/D3)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** (T001): No dependencies — start immediately
- **Phase 2** (T002): Can run alongside Phase 1
- **Phase 3** (T003): Depends on Phase 1 (DailyScreen imports ProgressBar)
- **Phase 4** (T004): Depends on Phase 3 (tests reference rewritten DailyScreen)
- **Phase 5** (T005–T007): Depends on all phases complete

### Parallel Opportunities

- T001 and T002 can run in parallel (different files)
- T005, T006, T007 are sequential (format → analyze → test)

---

## Implementation Strategy

### Recommended: Sequential by Phase

1. Phase 1: Create ProgressBar widget → compile check
2. Phase 2: Create ProgressBar tests → widget tests green
3. Phase 3: Rewrite DailyScreen → compile check
4. Phase 4: Create DailyScreen tests → integration tests green
5. Phase 5: Format → analyze → full test suite green

### Commit Strategy

- Single commit after all phases complete (D3 is a cohesive change)

---

## Notes

- No new providers, database tables, or dependencies needed for D3
- Linear ProgressBar differentiates from Home screen's circular ProgressRing
- Delete flow uses AlertDialog (distinct from bottom sheets used for input)
- Provider invalidation pattern matches HomeScreen._addWater() exactly
