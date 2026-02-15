# Day 4 프론트/정보구조 적용 가이드

## 목표

- BookStack 기본 느낌을 줄이고, `Movie Journal` 원서의 종이/활자 분위기를 반영
- 협업에 필요한 기본 정보구조(Book/Chapter/Index/Template) 선구축

## 1) 책 분위기 테마 적용

```powershell
.\scripts\apply-moviejournal-theme.ps1
```

적용 내용:

- 종이톤 배경(베이지/세피아)
- 세리프 중심 본문 타이포그래피
- 페이지 컨텐츠 영역을 종이 면처럼 보이게 처리
- 링크/버튼/카드 컬러를 원서 무드에 맞춤

## 2) Day 4 구조 자동 생성

```powershell
.\scripts\seed-day4-structure.ps1 -WithSample
```

생성 항목:

- Book: `Movie Journal`
- Chapter: `1960`~`1964`
- Top-level pages:
  - `Index by Date`
  - `Index by People`
  - `Index by Places`
  - `Index by Topics`
  - `Entry Template`
- Sample page (`1960` 챕터):
  - `1960-01-13 - On Kurosawa and Drunken Angel`

## 3) 검수 체크리스트

1. 로그인 후 홈에서 `Movie Journal` Book 보이는지
2. `Index by Date` 등 인덱스 페이지 4개 생성됐는지
3. `1960` 챕터 내 샘플 페이지가 열리는지
4. 모바일 화면에서 본문 줄 길이/가독성 괜찮은지

## 4) 다음 단계 (Day 5)

- 원문/번역 2열 레이아웃 패턴을 엔트리 템플릿에 반영
- 날짜 기반 페이지를 실제 데이터로 10~20개 확장
- 태그 규칙(인물/장소/토픽) 팀 내 고정

