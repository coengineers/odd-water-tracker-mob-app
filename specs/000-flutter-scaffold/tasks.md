# Tasks: Flutter Scaffold & Navigation (D0)

**Input**: Design documents from `/specs/000-flutter-scaffold/`
**Prerequisites**: spec.md (required), /docs/PRD.md, /docs/brand-kit.md

**Tests**: Included — the feature specification requires widget tests for navigation and screen rendering (FR-D0-002, FR-D0-003, SC-003, SC-004).

**Organization**: Tasks are grouped by phase. US1 and US2 are both P1 but are ordered sequentially because US2 (navigation) depends on the screen widgets created in US1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialisation, dependency installation, font bundling, and linting configuration.

- [x] T001 Run `flutter create --org com.coengineers --platforms ios,android --project-name water_log .` to initialise the Flutter project in-place
- [x] T002 Update `pubspec.yaml`: add `go_router: ^15.1.2`, `flutter_riverpod: ^2.6.1`, `riverpod_annotation: ^2.6.1`, `drift: ^2.25.0`, `sqlite3_flutter_libs: ^0.5.32`, `fl_chart: ^0.70.2`, `intl: ^0.20.2`, `uuid: ^4.5.1`, `path_provider`, `path` to dependencies; add `build_runner`, `drift_dev`, `riverpod_generator`, `freezed`, `mocktail` to dev_dependencies; declare font assets under `flutter.fonts` (Satoshi, Nunito) and `flutter.assets`
- [x] T003 [P] Create `assets/fonts/` directory and place font files: Satoshi (OTF, multiple weights) and Nunito (TTF, Regular/SemiBold/Bold)
- [x] T004 [P] Configure `analysis_options.yaml` with strict analysis rules
- [x] T005 Run `flutter pub get` to install dependencies and verify resolution

**Checkpoint**: Flutter project compiles, `flutter analyze` runs.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Theme, router, and database infrastructure that ALL screens depend on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T006 Create `lib/theme/app_colors.dart` — implement `AppColors` class with static colour constants: brand orange (`#F7931A`), dark mode backgrounds (`#0E0F12`, `#151821`, `#1C2030`), text colours (primary `#E6E8EE`, secondary `#A2A8BD`, muted `#6E748A`), navigation colours, semantic colours (success, warning, error, info), neutral scale
- [x] T007 Create `lib/theme/app_typography.dart` — implement `AppTypography` class with static constants: heading font (Satoshi), body font (Nunito), font sizes (xs through 4xl), line heights, letter spacing
- [x] T008 Create `lib/theme/app_spacing.dart` — implement `AppSpacing` class with static constants: 4px base grid spacing scale, border radii (sm/md/lg/xl/full), minimum touch target (48dp)
- [x] T009 Create `lib/theme/app_theme.dart` — implement `AppTheme` class with static `dark` getter returning `ThemeData` with: `ColorScheme` using AppColors, `TextTheme` using AppTypography (Satoshi headings, Nunito body, min 16px body), AppBar/BottomNavigationBar/Card/InputDecoration themes, Material 3 enabled, `materialTapTargetSize: MaterialTapTargetSize.padded`
- [x] T010 Create `lib/router/app_router.dart` — implement router with `StatefulShellRoute` for bottom navigation tabs: `/` → HomeScreen, `/daily` → DailyScreen, `/weekly` → WeeklyScreen, `/monthly` → MonthlyScreen; separate `/settings` route with parent navigator
- [x] T011 Create `lib/db/app_database.dart` — implement drift database with `LazyDatabase` connection to `water_log.sqlite`, schema version 1, migration strategy (onCreate, onUpgrade, beforeOpen with foreign_keys pragma), empty tables list
- [x] T012 Create `lib/providers/database_provider.dart` — implement Riverpod provider for AppDatabase singleton (keepAlive: true) with disposal handling
- [x] T013 Create `lib/app.dart` — implement `WaterLogApp` ConsumerWidget wrapping `MaterialApp.router` with `routerConfig` from appRouter provider, `theme: AppTheme.dark`, `debugShowCheckedModeBanner: false`
- [x] T014 Create `lib/main.dart` — implement `main()` with `WidgetsFlutterBinding.ensureInitialized()`, `initializeDateFormatting()`, `runApp()` wrapping app in `ProviderScope`

**Checkpoint**: App compiles and launches to a blank Home route. `flutter analyze` passes. Theme, router, and database are ready.

---

## Phase 3: User Story 1 — Launch App and See Home Screen (Priority: P1) 🎯 MVP

**Goal**: The app boots to a Home screen with brand theme and app title.

**Independent Test**: Launch app in airplane mode → Home screen renders within 2s with title "WaterLog".

### Implementation for User Story 1

- [x] T015 [US1] Create `lib/screens/home_screen.dart` — `HomeScreen` ConsumerWidget with: AppBar displaying "WaterLog" title, settings icon button navigating to `/settings`, centered placeholder content "Home"
- [x] T016 [US1] Verify Home screen launches correctly with brand theme applied

**Checkpoint**: Home screen renders correctly with app title and settings navigation.

---

