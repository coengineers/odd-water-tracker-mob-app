# Feature Specification: Settings + Polish, QA, Release Readiness (D5)

**Feature Branch**: `005-settings-polish`
**Created**: 2026-02-12
**Status**: Implemented
**Input**: PRD Section 10 — D5: "Settings, polish, QA, release readiness." Covers FR-012, NFRs (accessibility, performance), integration tests, seed tools, release checklist.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Edit Daily Target (Priority: P1)

A user navigates to Settings and taps the Daily Target row. A bottom
sheet appears pre-populated with the current target. The user changes
the value and taps Save. The target updates across the entire app,
including Home progress ring, streak calculations, and chart
reference lines.

**Why this priority**: Editing the daily target (FR-012) is the only
remaining functional requirement. Without it the app has a hardcoded
2000ml target that cannot be personalized.

**Independent Test**: Navigate to Settings, verify 2000ml displayed.
Tap Daily Target, change to 3000ml, tap Save. Return to Home — ring
shows X / 3000 ml. Navigate to Weekly — reference line at 3000.

**Acceptance Scenarios**:

1. **Given** the current target is 2000 ml,
   **When** the user opens Settings,
   **Then** "Daily Target" shows "2000 ml" subtitle.

2. **Given** the user taps Daily Target,
   **When** the edit sheet opens,
   **Then** the text field is pre-populated with "2000".

3. **Given** the user enters 3000 and taps Save,
   **When** the sheet dismisses,
   **Then** the subtitle updates to "3000 ml" and all dependent
   providers (dailyTarget, streaks) are invalidated.

4. **Given** the user enters 200 (below 250),
   **When** they tap Save,
   **Then** an error message "Target must be at least 250 ml" appears
   and the sheet stays open.

5. **Given** the user enters 10001 (above 10000),
   **When** they tap Save,
   **Then** an error message "Target must be at most 10,000 ml" appears.

---

### User Story 2 - Reset All Data (Priority: P2)

A user taps "Reset All Data" in Settings. A confirmation dialog
appears. On confirm, all water entries are deleted, the target resets
to 2000ml, all providers refresh, and the user is navigated back to
Home with a SnackBar confirmation.

**Why this priority**: Data reset is a safety-net feature. It's less
critical than target editing but necessary for QA and user control.

**Independent Test**: Add several entries, navigate to Settings, tap
Reset All Data, confirm. Verify Home shows 0% and 0 / 2000 ml.

**Acceptance Scenarios**:

1. **Given** the user taps "Reset All Data",
   **When** the confirmation dialog appears,
   **Then** it shows "Reset All Data?" title with Cancel and Reset buttons.

2. **Given** the user taps "Cancel",
   **When** the dialog dismisses,
   **Then** no data is deleted.

3. **Given** the user taps "Reset",
   **When** the operation completes,
   **Then** all water entries are deleted, target resets to 2000ml,
   all providers are invalidated, a SnackBar shows "All data reset",
   and the user is navigated back to Home.

---

### User Story 3 - Accessibility (Priority: P2)

Screen reader users can navigate the app with meaningful labels on
all interactive and informational widgets.

**Why this priority**: Accessibility is an NFR required for release
but doesn't block core functionality.

**Independent Test**: Enable TalkBack/VoiceOver. Navigate Home —
hear progress ring percentage, quick-add button labels, streak
values. Navigate to Custom Amount sheet — hear "Custom amount entry
sheet". Navigate to Edit Target sheet — hear "Edit daily target sheet".

**Acceptance Scenarios**:

1. **Given** VoiceOver is active,
   **When** the progress ring is focused,
   **Then** it announces "$percentage% of daily target, $consumed of $target ml".

2. **Given** VoiceOver is active,
   **When** a quick-add button is focused,
   **Then** it announces "Add $label $amount ml" with button trait.

3. **Given** VoiceOver is active,
   **When** the streak card is focused,
   **Then** it announces "Current streak $current days, Longest streak $longest days".

4. **Given** VoiceOver is active,
   **When** the custom amount sheet is focused,
   **Then** it announces "Custom amount entry sheet".

5. **Given** VoiceOver is active,
   **When** the edit target sheet is focused,
   **Then** it announces "Edit daily target sheet".

---

### User Story 4 - Seed Sample Data (Debug) (Priority: P3)

In debug builds, a developer can tap "Seed Sample Data" in Settings
to populate 30 days of randomized entries for testing charts, streaks,
and empty states.

**Why this priority**: Debug tooling supports development velocity
but is invisible to end users.

**Independent Test**: Open Settings in debug build. Tap "Seed Sample
Data". Navigate to Weekly and Monthly — charts populate. The seed
button should not appear in release builds.

---

### Edge Cases

- What happens when the target is changed mid-day? Streaks are
  recomputed retroactively with the new target for all historical days.
- What happens when Reset is tapped with no data? Still resets target
  to 2000ml (idempotent operation).
- What happens in release builds? The Seed Sample Data option is
  hidden via `kDebugMode` guard.
- What happens if the user dismisses the edit sheet without saving?
  No changes are made (null result from sheet).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-012**: Settings screen MUST allow editing the daily target
  (250–10000 ml) via a bottom sheet modal.
- **FR-013**: Settings screen MUST provide a Reset All Data option
  with destructive confirmation.
- **FR-014**: Settings screen MUST show an About section.

### Non-Functional Requirements

- **NFR-001**: All interactive widgets MUST have Semantics labels.
- **NFR-002**: `flutter analyze` MUST produce zero issues.
- **NFR-003**: All unit and widget tests MUST pass.
- **NFR-004**: Integration tests MUST cover core user flows.
- **NFR-005**: Debug-only tools MUST be hidden in release builds.

### Key Entities

- **EditTargetSheet**: Bottom sheet for editing daily target, following
  CustomAmountSheet pattern.
- **seedSampleData**: Debug function generating 30 days of randomized
  water entries.
- **SettingsRepository.resetAllData()**: Deletes all entries and resets
  target to 2000ml.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Editing target from 2000 to 3000 updates Home ring to
  "X / 3000 ml" and recomputes streaks.
- **SC-002**: Reset All Data clears entries, resets target, and shows
  confirmation SnackBar.
- **SC-003**: All 4 Semantics labels added (progress_ring,
  quick_add_button, streak_card, custom_amount_sheet).
- **SC-004**: EditTargetSheet validates 250–10000 ml range.
- **SC-005**: `flutter analyze` — zero issues.
- **SC-006**: `flutter test` — all tests green.
- **SC-007**: Integration tests cover: quick add, custom add, delete
  entry, chart rendering, target change flow.
- **SC-008**: Seed data visible only in debug builds.
- **SC-009**: Release checklist items all pass.

## Assumptions

- D0–D4 are complete with all providers, repositories, screens, and
  tests passing.
- `kDebugMode` from `package:flutter/foundation.dart` correctly
  evaluates to `false` in release builds.
- The existing `AppDatabase.forTesting(NativeDatabase.memory())`
  pattern works for integration tests.
- `integration_test` SDK package is compatible with the project's
  Flutter SDK constraint.
