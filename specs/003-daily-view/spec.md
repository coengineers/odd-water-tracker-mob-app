# Feature Specification: Daily View + Delete Flow (D3)

**Feature Branch**: `003-daily-view`
**Created**: 2026-02-12
**Status**: Implemented
**Input**: PRD Section 10 — D3: "Give users insight into today's entries and ability to correct mistakes." Covers FR-006, FR-007, FR-011.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See Today's Progress at a Glance (Priority: P1)

A user navigates to the Daily tab and immediately sees a linear
progress bar showing how much water they have consumed today
relative to their target. The bar fills proportionally and changes
colour from orange to green when the target is met.

**Why this priority**: The progress bar is the visual anchor of the
Daily screen — it communicates hydration status instantly without
requiring the user to read numbers.

**Independent Test**: Navigate to Daily tab on a fresh database.
The progress bar shows 0 / 2000 ml. Log 500ml from Home tab,
return to Daily — bar shows 500 / 2000 ml. Log enough to meet
target — bar turns green.

**Acceptance Scenarios**:

1. **Given** a fresh database with no entries,
   **When** the user navigates to the Daily tab,
   **Then** the progress bar shows "0 / 2000 ml" with zero fill.

2. **Given** the user has logged 500ml today against a 2000ml target,
   **When** the user views the Daily screen,
   **Then** the progress bar shows "500 / 2000 ml" with 25% fill.

3. **Given** the user has met or exceeded their target,
   **When** the progress bar renders,
   **Then** the fill colour changes from primary (orange) to success (green),
   and the bar is clamped to full width while the label shows the actual values.

---

### User Story 2 - View Today's Entries (Priority: P1)

The user sees a list of all water entries logged today, formatted
as "{amount}ml at HH:mm", with the newest entry at the top. Each
entry has a chevron icon as a tap affordance.

**Why this priority**: Viewing logged entries is core to the Daily
screen's purpose. Without it, users cannot review what they've
logged.

**Independent Test**: Log 250ml and 500ml from Home, switch to
Daily tab — see two entries in newest-first order, each showing
"{amount}ml at HH:mm".

**Acceptance Scenarios**:

1. **Given** the user has logged entries today,
   **When** the Daily screen loads,
   **Then** entries are listed newest-first with format "{amount}ml at HH:mm".

2. **Given** entries exist,
   **When** the user views the entry list,
   **Then** each entry has a water drop icon, formatted text, and trailing chevron.

---

### User Story 3 - Delete an Entry (Priority: P1)

The user taps an entry to see a delete confirmation dialog. The
dialog shows the entry details and offers Cancel/Delete actions.
Confirming deletes the entry and updates the total and progress bar.

**Why this priority**: Users must be able to correct mistakes
(FR-007). Without delete, accidental entries permanently inflate
the daily total.

**Independent Test**: Log 300ml, tap the entry on Daily tab, see
"Delete Entry?" dialog with "Remove 300ml logged at HH:mm?". Tap
Cancel — nothing changes. Tap Delete — entry removed, total updated.

**Acceptance Scenarios**:

1. **Given** an entry exists on the Daily screen,
   **When** the user taps the entry,
   **Then** an AlertDialog shows "Delete Entry?" with content
   "Remove {amount}ml logged at {time}?".

2. **Given** the delete dialog is shown,
   **When** the user taps "Cancel",
   **Then** the dialog dismisses and the entry remains.

3. **Given** the delete dialog is shown,
   **When** the user taps "Delete",
   **Then** the entry is removed from the database, the list updates,
   and the total/progress bar reflect the new value.

4. **Given** only one entry exists,
   **When** the user deletes it,
   **Then** the empty state appears.

---

### User Story 4 - Empty State (Priority: P2)

When no water has been logged today, the Daily screen shows a
water drop icon, "No entries yet today" heading, and a prompt
to log water from the Home tab.

**Why this priority**: Empty states (FR-011) improve UX but are
not blocking for core functionality.

**Independent Test**: Open Daily tab on fresh database — see water
drop icon, "No entries yet today", and "Log water from the Home
tab to start tracking!". Log water, return — empty state gone.

**Acceptance Scenarios**:

1. **Given** zero entries for today,
   **When** the Daily screen loads,
   **Then** a water drop icon (64px, muted), "No entries yet today",
   and "Log water from the Home tab to start tracking!" are shown.

2. **Given** the user has logged at least one entry today,
   **When** the Daily screen loads,
   **Then** the empty state is not shown.

---

### Edge Cases

- What happens when consumed exceeds target? The progress bar fill
  is clamped to 100% width, but the label shows actual values
  (e.g. "2500 / 2000 ml"). Colour changes to success green.
- What happens when the user deletes the last entry? The empty state
  appears and the total resets to 0.
- What happens with rapid successive deletes? Each delete invalidates
  providers, so the list re-renders after each deletion.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-006**: Daily screen MUST show a progress bar towards the daily
  target and list all entries formatted as "{amount}ml at HH:mm".
- **FR-007**: App MUST allow deleting individual entries with a
  confirmation dialog.
- **FR-011**: App MUST provide empty state for Daily screen when no
  entries exist for today.

### Key Entities

- **ProgressBar**: Linear progress indicator showing consumed/target
  with colour transition at target. Full-width, 20px height, 12px
  border radius.
- **DailyScreen**: ConsumerWidget showing header, progress bar, and
  entry list with delete capability.
- **Delete Confirmation**: AlertDialog with Cancel/Delete actions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Progress bar shows correct fill (0%, partial, 100%,
  clamped >100%) for all consumed/target combinations.
- **SC-002**: Entry list displays entries in newest-first order with
  "{amount}ml at HH:mm" format.
- **SC-003**: Tapping an entry shows delete confirmation with correct
  entry details.
- **SC-004**: Cancelling delete dismisses dialog without data changes.
- **SC-005**: Confirming delete removes entry and updates total/progress.
- **SC-006**: Empty state appears when no entries exist and disappears
  when entries are added.
- **SC-007**: `flutter analyze` produces zero new issues.
- **SC-008**: `flutter test` — all tests green (D0/D1/D2/D3).

## Assumptions

- D1/D2 providers (`todayTotalProvider`, `todayEntriesProvider`,
  `dailyTargetProvider`, `streaksProvider`) and repositories are
  complete.
- `WaterEntryRepository.delete(String id)` exists and works correctly.
- No new Riverpod providers or database changes are needed for D3.
- The daily target defaults to 2000 ml (seeded in the database).
- Provider invalidation after delete matches the `_addWater()` pattern
  from HomeScreen.
