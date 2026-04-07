
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d chrome    # Run in Chrome (web)
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter analyze          # Lint / static analysis
dart format lib/         # Format Dart code
flutter build apk        # Build Android APK
flutter build web        # Build web app
flutter clean            # Clean build artifacts
```

## Architecture

This is a Flutter application targeting Android, iOS, web, macOS, Windows, and Linux.

- `lib/main.dart` — entire app today: `MyApp` (root widget, Material 3 theme seeded with `deepPurple`), `MyHomePage` + `_MyHomePageState` (counter screen using `setState`)
- `test/` — Flutter widget tests using `flutter_test`
- Platform folders (`android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`) contain generated native scaffolding; business logic lives in `lib/`

State management is plain `setState`; no BLoC/Provider/Riverpod is configured yet.


## Code Style Guidelines

- Recognize rules in the analysis_options.yaml
- Use dart strictly, no var or dynamic
- Prefer functional components over classes
- Use camelCase for everything(!)
- Keep functions under 80 lines
- Use the dart formatter
- Avoid double arrow functions
- Always(!) use trailing commas, always vertical arguments, 
- Trailing commas also in signatures(!)
- Auch einzelne Parameter mit Komma!
