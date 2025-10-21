## Purpose

Short, actionable guidance for AI coding agents working on the Aura Safe Flutter app.
Focus on what is discoverable in the repo so you can be productive immediately.

## Quick commands (Windows PowerShell)

Get dependencies and run app (choose a target device):

```powershell
flutter pub get
flutter run -d windows     # or -d emulator-5554, -d <device id>, or just `flutter run`
```

Build and test:

```powershell
flutter build apk          # Android
flutter build ios          # macOS/iOS (requires macOS environment)
flutter test               # run unit/widget tests
flutter analyze            # static analysis (uses analysis_options.yaml)
```

If you change native Gradle files for Android, use the Gradle wrapper in `android/`:

```powershell
cd android; .\gradlew.bat assembleDebug
```

## High-level architecture (what to read first)

- Entrypoint: `lib/main.dart` — sets a dark theme and `MainScreen` which composes the app.
- Primary UI routing: `MainScreen` uses a BottomNavigationBar and an internal `_widgetOptions` list that holds screens: `lib/screens/home_screen.dart`, `lib/screens/sos_screen.dart`, `lib/screens/map_screen.dart`, `lib/screens/profile_screen.dart`.
- Reusable UI: `lib/widgets/` contains small, focused widgets (e.g. `animated_button.dart`, `alert_card.dart`). Inspect these for common patterns (GestureDetectors, Animated widgets).
- Platform/native code: `android/`, `ios/`, `windows/`, `macos/`, `linux/` — mostly Flutter platform scaffolding and generated plugin registrants. There are no obvious custom MethodChannel implementations in the repo (search for MethodChannel if you need platform integration).

## Project-specific conventions and patterns

- UI state: screens are mostly StatelessWidgets or simple StatefulWidgets. `MainScreen` holds navigation state (`_selectedIndex`).
- Animation pattern: press effects use `GestureDetector` with `AnimatedScale` in `lib/widgets/animated_button.dart` — prefer small, composable animated widgets.
- Navigation pattern: stateful in `MainScreen` rather than Navigator routes for bottom nav tabs; to add new main tabs, update `_widgetOptions` and the BottomNavigationBar items in `lib/main.dart`.
- Icons: project uses the `line_icons` package (see `pubspec.yaml`).
- Lints: project enables `flutter_lints` and `analysis_options.yaml` — follow the rules enforced there.

## Common change examples

- Add a new top-level screen:
  1. Create `lib/screens/new_screen.dart` with a `StatelessWidget`.
  2. Import and add it to `_widgetOptions` in `lib/main.dart` and add a corresponding `BottomNavigationBarItem`.

- Add a new dependency:
  1. Update `pubspec.yaml` and run `flutter pub get`.
  2. If native code is involved, run the platform build (e.g., `cd android; .\gradlew.bat assembleDebug`).

- Use shared widgets:
  - `lib/widgets/animated_button.dart` demonstrates the press-down pattern (onTapDown/onTapUp/onTapCancel) and `AnimatedScale` for smooth interaction.

## Tests, linting, and CI hints

- Run `flutter test` for the test suite (there is a `test/widget_test.dart` starter test).
- Run `flutter analyze` (or rely on your editor) to see lint issues from `analysis_options.yaml`.
- There is no existing GitHub Actions workflow in this repo — if you add CI, run `flutter pub get`, `flutter analyze`, and `flutter test` on the matrix of targeted OSes.

## Integration points & external dependencies

- Dependencies declared in `pubspec.yaml`: `cupertino_icons`, `line_icons`.
- Platform plugin registration files exist under each platform's `flutter/` folder (generated). Treat plugin native code as separate — review `android/app/src` and `ios/Runner` if modifying.

## Files to inspect first for any UI/behavior change

- `lib/main.dart` — navigation, theming, and main composition.
- `lib/screens/*.dart` — screens and their sample implementations.
- `lib/widgets/*.dart` — utilities and reusable components (e.g., `animated_button.dart`, `alert_card.dart`).
- `pubspec.yaml` and `analysis_options.yaml` — dependency and lint rules.

## What not to assume

- There are no visible analytics, authentication, or backend service clients in the repo. If a change requires network or auth, search for HTTP clients or MethodChannel usage first.
- No CI or release automation files were found — don't assume workflows exist.

## Quick checklist for PR changes

- Run `flutter analyze` and `flutter test` locally.
- Bump `pubspec.yaml` only if you intend to publish; otherwise leave `publish_to: 'none'` untouched.
- Update imports in `lib/main.dart` when adding/removing screens.

---
If any section is unclear or you'd like CI workflow examples or more example edits (add widget + test), tell me which area to expand and I'll update this file.
