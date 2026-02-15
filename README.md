# Movie Journal 번역 협업 워크스페이스

Jonas Mekas의 *Movie Journal* 공동 번역/열람 사이트를 BookStack으로 구축하는 프로젝트입니다.

## 현재 상태

- Day 1 기획 문서화 완료.
- Day 2 로컬 인프라 구성 파일 작성 완료.
- Docker Compose로 BookStack/MariaDB 기동 확인 완료.

## 구성 파일

- `docs/implementation-plan.md`: 7일 구축 일정과 체크포인트
- `docs/day1-foundation.md`: 권한 정책, 메타데이터, 페이지 템플릿
- `docs/day2-runbook.md`: 로컬 스택 실행 절차
- `docs/day3-auth-role.md`: Google/GitHub OAuth 및 역할 설정
- `docs/day4-frontend-and-ia.md`: 책 스타일 테마/정보구조 적용
- `docs/wiki-policy-benchmark.md`: 대표 위키 정책 벤치마크와 권한 권고안
- `docs/server-and-docker-basics.md`: 동적 사이트/서버/Docker 기초 설명
- `docker-compose.yml`: BookStack + MariaDB 스택
- `docker-compose.external-db.yml`: 외부 MariaDB 사용 시 BookStack 단독 스택
- `.env.example`: 환경 변수 템플릿
- `scripts/bootstrap.ps1`: `.env` 생성(APP_KEY/DB 비밀번호 자동 생성)
- `scripts/validate-env.ps1`: `.env` 검증
- `scripts/backup-db.ps1`: MariaDB 백업
- `scripts/create-admin.ps1`: 관리자 계정 생성/초기화
- `scripts/promote-admin.ps1`: 지정 사용자에게 Admin 역할 부여
- `scripts/show-callback-urls.ps1`: OAuth 콜백 URL 출력
- `scripts/configure-registration-role.ps1`: 가입 기본 역할(예: Editor) 설정
- `scripts/set-oauth-env.ps1`: OAuth 앱 키를 `.env`에 반영(구글 전용 모드 지원)
- `scripts/check-login-providers.ps1`: 로그인 페이지 소셜 버튼 노출 확인
- `scripts/list-users-roles.ps1`: 사용자/역할 매핑 조회
- `scripts/apply-moviejournal-theme.ps1`: 원서 무드 테마 적용
- `scripts/seed-day4-structure.ps1`: Day 4 정보구조 자동 생성
- `theme/moviejournal-custom-head.html`: 읽기 모드 스타일/동작 커스텀 소스

## 빠른 시작

1. `.\scripts\bootstrap.ps1`
2. `.\scripts\validate-env.ps1`
3. `docker compose up -d`
4. 브라우저에서 `http://localhost:6875` 접속
