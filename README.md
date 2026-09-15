# Project Nine

Godot 4와 GDScript로 만드는 모바일 고교야구 감독/육성 시뮬레이션 프로토타입입니다. 기준 화면은 세로형 9:16이며 Android와 모바일 웹을 우선 지원합니다.

현재 버전은 시스템 중심의 v0.1 MVP입니다. 직접 타격·투구 조작, 3D 그래픽, 스토리, 가챠, 온라인 대전은 범위에 포함하지 않습니다.

## 현재 구현됨

- 18~25명 랜덤 선수단과 `Player`·`Team` 도메인 모델
- 선수 명단, 터치/마우스 상세 능력치, 한글 UI 폰트
- 선발 타순 구성과 추천 타순 자동 편성
- Elcherlab 통합 계정 로그인 및 선수단/타순 저장
- 로그인 전 기기별 로컬 선수단 유지
- 타석 단위 확률 기반 연습 경기 시뮬레이션과 이닝별 결과
- HTTPS, CSP, HSTS 등 웹 보안 헤더와 로컬 PostgreSQL 저장 백엔드

## 플레이 방법

1. 선수 명단을 스크롤하고 선수를 탭해 능력치를 확인합니다.
2. **선발 타순 구성**에서 `추천 타순 자동 편성` 또는 직접 선택 후 `타순 확정`을 누릅니다.
3. **연습 경기 시뮬레이션**을 눌러 랜덤 상대 학교와 경기합니다.
4. 웹에서는 우측 상단의 Elcherlab 계정 로그인 후 선수단과 타순을 계정에 저장할 수 있습니다.

## 실행과 테스트

Godot 4.5 권장입니다.

```bash
godot4 --path .
godot4 --headless --path . --script res://tests/test_models.gd
```

테스트는 능력치 범위, 선수단 규모, 타순 유효성·직렬화, 경기 점수와 최소 9이닝 진행을 검증합니다.

## 빌드

### Web

Godot Editor의 **Web** preset으로 `export/web/index.html`에 내보냅니다. 웹 배포 시 `index.html`, `.pck`, `.wasm`, 보조 JavaScript 파일을 모두 같은 문서 루트에 배치해야 합니다. 현재 운영 주소는 [nine.elcherlab.com](https://nine.elcherlab.com)입니다.

### Android

Godot Editor Settings에서 Android SDK 및 OpenJDK 17 경로를 지정한 뒤 **Android** preset에서 Debug APK를 내보냅니다. 게임 로직은 Android 고유 API에 의존하지 않습니다.

## 문서

- [아키텍처와 데이터 모델](docs/architecture.md)
- [운영·배포 가이드](docs/operations.md)
- [나눔스퀘어 네오 글꼴 고지](assets/fonts/NOTICE.md)

## 아직 구현하지 않음

- 수비 포지션 배치, 교체, 투수 교체
- 경기 기록 상세·시즌 기록·선수 성장
- 훈련, 신입생, 대회, 졸업 및 시즌 루프
- 네이티브 Android 로그인 UI와 오프라인 동기화 충돌 해결

자세한 설계 기준은 `docs/architecture.md`를 참고합니다.
