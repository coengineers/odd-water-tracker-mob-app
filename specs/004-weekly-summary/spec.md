# Feature Specification: Weekly Summary + Monthly Patterns (D4)

**Feature Branch**: `004-weekly-summary`
**Created**: 2026-02-12
**Status**: Implemented
**Input**: PRD Section 10 — D4: "Visualise patterns with simple stats." Covers FR-008, FR-009, FR-011.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Weekly Bar Chart (Priority: P1)

A user navigates to the Weekly tab and sees a 7-day bar chart
showing daily water totals for the last 7 days (ending today).
A horizontal dashed reference line marks the daily target. Bars
that meet or exceed the target are coloured green; below-target
bars use the brand primary orange.

**Why this priority**: The weekly bar chart is the core
visualisation for FR-008. It provides the at-a-glance pattern
recognition that motivates users to stay consistent.

**Independent Test**: Log water on 3 different days in the last
week. Navigate to Weekly tab — see 7 bars (3 filled, 4 at zero),
a dashed target line, and green colouring for any bars at/above
the target.

**Acceptance Scenarios**:

1. **Given** at least 1 day of data in the last 7 days,
   **When** the user opens the Weekly tab,
   **Then** a 7-day bar chart displays daily totals with abbreviated
   day labels (Mon–Sun) and a horizontal dashed reference line at
   the target.

2. **Given** a day's total meets or exceeds the target,
   **When** the bar chart renders,
   **Then** that day's bar uses `AppColors.success` (green).

3. **Given** a day's total is below the target,
   **When** the bar chart renders,
   **Then** that day's bar uses `AppColors.primary` (orange).

4. **Given** a day has no data,
   **When** the bar chart renders,
   **Then** that day's bar has height 0.

---

### User Story 2 - View Weekly Stats (Priority: P1)

Below the bar chart, the user sees two summary stats: average
intake per day (sum ÷ 7) and the number of days the target was
hit (out of 7).

**Why this priority**: Stats give meaning to the chart. "Avg/day"
quantifies consistency; "Days on target" tracks goal adherence —
both are required by FR-008.

**Independent Test**: Log 2000ml on 2 days and 500ml on 1 day
(total 4500ml). Stats should show: Avg = 4500 ÷ 7 = 642 ml,
Days on target = 2 / 7.

**Acceptance Scenarios**:

1. **Given** water data exists in the last 7 days,
   **When** the Weekly tab shows the stats row,
   **Then** "Avg / day" shows total sum ÷ 7 (integer division) in ml,
   and "Days on target" shows the count of days where total ≥ target
   out of 7.

2. **Given** no data exists in the last 7 days,
   **When** the stats row renders,
   **Then** average is "0 ml" and days on target is "0 / 7".

---

### User Story 3 - View Monthly Calendar Heatmap (Priority: P1)

A user navigates to the Monthly tab and sees the current month's
name, followed by a calendar grid. Each day cell is coloured by
intake intensity (5 opacity levels of brand primary). Days that
hit the target show a small green check icon.

**Why this priority**: The calendar heatmap (FR-009) is the primary
monthly visualisation, giving users a bird's-eye view of their
hydration consistency across the month.

**Independent Test**: Seed data for multiple days in the current
month with varying totals. Navigate to Monthly tab — see month
title, coloured cells at different intensities, and check marks
on target-met days.

**Acceptance Scenarios**:

1. **Given** data exists in the current month,
   **When** the user opens the Monthly tab,
   **Then** the month title (e.g. "February 2026") is displayed,
   and a calendar grid shows day cells coloured by intake intensity.

2. **Given** a day's total is ≥ target,
   **When** the heatmap renders,
   **Then** that cell shows a green check icon.

3. **Given** the colour intensity mapping:
   | Range            | Colour                           |
   |------------------|----------------------------------|
   | 0 / no data      | `AppColors.bgSurfaceHover`       |
   | 1–25% of target  | `primary` at 20% opacity         |
   | 26–50%           | `primary` at 40% opacity         |
   | 51–75%           | `primary` at 60% opacity         |
   | 76–99%           | `primary` at 80% opacity         |
   | 100%+            | `primary` full + check mark      |

   **When** cells render,
   **Then** each cell matches its intensity level.

---

### User Story 4 - Tap Day for Tooltip (Priority: P2)

The user taps a day cell on the monthly heatmap and sees a tooltip
card below the grid showing the date, total ml, and whether the
target was hit. Tapping the same day dismisses the tooltip; tapping
a different day switches to that day's details.

**Why this priority**: Day-level detail on tap (FR-009) enhances
the heatmap but is not blocking for the visual pattern display.

**Independent Test**: Tap a day with 1500ml logged against a 2000ml
target. Tooltip shows the date, "1500 ml", and "Below target". Tap
again — tooltip disappears. Tap a different day — tooltip switches.

**Acceptance Scenarios**:

