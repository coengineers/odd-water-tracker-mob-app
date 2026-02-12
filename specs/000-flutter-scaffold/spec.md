# Feature Specification: Flutter Scaffold & Navigation (D0)

**Feature Branch**: `000-flutter-scaffold`
**Created**: 2026-02-11
**Status**: Done
**Input**: User description: "Implement D0 from /docs/PRD.md — Flutter scaffold & navigation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Launch App and See Home Screen (Priority: P1)

A user installs the app for the first time, opens it, and immediately
sees a Home screen with a clear layout. The app loads without requiring
any account setup, network connection, or onboarding flow.

**Why this priority**: The Home screen is the entry point for every
user session. If the app does not boot to a usable Home screen,
nothing else matters.

**Independent Test**: Launch the app on a device in airplane mode.
The Home screen renders with the brand-correct theme and the app
title is visible.

**Acceptance Scenarios**:

1. **Given** a fresh install on a device in airplane mode,
   **When** the user opens the app,
   **Then** the Home screen renders within 2 seconds (cold start)
   with the app title "WaterLog" and placeholder content.

2. **Given** the app is already running,
   **When** the user returns to the Home screen from any other screen,
   **Then** the Home screen renders and no network requests are made.

---

### User Story 2 - Navigate to All Screens (Priority: P1)

From the Home screen, the user can navigate to each of the four main
screens (Home, Daily, Weekly Summary, Monthly Patterns) via bottom
navigation, and access Settings from the app bar. Every screen shows
a placeholder shell that confirms the route is reachable.

**Why this priority**: Navigation is the structural backbone. All
future deliverables (D1-D5) depend on routes being defined and
reachable. Without working navigation, no subsequent feature can be
built or tested.

**Independent Test**: Starting from Home, tap each bottom navigation
item and verify the correct screen shell renders. Tap the settings
icon and verify Settings renders with back navigation.

**Acceptance Scenarios**:

1. **Given** the user is on the Home screen,
   **When** the user taps the "Daily" tab in bottom navigation,
   **Then** the Daily screen shell renders with the screen title
   visible.

2. **Given** the user is on the Home screen,
   **When** the user taps the "Weekly" tab in bottom navigation,
   **Then** the Weekly Summary screen shell renders with the screen
   title visible.

3. **Given** the user is on the Home screen,
   **When** the user taps the "Monthly" tab in bottom navigation,
   **Then** the Monthly Patterns screen shell renders with the screen
   title visible.

4. **Given** the user is on any tab,
   **When** the user taps the settings icon in the app bar,
   **Then** the Settings screen shell renders with back navigation
   to return to the previous tab.

5. **Given** the user is on any child screen (Settings),
   **When** the user uses back navigation,
   **Then** the user returns to the previous tab.

---

### User Story 3 - Brand-Compliant Visual Identity (Priority: P2)

The app renders with the CoEngineers brand identity: dark theme as
default, brand orange for primary accents, Satoshi font for headings,
Nunito for body text, and consistent spacing and radius tokens. The
visual identity is established once in the scaffold so all subsequent
screens inherit it automatically.

**Why this priority**: Establishing the theme in D0 means every
subsequent deliverable gets brand compliance for free. Deferring
theming creates rework across all screens later.

**Independent Test**: Launch the app and visually verify: dark
background (`#0E0F12`), brand orange accents (`#F7931A`), Satoshi
headings, Nunito body text. Confirm text is readable (sufficient
contrast) and touch targets meet minimum size.

**Acceptance Scenarios**:

1. **Given** the app launches,
   **When** the Home screen renders,
   **Then** the background colour is the brand dark mode default
   (`#0E0F12`), heading text uses the Satoshi font family, and body
   text uses the Nunito font family.

2. **Given** the app launches,
   **When** the user views any primary action button,
   **Then** the button uses brand orange (`#F7931A`) as its accent
   colour.

3. **Given** the app launches,
   **When** the user views any interactive element,
   **Then** the element has a minimum tap area of 48x48 dp.

---

### User Story 4 - Database Infrastructure Ready (Priority: P2)

The app initialises a local SQLite database on first launch using
drift. The database connection is managed via Riverpod and available
to all screens. No tables are populated yet — only the migration
infrastructure is in place.

