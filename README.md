# CherryRecorder Client

CherryRecorder Client는 장소와 기억을 지도 위에 기록하는 Flutter 애플리케이션입니다. 장소 탐색, 메모, 태그와 실시간 메시징을 하나의 모바일 경험으로 연결합니다.

| Splash | Map entry |
| --- | --- |
| ![CherryRecorder splash](.github/assets/portfolio/cherryrecorder-restored-splash.png) | ![CherryRecorder map](.github/assets/portfolio/cherryrecorder-restored-map.png) |

## 주요 기능

- 현재 위치 기반 지도 탐색
- 주변 장소 및 텍스트 검색
- 장소 상세 정보와 사진 조회
- 장소별 메모 작성 및 조회
- 태그 기반 메모 탐색
- HTTP API와 WebSocket 기반 서버 통신
- 로컬 저장소를 활용한 상태 유지

## Stack

- Flutter / Dart
- Google Maps Flutter
- Provider / Riverpod / Bloc
- HTTP / WebSocket
- SQLite / local persistence

## 시작하기

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Google Maps와 Places 기능은 플랫폼별 API key 설정이 필요합니다. key는 저장소가 아닌 로컬 플랫폼 설정 또는 환경변수로 관리하세요.

## 서버 연동

클라이언트는 별도의 C++ 백엔드와 통신합니다.

- HTTP: health/status, Maps key, Places nearby/search/details/photo
- WebSocket: 실시간 채팅과 메시징

Android Emulator에서 로컬 서버를 사용할 경우 `localhost` 대신 `10.0.2.2`를 사용할 수 있습니다.
