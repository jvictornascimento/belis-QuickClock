# Repository Guidelines

## Project Structure & Module Organization

This repository is a Flutter app named `quick_clock`. The current generated structure is:

- `lib/` for Dart application code.
- `test/` for widget and unit tests.
- `android/` for the Android host project.
- `PROJECT_CONTEXT.md` for product rules and story planning.

Future feature code should stay under `lib/` and follow the planned modules: `features/`, `data/`, `models/`, and `shared/`.

## Build, Test, and Development Commands

Use the Flutter CLI from the repository root:

- `flutter pub get` - install Dart and Flutter dependencies.
- `flutter analyze` - run static analysis and lints.
- `flutter test` - run automated tests.
- `flutter run` - run on a connected Android device or emulator.
- `flutter build apk --debug` - create a debug APK.

Do not add native Android or iOS code unless the feature cannot be built in Dart/Flutter.

## Coding Style & Naming Conventions

Follow `flutter_lints` from `analysis_options.yaml`. Format Dart code before committing:

```bash
dart format lib test
```

Use `PascalCase` for widgets/classes, `camelCase` for variables and methods, and `snake_case.dart` for Dart filenames. Keep widgets focused and move reusable UI into `shared/` when it appears in more than one feature.

## Testing Guidelines

Add tests with each behavioral change. Use `flutter_test` for widget tests and plain Dart tests for business rules.

Name tests by behavior, for example `shows the app shell` or `calculates month total with marked periods`. Run `flutter test` before opening a pull request.

## Commit & Pull Request Guidelines

Use Conventional Commits with a scope and simple English:

- `feat(home): add period buttons`
- `fix(report): hide empty days`
- `docs(context): update story plan`

Pull requests should include a concise description, linked issue when applicable, test results, and screenshots for UI changes. Note any schema, configuration, or migration steps clearly.

## Agent-Specific Instructions

Before editing, inspect the current repository state and avoid assuming a framework that is not present. Keep changes scoped, document new commands here, and do not remove user-created files unless explicitly requested.
