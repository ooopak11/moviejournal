# Day 2 실행 가이드 (로컬 스택)

## 사전 조건

- Docker Desktop 실행 중
- `6875` 포트 사용 가능

## 초기 설정

1. `.env` 생성

```powershell
.\scripts\bootstrap.ps1
```

2. 환경 변수 검증

```powershell
.\scripts\validate-env.ps1
```

3. 소셜 로그인을 바로 쓰려면 `.env`에 OAuth 값 입력
- `GITHUB_APP_ID`, `GITHUB_APP_SECRET`
- `GOOGLE_APP_ID`, `GOOGLE_APP_SECRET`

## 서비스 시작

```powershell
docker compose up -d
```

상태 확인:

```powershell
docker compose ps
docker logs moviejournal_bookstack --tail 100
```

참고:

- 현재 구성은 OneDrive 경로 이슈를 피하기 위해 bind mount 대신 Docker named volume을 사용함.

## 접속

- URL: `http://localhost:6875`
- 첫 관리자 계정은 초기 로그인 화면에서 생성

## 중지

```powershell
docker compose down
```

## 백업

```powershell
.\scripts\backup-db.ps1
```
