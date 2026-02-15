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
- 페이지 읽기 모드에서 좌/우 사이드바 축소
- 읽기 모드에서 `Source Text`, `Editorial Notes`, `Related Entries` 자동 숨김
- 문서 하단에 작성자/생성 시각/수정 시각 메타정보를 은은하게 표시

테마 소스 파일:

- `theme/moviejournal-custom-head.html`

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

## 편집자 노트

- 편집 화면(`.../edit`)에서는 모든 섹션이 그대로 보임
- 읽기 화면에서는 한국어 번역 중심으로 보이며, 편집 보조 섹션은 자동으로 숨겨짐
