# Release Checklist — WaterLog v1.0

**Date**: 2026-02-12
**Branch**: `005-settings-polish`

---

## Automated Checks

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all unit/widget tests green
- [ ] `flutter test integration_test/` — all integration tests green

## Manual QA

- [ ] Airplane mode QA pass — app fully functional offline
- [ ] No HTTP client imports in `lib/` (verify offline-only)
- [ ] Debug tools hidden in release (`kDebugMode` guard on seed data)
- [ ] All screens functional end-to-end:
  - [ ] Home: progress ring, quick-add buttons, custom amount, streak card
  - [ ] Daily: entry list, delete with confirmation, progress bar
  - [ ] Weekly: bar chart, stats row, empty state
  - [ ] Monthly: calendar heatmap, tooltip on tap, empty state
  - [ ] Settings: edit target, reset all data, about, seed data (debug)

## Accessibility

- [ ] ProgressRing has Semantics label
- [ ] QuickAddButton has Semantics label with button trait
- [ ] StreakCard has Semantics label
- [ ] CustomAmountSheet has Semantics label
- [ ] EditTargetSheet has Semantics label
- [ ] All screens have Semantics labels

## Build Verification

- [ ] `flutter build apk --release` succeeds
- [ ] `flutter build ios --release` succeeds (if macOS)
- [ ] Release APK/IPA tested on physical device

---

## Known Limitations

1. **DST boundary**: Entries use local time; midnight boundary edge case may misattribute entries during DST transitions.

2. **Retroactive target change**: Changing the daily target recomputes all historical streaks retroactively with the new target value. There is no per-day target history.

3. **No data export/backup**: Users cannot export their data or create backups. Data is stored locally in SQLite only.

4. **No undo for delete**: Deleting a water entry is permanent once confirmed. The only safety net is the confirmation dialog.

5. **Single timezone**: The app uses the device's local timezone. Traveling across timezones may cause entries to appear on unexpected days.

6. **No landscape optimization**: The app is designed for portrait mode. Landscape works but is not optimized (charts may appear squished).

7. **No widget/notification support**: No home screen widget or reminder notifications are implemented.

8. **No multi-device sync**: Data is local-only with no cloud sync between devices.
