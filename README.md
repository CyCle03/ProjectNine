# Project Nine

Godot 4 기반 모바일 고교야구 감독/육성 시뮬레이션 프로토타입입니다. v0.1은 선수·팀 데이터, 랜덤 선수단 생성, 반응형 선수단/상세 UI를 포함합니다.

## PC 실행

Godot 4에서 `project.godot`를 열고 실행하거나 다음을 사용합니다.

```bash
godot4 --path .
```

## 테스트

```bash
godot4 --headless --path . --script res://tests/test_models.gd
```

## Web 배포

Godot에서 Web preset을 선택해 `export/web/index.html`로 내보낸 뒤 해당 디렉터리의 모든 파일을 웹 서버 문서 루트에 업로드합니다. `nine.elcherlab.com`에는 HTTPS와 WebAssembly 파일 제공 설정이 필요합니다.

## Android 테스트 빌드

Editor Settings에서 Android SDK와 OpenJDK 17 경로를 지정하고, Export에서 Android preset을 선택해 Debug APK를 내보냅니다. 게임 로직은 Android 고유 API에 의존하지 않습니다.