## Phase 4: User Story 2 — Navigate to All Screens (Priority: P1)

**Goal**: All five screen shells are reachable via bottom navigation (4 tabs) and app bar (settings). Tab state is preserved.

**Independent Test**: Tap each bottom navigation tab → correct screen shell renders. Tap settings icon → Settings screen renders → back returns to previous tab.

### Implementation for User Story 2

- [x] T017 [P] [US2] Create `lib/screens/daily_screen.dart` — `DailyScreen` ConsumerWidget with AppBar title "Daily", placeholder body content
- [x] T018 [P] [US2] Create `lib/screens/weekly_screen.dart` — `WeeklyScreen` ConsumerWidget with AppBar title "Weekly Summary", placeholder body content
- [x] T019 [P] [US2] Create `lib/screens/monthly_screen.dart` — `MonthlyScreen` ConsumerWidget with AppBar title "Monthly Patterns", placeholder body content
- [x] T020 [P] [US2] Create `lib/screens/settings_screen.dart` — `SettingsScreen` ConsumerWidget with AppBar title "Settings", placeholder body content, back navigation
- [x] T021 [US2] Create `lib/widgets/scaffold_with_nav_bar.dart` — `ScaffoldWithNavBar` StatelessWidget wrapping `StatefulNavigationShell`, implementing BottomNavigationBar with 4 items (Home, Daily, Weekly, Monthly) using AppColors for theming
- [x] T022 [US2] Verify all screen navigation works: bottom tabs preserve state, settings push/pop works

**Checkpoint**: All five screens render their shells. Full navigation works. Tab state is preserved.

---

## Phase 5: User Story 3 — Brand-Compliant Visual Identity (Priority: P2)

**Goal**: Theme tokens are applied correctly across all screens — dark background, brand orange accents, Satoshi headings, Nunito body, 48dp touch targets.

**Independent Test**: Launch app, visually confirm dark background (#0E0F12), orange accents (#F7931A), Satoshi headings, Nunito body text, adequate contrast, and min 48dp touch targets.

### Implementation for User Story 3

- [x] T023 [US3] Verify and refine theme application across all screens — ensure: `ColorScheme` tokens match brand kit exactly, AppBar/BottomNavigationBar themed correctly, body text uses Nunito at 16px minimum, `materialTapTargetSize: MaterialTapTargetSize.padded` ensures 48dp targets, safe area insets respected
- [x] T024 [US3] Run `flutter analyze` — verify zero warnings and zero errors across all source files

**Checkpoint**: Theme is visually brand-compliant. `flutter analyze` passes cleanly.

---

## Phase 6: User Story 4 — Database Infrastructure (Priority: P2)

**Goal**: Drift database is initialised on launch with migration support. No tables yet.

**Independent Test**: Launch app → database file created → no crash.

### Implementation for User Story 4

- [x] T025 [US4] Verify database initialisation: `water_log.sqlite` file created, Riverpod provider returns singleton, migration strategy in place
- [x] T026 [US4] Run drift code generation: `dart run build_runner build`

**Checkpoint**: Database infrastructure ready for D1 table definitions.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, cleanup, and verification.

- [x] T027 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T028 Run `flutter analyze` — zero issues
- [x] T029 Run `flutter test` — all tests green (if any exist)
- [x] T030 Validate end-to-end: app launches to Home screen, all tabs navigate correctly, settings accessible

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 (needs theme, router, main.dart)
- **US2 (Phase 4)**: Depends on Phase 3 (other screens need HomeScreen for nav context)
- **US3 (Phase 5)**: Depends on Phase 4 (all screens must exist to verify theme application)
- **US4 (Phase 6)**: Depends on Phase 2 (database infrastructure independent of screens)
- **Polish (Phase 7)**: Depends on all user story phases complete

### Parallel Opportunities

- T003 and T004 can run in parallel (different files)
- T006, T007, T008 can run in parallel (different theme files)
- T017, T018, T019, T020 can run in parallel (different screen files)

---

## Implementation Strategy

### Recommended: Sequential by Priority

1. Complete Phase 1: Setup → Flutter project compiles
2. Complete Phase 2: Foundational → Theme + Router + Database + main.dart ready
3. Complete Phase 3: US1 (P1) → Home screen with app title
4. Complete Phase 4: US2 (P1) → All screen shells + full navigation
5. Complete Phase 5: US3 (P2) → Brand compliance verified
6. Complete Phase 6: US4 (P2) → Database infrastructure verified
7. Complete Phase 7: Polish → Clean, formatted, all checks green

### Commit Strategy

- Commit after Phase 2 (foundational)
- Commit after all user stories complete (D0 implemented)

---

## Notes

- [P] tasks = different files, no dependencies — can be launched in parallel
- [Story] label maps task to specific user story for traceability
- Font files must be placed manually before T003
- `flutter create .` runs in-place — does not overwrite existing docs/, specs/, CLAUDE.md
- Navigation uses StatefulShellRoute (bottom tabs) instead of push-style navigation from D0 example — this matches the PRD's bottom navigation spec (Section 7)
- Database has empty tables list — tables are added in D1
