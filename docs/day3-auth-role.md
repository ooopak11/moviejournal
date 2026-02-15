# Day 3 인증/권한 설정

## 1) OAuth 앱 생성 (Google, GitHub)

콜백 URL 등록:

- GitHub: `http://localhost:6875/login/service/github/callback`
- Google: `http://localhost:6875/login/service/google/callback`

`APP_URL`이 바뀌면 콜백 URL도 동일하게 변경해야 함.

## 2) `.env` 설정

```env
GITHUB_APP_ID=<client id>
GITHUB_APP_SECRET=<client secret>
GITHUB_AUTO_REGISTER=true

GOOGLE_APP_ID=<client id>
GOOGLE_APP_SECRET=<client secret>
GOOGLE_AUTO_REGISTER=true
```

## 3) 재기동

```powershell
docker compose down
docker compose up -d
```

## 4) BookStack 관리자 화면 역할 설정

1. `Admin`, `Editor`, `Viewer` 역할 확인/생성
2. `Editor`에 페이지 생성/수정 권한 부여
3. `Viewer`는 읽기 전용 유지
4. 베타 단계 기본 등록 역할을 `Editor`로 설정

## 5) 체크포인트 C 검수 항목

1. GitHub 로그인 성공
2. Google 로그인 성공
3. 첫 로그인 시 자동 가입
4. 신규 계정의 기본 역할이 `Editor`
5. 리비전 히스토리로 롤백 가능
