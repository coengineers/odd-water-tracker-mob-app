# Feature Specification: Home Screen + Fast Logging UX (D2)

**Feature Branch**: `002-home-screen`
**Created**: 2026-02-12
**Status**: Implemented
**Input**: PRD Section 10 — D2: "Make logging feel instant and motivating." Covers FR-002, FR-004, FR-005, FR-010, FR-011, partial FR-012.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See Daily Progress at a Glance (Priority: P1)

A user opens the app and immediately sees a circular progress ring
showing how much water they have consumed today relative to their
target. The percentage is prominent, and consumed/target amounts
are shown below it. A "Daily Target" label confirms the goal.

**Why this priority**: The progress ring is the centrepiece of the
Home screen — it provides instant feedback on whether the user is
on track. Without it, the screen has no visual anchor.

**Independent Test**: Launch the app with a fresh database. The
progress ring shows 0% and "0 / 2000 ml". Tap Glass (250ml) — the
ring updates to 12% and "250 / 2000 ml". The "Daily Target: 2000 ml"
label is visible.

**Acceptance Scenarios**:

1. **Given** a fresh database with no entries,
   **When** the user opens the Home screen,
   **Then** the progress ring shows "0%" and "0 / 2000 ml",
   and "Daily Target: 2000 ml" is displayed below the ring.

2. **Given** the user has logged 500ml today against a 2000ml target,
   **When** the user views the Home screen,
   **Then** the progress ring shows "25%" and "500 / 2000 ml".

3. **Given** the user has met or exceeded their target,
   **When** the progress ring renders,
   **Then** the arc colour changes from primary (orange) to success (green),
   and the percentage displays the actual value (e.g. "125%") while
   the arc is clamped to a full circle.

---

### User Story 2 - Log Water Quickly via Quick-Add Buttons (Priority: P1)

The user sees four quick-add buttons (Glass 250ml, Bottle 500ml,
Large 750ml, Custom) and can log a preset amount with a single tap.
Each button has a descriptive icon, label, and amount.

**Why this priority**: Quick-add buttons are the primary interaction
for water logging (M1: log in ≤ 3 seconds). If they are missing or
broken, the core value proposition fails.

**Independent Test**: From the Home screen, tap "Glass" — the progress
ring updates. Tap "Bottle" — the ring updates again. Tap "Large" — the
ring updates again. All three amounts are additive.

**Acceptance Scenarios**:

1. **Given** the Home screen is displayed,
   **When** the user views the quick-add area,
   **Then** four buttons are visible: Glass (250 ml), Bottle (500 ml),
   Large (750 ml), and Custom (no amount shown).

2. **Given** the Home screen with 0ml logged,
   **When** the user taps the "Glass" button,
   **Then** a 250ml entry is persisted and the progress ring updates
   to reflect the new total.

3. **Given** the Home screen with 250ml logged,
   **When** the user taps "Bottle",
   **Then** the total becomes 750ml and the ring updates to "38%".

---

### User Story 3 - Log a Custom Amount (Priority: P1)

The user taps the "Custom" button, a bottom sheet appears with a
numeric input field, validation, and an "Add" button. Valid amounts
(1–5000 ml) are accepted; invalid inputs show inline errors.

**Why this priority**: Custom amounts are necessary for any non-preset
quantity (M2: log custom in ≤ 15 seconds). Without this, users cannot
track odd-sized containers.

**Independent Test**: Tap Custom → enter "350" → tap Add → sheet
dismisses → progress ring updates. Tap Custom → leave empty → tap Add
→ error "Please enter an amount". Enter "0" → error. Enter "5001" →
error. Enter "1" → succeeds. Enter "5000" → succeeds.

**Acceptance Scenarios**:

1. **Given** the user taps the Custom button,
   **When** the bottom sheet appears,
   **Then** it shows a title "Custom Amount", a numeric text field
   with "Enter amount" hint and "ml" suffix, and an "Add" button.

2. **Given** the bottom sheet is open and the field is empty,
   **When** the user taps "Add",
   **Then** the error message "Please enter an amount" is shown inline.

3. **Given** the bottom sheet is open with "0" entered,
   **When** the user taps "Add",
   **Then** the error message "Amount must be at least 1 ml" is shown.

4. **Given** the bottom sheet is open with "5001" entered,
   **When** the user taps "Add",
   **Then** the error message "Amount must be at most 5,000 ml" is shown.

5. **Given** the bottom sheet is open with "350" entered,
   **When** the user taps "Add",
   **Then** the sheet dismisses, a 350ml entry is persisted, and the
   progress ring updates.

---

### User Story 4 - See Streak Counters (Priority: P2)

