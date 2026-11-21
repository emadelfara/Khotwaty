# Khotwaty 👟

A dark, Arabic-first Flutter pedometer for Android 8.0+.

## Features

- Daily step count using Android's hardware step counter sensor.
- Persistent Android foreground tracking service.
- Distance and estimated active calories.
- Daily history and comparisons.
- Home-screen widget and milestone notifications.
- Offline-first local storage.

## Requirements

- Flutter stable (Dart SDK compatible with the project constraints)
- Android 8.0 (API 26) or newer

## Build

```bash
flutter pub get
flutter run
flutter build apk --release
```

The Android tracking service uses the device `TYPE_STEP_COUNTER` sensor. Background tracking depends on hardware support and Android/OEM battery policies. Distance and calories are estimates.

## License

MIT
