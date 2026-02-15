# Day 3 인증/권한 설정

## 1) 관리자 계정 준비

초기 관리자 계정이 없다면 아래로 생성:

```powershell
.\scripts\create-admin.ps1 -Email "admin@example.com" -Name "Admin" -GeneratePassword -Initial
```

등록 기본 권한을 `Editor`로 적용:

```powershell
.\scripts\configure-registration-role.ps1 -RoleName "Editor"
```

## 2) OAuth 앱 생성 (Google, GitHub)

콜백 URL 등록:

- GitHub: `http://localhost:6875/login/service/github/callback`
- Google: `http://localhost:6875/login/service/google/callback`

`APP_URL`이 바뀌면 콜백 URL도 동일하게 변경해야 함.

`APP_URL` 기준 콜백 URL 자동 확인:

```powershell
.\scripts\show-callback-urls.ps1
```

## 3) `.env` 설정

```env
GITHUB_APP_ID=<client id>
GITHUB_APP_SECRET=<client secret>
GITHUB_AUTO_REGISTER=true

GOOGLE_APP_ID=<client id>
GOOGLE_APP_SECRET=<client secret>
GOOGLE_AUTO_REGISTER=true
```

스크립트로 입력:

```powershell
.\scripts\set-oauth-env.ps1 `
  -GithubAppId "<github client id>" `
  -GithubAppSecret "<github client secret>" `
  -GoogleAppId "<google client id>" `
  -GoogleAppSecret "<google client secret>"
```

## 4) 재기동

```powershell
docker compose down
docker compose up -d
```

## 5) BookStack 관리자 화면 역할 설정

1. `Settings > Registration`으로 이동
2. `Enable registration` 활성화
3. `Default user role after registration`을 `Editor`로 설정
4. 저장
5. `Roles & Permissions`에서 `Editor`, `Viewer` 권한 확인

스크립트를 썼다면 위 값이 이미 반영되어 있을 수 있음.

## 6) 체크포인트 C 검수 항목

1. GitHub 로그인 성공
2. Google 로그인 성공
3. 첫 로그인 시 자동 가입
4. 신규 계정의 기본 역할이 `Editor`
5. 리비전 히스토리로 롤백 가능

로그인 페이지 버튼 확인:

```powershell
.\scripts\check-login-providers.ps1
```