1. **Given** the heatmap is displayed,
   **When** the user taps a day cell,
   **Then** a tooltip Card appears below the grid showing the date,
   total ml, and target status ("Below target" or check icon).

2. **Given** a tooltip is shown for a day,
   **When** the user taps the same day again,
   **Then** the tooltip is dismissed.

3. **Given** a tooltip is shown for day A,
   **When** the user taps day B,
   **Then** the tooltip switches to show day B's data.

---

### User Story 5 - Empty States (Priority: P2)

When no data exists for the current week or month, the respective
screen shows an icon, a heading, and a prompt to log water from
the Home tab.

**Why this priority**: Empty states (FR-011) improve UX but are
not blocking for core visualisation.

**Independent Test**: Open Weekly tab on fresh database — see
bar_chart_outlined icon, "No data this week", and prompt. Open
Monthly tab — see calendar_month_outlined icon, "No data this
month", and prompt.

**Acceptance Scenarios**:

1. **Given** zero entries in the last 7 days,
   **When** the user opens the Weekly tab,
   **Then** an empty state shows: `Icons.bar_chart_outlined` (64px,
   muted), "No data this week" heading, "Log water from the Home
   tab to start tracking!" body text.

2. **Given** zero entries in the current month,
   **When** the user opens the Monthly tab,
   **Then** an empty state shows: `Icons.calendar_month_outlined` (64px,
   muted), "No data this month" heading, "Log water from the Home
   tab to start tracking!" body text.

3. **Given** the user has logged at least one entry,
   **When** the corresponding screen loads,
   **Then** the empty state is not shown.

---

### Edge Cases

- What happens when the month starts on a non-Monday? Leading
  empty cells offset the grid so day 1 aligns to its correct
  weekday column (Monday-based).
- What happens when the calendar heatmap overflows vertically
  (e.g. months with 6 rows)? The monthly screen wraps content in
  a `SingleChildScrollView` to prevent overflow.
- What happens when intake is exactly at the target boundary?
  Values equal to `targetMl` count as "hit" and show success
  colour / check mark.
- What happens when target is very low (e.g. 250ml)? Bars may
  exceed maxY — the chart auto-scales to 115% of the maximum
  observed value or the target, whichever is larger.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-008**: Weekly Summary MUST show a 7-day bar chart of daily
  totals with a target reference line, average daily intake, and
  number of days hitting the target.
- **FR-009**: Monthly Patterns MUST show a calendar heatmap with
  colour intensity by intake, check marks for target-met days, and
  tap-to-tooltip for day details.
- **FR-011**: App MUST provide empty states for Weekly and Monthly
  screens when data is insufficient.

### Key Entities

- **WeeklyBarChart**: fl_chart `BarChart` with 7 bars, target
  reference line, day labels, and colour coding by target status.
- **WeeklyStatsRow**: Row showing average/day and days-on-target.
- **CalendarHeatmap**: StatefulWidget with 7-column grid, intensity
  colouring, check icons, and tap-to-tooltip.
- **weeklySummaryProvider**: Riverpod provider fetching last-7-days
  daily totals from `WaterStatsRepository.getWeeklySummary()`.
- **monthlyTotalsProvider**: Riverpod provider fetching current
  month totals from `WaterStatsRepository.getMonthlyTotals()`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Weekly bar chart renders 7 bars with correct values,
  day labels, and a horizontal target reference line.
- **SC-002**: Bars at/above target use success (green) colour; bars
  below use primary (orange).
- **SC-003**: Weekly stats row shows correct average (sum ÷ 7) and
  correct days-hit count.
- **SC-004**: Monthly heatmap renders correct number of day cells
  with proper weekday alignment.
- **SC-005**: Heatmap cells use correct intensity colour based on
  intake fraction.
- **SC-006**: Days at/above target show a green check icon.
- **SC-007**: Tapping a day shows tooltip with date, total, and
  target status; tapping again dismisses; tapping another switches.
- **SC-008**: Empty states appear when no data exists for the
  week/month and disappear when data is present.
- **SC-009**: `flutter analyze` produces zero new issues.
- **SC-010**: `flutter test` — all tests green (D0–D4), 103 total.

## Assumptions

- D1/D2/D3 providers (`todayTotalProvider`, `todayEntriesProvider`,
  `dailyTargetProvider`, `streaksProvider`) and repositories are
  complete and tested.
- `WaterStatsRepository.getWeeklySummary()` and
  `WaterStatsRepository.getMonthlyTotals()` exist and return
  `Map<String, int>` (date string → total ml).
- `fl_chart` is already in pubspec.yaml (added in D0, previously
  unused).
- `intl` package is already in pubspec.yaml for date formatting.
- The daily target defaults to 2000 ml.
- Calendar weeks start on Monday (ISO standard).
- Provider invalidation for weekly/monthly data is not needed in D4
  because these providers auto-refresh on screen visit.
