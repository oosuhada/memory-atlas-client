# Memory Atlas Client Build Guide

## Build-time configuration

- `WEB_API_BASE_URL`: Memory Atlas API origin
- `WEB_MAPS_API_KEY`: Google Maps browser key when map features are enabled on web
- `APP_ENV`: `dev` or `prod`

Development:

```bash
flutter build web --release \
  --dart-define=APP_ENV=dev \
  --dart-define=WEB_API_BASE_URL=http://localhost:8080
```

Portfolio deployment:

```bash
flutter build web --release \
  --dart-define=APP_ENV=prod \
  --dart-define=WEB_API_BASE_URL=https://memory-atlas.oosu.dev/api
```

Never hardcode Maps or infrastructure credentials in source. Validate the resulting build with `flutter analyze`, `flutter test`, and a production `flutter build web` before deployment.