The user sees their current streak and longest streak on the Home
screen, motivating continued daily logging.

**Why this priority**: Streaks are a key motivational element (G4)
but the app is fully functional without them. They depend on existing
streak computation from D1.

**Independent Test**: On a fresh database, both streaks show 0.
After meeting today's target, the current streak shows 1.

**Acceptance Scenarios**:

1. **Given** a fresh database,
   **When** the Home screen loads,
   **Then** the streak card shows "Current Streak: 0" and
   "Longest Streak: 0".

2. **Given** the user has met their target for 3 consecutive days,
   **When** the Home screen loads,
   **Then** the current streak shows 3.

---

### User Story 5 - Empty State Prompt (Priority: P2)

When no water has been logged today, the Home screen shows a
motivational prompt encouraging the user to log their first glass.
The prompt disappears after the first entry. Buttons remain visible
at all times.

**Why this priority**: Empty states (FR-011) improve first-run
experience but are not blocking for core functionality.

**Independent Test**: Launch with fresh DB → see prompt. Tap Glass →
prompt disappears. Buttons are always visible.

**Acceptance Scenarios**:

1. **Given** zero entries for today,
   **When** the Home screen loads,
   **Then** the text "Start tracking by logging your first glass!"
   is visible, and all four quick-add buttons are also visible.

2. **Given** the user has logged at least one entry today,
   **When** the Home screen loads,
   **Then** the empty state prompt is not shown.

---

### Edge Cases

- What happens when consumed exceeds target? The percentage displays
  the actual value (e.g. "125%") but the progress arc is clamped to
  a full circle (360 degrees). The arc colour switches to success green.
- What happens on narrow screens? Quick-add buttons use `Wrap` layout
  and flow to the next line if horizontal space is insufficient.
- What happens when the keyboard is open in the Custom sheet? The sheet
  uses `isScrollControlled: true` and pads for `MediaQuery.viewInsets.bottom`
  to avoid the keyboard obscuring the input.
- What happens with very large custom amounts (e.g. 5000 ml)? Accepted
  as valid. Amounts above 5000 or below 1 are rejected with inline errors.
- What happens when the body content is taller than the screen? A
  `SingleChildScrollView` wraps the entire body, preventing overflow.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-002**: App MUST allow logging water intake via quick-add buttons
  (250/500/750 ml) and a custom amount.
- **FR-004**: App MUST validate custom input (integer, 1–5000 ml range).
- **FR-005**: Home screen MUST show daily progress towards the target
  (circular progress ring with percentage) and prominent streak counters.
- **FR-010**: Streak tracking MUST compute consecutive days meeting/
  exceeding the target (current + longest).
- **FR-011**: App MUST provide empty state for Home screen when no
  entries exist for today.
- **FR-012** (partial): Home screen MUST display the current daily
  target value.

### Key Entities

- **ProgressRing**: CustomPainter-based circular progress indicator
  showing consumed/target with percentage text. Colour transitions
  from primary to success when target is met.
- **QuickAddButton**: Tappable card with icon, label, and optional
  amount. Four instances: Glass, Bottle, Large, Custom.
- **CustomAmountSheet**: Modal bottom sheet with validated numeric
  input returning `Future<int?>`.
- **StreakCard**: Card displaying current and longest streak values.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Progress ring shows correct percentage (0%, 25%, 100%,
  >100%) for all consumed/target combinations.
- **SC-002**: Tapping any quick-add button persists an entry and
  updates the progress ring within the same frame cycle.
- **SC-003**: Custom amount validation rejects empty, 0, and >5000
  inputs with correct error messages; accepts 1 and 5000 as boundary
  values.
- **SC-004**: Streak card displays current and longest streak values
  sourced from the existing `streaksProvider`.
- **SC-005**: Empty state prompt appears when todayTotal == 0 and
  disappears after the first entry.
- **SC-006**: `flutter analyze` produces zero new issues.
- **SC-007**: `flutter test` — all tests green (including existing
  D0/D1 tests).

## Assumptions

- D1 providers (`todayTotalProvider`, `dailyTargetProvider`,
  `streaksProvider`) and repositories are complete and supply all
  required data.
- Validation (1–5000 ml) is already enforced in
  `WaterEntryRepository.add()` at the repository layer; the
  CustomAmountSheet provides client-side validation as an additional
  UX guard.
- No new Riverpod providers or database changes are needed for D2.
- The daily target defaults to 2000 ml (seeded in the database).
- The progress ring is built with `CustomPainter` (not
  `CircularProgressIndicator`) for full styling control.
- Bottom tab navigation and settings gear icon remain unchanged from
  D1.
