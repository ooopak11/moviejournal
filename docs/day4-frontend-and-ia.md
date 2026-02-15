# Day 4 프론트/정보구조 적용 가이드

## 목표

- 비로그인 사용자도 바로 읽을 수 있는 공개 열람 모드 구성
- BookStack 기본 위키 느낌을 줄이고 `Movie Journal` 원서의 종이/활자 분위기 반영
- 원저 기록 범위(`1959~1968`)에 맞춘 정보구조/목차 템플릿 구축

## 1) 책 분위기 테마 적용

```powershell
.\scripts\apply-moviejournal-theme.ps1
```

적용 내용:

- 종이톤 배경(베이지/세피아) + 세리프 중심 타이포그래피
- 읽기 페이지에서 사이드바/상단 기본 헤더 최소화
- 상단 슬라이드형 `Contents`/`Search` 패널 제공
- 읽기 화면에서 `Source Text`, `Editorial Notes`, `Related Entries` 자동 숨김
- 문서 하단에 작성자/생성 시각/수정 시각 메타정보만 은은하게 노출
- `Contents` 페이지를 원서 목차 느낌에 맞춘 전용 레이아웃으로 표시

테마 소스 파일:

- `theme/moviejournal-custom-head.html`

## 2) Day 4 구조(1959~1968) 생성

```powershell
.\scripts\seed-day4-structure.ps1 -WithSample
```

생성/갱신 항목:

- Book: `Movie Journal`
- Chapter: `1959`~`1968`
- Top-level pages:
  - `Introduction`
  - `Contents`
  - `Entry Template`
- Sample page (`1960` 챕터):
  - `1960-01-13 - On Kurosawa and Drunken Angel`

## 3) 공개 열람 모드 적용

```powershell
.\scripts\configure-public-reader-mode.ps1
```

적용 내용:

- `app-public=true` (비로그인 열람 허용)
- 홈을 `Contents` 페이지로 지정
- `Public`, `Viewer` 역할의 `content-export` 권한 제거

선택 옵션:

```powershell
.\scripts\configure-public-reader-mode.ps1 -RemoveEditorExport
```

- `Editor` 역할에서도 `content-export`를 제거하려면 위 옵션 사용

## 4) 검수 체크리스트

1. 로그아웃 상태에서 `http://localhost:6875` 접속 시 로그인 화면이 아닌 `Contents`가 보이는지
2. `Contents` 페이지에서 `Introduction` + `1959~1968` 링크가 동작하는지
3. 일반 읽기 화면에서 편집 보조 섹션(`Source Text` 등)이 숨겨지는지
4. 편집 화면(`.../edit`)에서는 숨김 없이 모든 섹션이 보이는지
5. 모바일 화면에서 본문 줄 길이/행간이 읽기 가능한지

## 편집자 노트

- 읽기 화면은 책 감상 흐름을 우선하고, 편집 액션은 최대한 전면에서 숨긴다.
- 원문은 저작권 정책에 따라 공개 화면에 노출하지 않고, 편집 권한자 컨텍스트에서만 관리한다.
