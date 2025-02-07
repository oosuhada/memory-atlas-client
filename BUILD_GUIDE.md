# CherryRecorder Client Build Guide

## Build-time configuration

- `WEB_API_BASE_URL`: CherryRecorder server HTTP origin
- `WEB_MAPS_API_KEY`: Google Maps browser key for web map rendering
- `GOOGLE_MAPS_API_KEY`: native Google Maps key when required by the target platform
- `APP_ENV`: `dev` or `prod`

Development example:

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=WEB_API_BASE_URL=http://localhost:8080
```

iOS Simulator build:

```bash
flutter build ios --simulator --debug --no-codesign
```

Web build:

```bash
flutter build web --release \
  --dart-define=APP_ENV=prod \
  --dart-define=WEB_API_BASE_URL=https://example.invalid/api
```

Do not hardcode Maps keys or infrastructure credentials in source control.
