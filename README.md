# EcoTrack

EcoTrack is a Flutter and Dart carbon-footprint companion. All application screens, styling, navigation, state, forms, and interactions are implemented with Flutter widgets. The `web/` directory contains Flutter's web bootstrap only; it does not render application UI with HTML.

## Run

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze
flutter test
```

## App Structure

- `lib/main.dart` starts the app and maps store routes to screens.
- `lib/screens/` contains onboarding, authentication, home, activity logging, results, history, statistics, challenges, tips, and profile screens.
- `lib/widgets/` contains shared navigation, sheets, common controls, and charts.
- `lib/models.dart` defines activities, emission estimates, tips, challenges, and badges.
- `lib/store.dart` manages app state and in-app navigation.
- `lib/theme.dart` defines Flutter design tokens and the app theme.
- `assets/` contains mascot artwork and bundled fonts.

The app currently uses seeded illustrative data held in memory. No backend or API is configured; entries and settings reset when the app process restarts.
