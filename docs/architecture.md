# 아키텍처와 데이터 모델

## 원칙

- UI는 `scripts/ui`, 게임 모델은 `scripts/models`, 게임 규칙은 `scripts/services`에 둡니다.
- 경기 엔진은 Godot UI 노드에 의존하지 않습니다.
- 생성·경기 밸런스는 `data/*.json`에서 관리합니다.
- 저장 데이터는 JSON으로 직렬화 가능한 모델 구조를 유지합니다.

## 주요 구성

| 영역 | 파일 | 역할 |
| --- | --- | --- |
| 선수 | `scripts/models/player.gd` | 능력치, 투·타, 포지션, 종합 능력치 |
| 선수단 | `scripts/models/team.gd` | 명단, 타순, 추천 타순, 직렬화 |
| 경기 상태 | `scripts/models/game_state.gd` | 점수와 이닝별 득점 |
| 선수 생성 | `scripts/services/player_generator.gd` | 설정 기반 랜덤 선수단 생성 |
| 경기 엔진 | `scripts/services/game_engine.gd` | 타석 단위 확률 시뮬레이션 |
| UI | `scripts/ui/*.gd` | 명단, 상세, 타순, 경기 결과 |
| 저장 API | `server/index.js` | 로그인 쿠키 검증 후 `nine.saves`에 JSON 저장 |

## 선수와 팀 저장 형식

`Player`는 내부적으로 영어 변수명을 사용하며 UI에는 한글 능력치 이름을 사용합니다. 모든 능력치는 기본적으로 1~100 범위입니다.

`Team.to_dict()`는 학교명, 선수 목록, `batting_order`(선수 ID 9개)를 반환합니다. `Team.from_dict()`는 이전 저장 데이터에 타순이 없더라도 선수단을 복원할 수 있습니다.

## 타순 추천

자동 편성은 야수의 컨택, 파워, 선구안, 주력에 컨디션·피로도를 반영해 상위 8명을 우선 선택하고, 가장 종합 능력치가 높은 투수를 9번에 둡니다. 추천은 확정이 아니며 사용자가 변경한 뒤 저장합니다.

## 경기 엔진

`GameEngine.simulate_game(away, home)`은 9이닝을 기본으로 하며 동점이면 최대 12이닝까지 진행합니다. 매 타석은 삼진, 볼넷, 단타, 2루타, 3루타, 홈런, 아웃 중 하나로 결정됩니다. 타자 능력치와 상대 선발투수의 구위·제구가 확률에 반영됩니다.

현재 엔진은 MVP용 간략화 규칙입니다. 병살, 도루, 희생타, 투수 교체, 수비 능력치, 개별 경기 기록은 다음 단계 대상입니다.
