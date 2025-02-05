# Memory Atlas Client

Memory Atlas는 장소 자체를 저장하는 지도 앱이 아니라, **장소에 남은 개인의 감각과 순간을 다시 찾을 수 있게 하는 spatial memory journal**입니다. 기존 지도·장소 탐색 경험을 유지하면서 기록의 중심을 개인 기억으로 옮겼습니다.

## Product preview

| Memory Atlas overview | Journal-focused layout |
| --- | --- |
| ![Memory Atlas overview](.github/assets/portfolio/memory-atlas-overview.png) | ![Memory Atlas journal](.github/assets/portfolio/memory-atlas-journal.png) |

두 이미지는 Flutter Web production build를 직접 실행해 캡처한 화면입니다. 동일한 UI가 서버의 `/memories` 계약과 연결되어 기록 생성·재조회·삭제 상태를 유지합니다.

## Core flow

1. 주변 장소를 지도에서 탐색합니다.
2. 장소와 연결해 제목, 감각 메모를 기록합니다.
3. 기록은 `memory-atlas-server`의 `/memories` API에 저장됩니다.
4. 앱을 다시 열어도 서버 영속 저장소에서 최근 기억을 불러옵니다.
5. 기억을 삭제하면 서버 데이터와 화면 상태가 함께 반영됩니다.

네트워크가 끊기거나 서버에 접근할 수 없는 경우 기존 UI 톤을 해치지 않는 상태 안내와 재시도 동작을 제공합니다.

## Stack

- Flutter 3.47.1 / Dart 3.13.1
- Google Maps Flutter
- HTTP + WebSocket 기반 네트워크 레이어
- Provider / Riverpod / Bloc이 공존하는 기존 기능 구조
- `memory-atlas-server`의 C++20 API

## Run

현재 stable Flutter SDK를 권장합니다.

```bash
flutter pub get
flutter analyze
flutter test
flutter run \
  --dart-define=WEB_API_BASE_URL=http://localhost:8080
```

Android 에뮬레이터에서 `localhost`를 사용할 때만 API 클라이언트가 `10.0.2.2`로 변환합니다. iOS/macOS/web에서는 전달된 주소를 그대로 사용합니다.

## Web portfolio build

```bash
flutter build web --release \
  --dart-define=APP_ENV=prod \
  --dart-define=WEB_API_BASE_URL=https://memory-atlas.oosu.dev/api
```

지도 검색을 활성화하려면 별도의 Maps 키를 빌드 환경에서 주입합니다. API 키나 서버 자격 증명은 저장소에 커밋하지 않습니다.

## Product architecture

```text
Memory Atlas Home
 ├─ recent memory timeline
 ├─ moment composer
 └─ map discovery
       │
       ├─ place search/details
       └─ memory create/list/delete
                  │
                  ▼
          memory-atlas-server
```

## Design direction

기존 프로덕트의 지도 사용성, 다크 베이스, 카드 계층과 상호작용 규칙은 유지했습니다. 새 Memory Atlas 플로우 역시 기존 제품 위에 덧붙인 별도 AI 화면처럼 보이지 않도록 같은 여백·곡률·타이포그래피 밀도 안에서 구성합니다.

## Repository boundary

이 저장소는 과거 팀 서비스의 공개 배포 주소나 계정을 전제로 하지 않습니다. 앱 표시명과 포트폴리오 문서는 Memory Atlas 기준이며, 서버 계약은 `memory-atlas-server`와 함께 관리합니다.