**Why this priority**: D1 requires database tables and repositories.
Having the drift infrastructure bootstrapped in D0 means D1 can
immediately define tables without wiring boilerplate.

**Independent Test**: Launch the app and verify no crash occurs
related to database initialisation. The database file is created
on disk.

**Acceptance Scenarios**:

1. **Given** a fresh install,
   **When** the app launches,
   **Then** a SQLite database file (`water_log.sqlite`) is created
   in the app's documents directory without errors.

2. **Given** the database provider exists,
   **When** any screen widget accesses the database via Riverpod,
   **Then** the same database instance is returned (singleton).

---

### Edge Cases

- What happens when the device has extremely large or small text
  accessibility settings? Screen shells MUST remain usable and not
  clip or overflow. Body text minimum is 16px to prevent iOS input
  zoom.
- What happens when the user rapidly switches between bottom
  navigation tabs? Navigation MUST not produce visual glitches or
  errors.
- What happens on devices with notches, dynamic islands, or
  non-standard safe areas? Screen content MUST respect safe area
  insets.
- What happens when the user rotates the device? The scaffold MUST
  handle portrait orientation gracefully (no crash on rotation).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-D0-001**: The app MUST boot to the Home screen without
  requiring any account, sign-in, or network connection.
- **FR-D0-002**: The app MUST define routes for five screens: Home,
  Daily, Weekly Summary, Monthly Patterns, and Settings.
- **FR-D0-003**: The user MUST be able to navigate between Home,
  Daily, Weekly Summary, and Monthly Patterns via bottom navigation
  tabs.
- **FR-D0-004**: The user MUST be able to navigate from any tab to
  Settings via the app bar, and return via back navigation.
- **FR-D0-005**: Each screen MUST render a shell with a visible
  screen title and placeholder content indicating its purpose.
- **FR-D0-006**: The app MUST apply the CoEngineers brand theme
  (dark mode default) with correct colour tokens, typography, spacing,
  and radius values from the brand kit.
- **FR-D0-007**: All fonts (Satoshi for headings, Nunito for body)
  MUST be bundled as app assets — no runtime font downloads.
- **FR-D0-008**: All interactive elements MUST have a minimum tap
  area of 48x48 dp.
- **FR-D0-009**: Bottom navigation MUST use StatefulShellRoute to
  preserve each tab's state independently.
- **FR-D0-010**: The app MUST initialise a drift (SQLite) database
  on launch with migration infrastructure in place.

### Key Entities

- **Screen Shell**: A placeholder screen with a title and placeholder
  body content. Serves as the mounting point for future feature
  implementation.
- **Route**: A named navigation destination with a defined path and
  associated screen widget. Routes form the navigation graph of the
  app.
- **Database**: A drift-managed SQLite database with migration
  support, provided as a Riverpod singleton.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The app boots to the Home screen in under 2 seconds
  (cold start) on a mid-range device with no network connection.
- **SC-002**: A user can navigate to every screen via bottom
  navigation and settings icon without errors.
- **SC-003**: All five screens are reachable and render their shell
  content without errors or blank screens.
- **SC-004**: The app produces zero crashes during a navigation
  smoke test covering all defined routes.
- **SC-005**: The visual theme matches the brand kit specification:
  correct background colour, primary accent colour, heading font, and
  body font are applied consistently across all screens.
- **SC-006**: No network requests are made at any point during app
  usage (verified via inspection).
- **SC-007**: The SQLite database file is created on first launch
  without errors.

## Assumptions

- Navigation uses a bottom tab pattern with StatefulShellRoute:
  Home, Daily, Weekly, and Monthly are tab destinations. Settings
  is accessed via the app bar and uses push navigation.
- Screen shells are intentionally minimal — they display a title and
  placeholder text only. Actual screen content (forms, lists, charts)
  is deferred to D1-D4.
- The database is initialised with migration infrastructure but no
  tables. Tables are added in D1.
- Portrait orientation is the primary layout. The app handles rotation
  gracefully (no crash) but does not optimise for landscape.
- Light mode theming is deferred to a future deliverable. Only dark
  mode is implemented in D0.
