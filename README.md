# WaterLog

Offline-first water intake tracker built with Flutter.

## Prerequisites

- Flutter 3.38+ (stable channel) with Dart 3.10+
- A connected device or running emulator (`flutter devices` to verify)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (drift, riverpod, freezed)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run static analysis
flutter analyze

# Run tests
flutter test
```

## Project Structure

```
lib/
  app.dart              # Root app widget (MaterialApp.router)
  main.dart             # Entry point
  db/                   # Drift database
  providers/            # Riverpod providers
  repositories/         # Data access layer (D1+)
  router/               # go_router configuration
  screens/              # Screen widgets
  services/             # Business logic services (D1+)
  theme/                # Colours, typography, spacing, ThemeData
  utils/                # Shared utilities (D1+)
  widgets/              # Reusable widgets
test/                   # Unit and widget tests
integration_test/       # Integration tests (D5)
assets/
  fonts/                # Satoshi + Nunito font files
docs/
  PRD.md                # Product requirements
  brand-kit.md          # Brand identity and design tokens
```
