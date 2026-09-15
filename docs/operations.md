# 운영·배포 가이드

## 웹 구성

운영 웹은 Caddy가 `nine.elcherlab.com`을 제공하고 `/api/*` 요청을 Project Nine Node 서버로 프록시합니다. 정적 Godot Web 빌드의 문서 루트는 `export/web`입니다.

Godot Web 기본 HTML은 인라인 부트스트랩 스크립트를 사용합니다. CSP를 적용한 운영 환경에서는 내보낼 때마다 해당 스크립트의 SHA-256 해시를 CSP `script-src`에 갱신해야 합니다. `unsafe-inline`을 추가하지 않습니다.

## 인증과 저장

- 웹 로그인: `scripts/web/project-nine-auth.js`
- API: `/api/me`, `/api/save`
- 서버: `server/index.js`
- 데이터베이스: 로컬 PostgreSQL `nine.saves` JSONB 저장

인증 비밀값과 데이터베이스 환경 변수는 저장소에 넣지 않습니다. 운영 환경에서는 systemd `EnvironmentFile` 또는 별도 보안 설정으로 제공해야 합니다.

## 백업

`scripts/server/backup_local_postgres.sh`은 로컬 PostgreSQL을 custom dump + gzip 형태로 백업하고 14일보다 오래된 백업을 정리합니다. 관련 systemd service/timer 예시도 `scripts/server`에 있습니다.

## 배포 전 확인

```bash
godot4 --headless --path . --script res://tests/test_models.gd
godot4 --headless --path . --export-release Web export/web/index.html
```

배포 후에는 다음을 확인합니다.

- `https://nine.elcherlab.com`이 HTTPS로 응답하는지
- `index.wasm`의 Content-Type이 `application/wasm`인지
- `/api/health`가 정상인지
- CSP, HSTS, `X-Content-Type-Options` 헤더가 유지되는지
