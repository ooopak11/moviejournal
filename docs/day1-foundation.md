# Day 1 기획 확정

## 1) 접근/운영 정책

출판 전(비공개) 운영 정책:

- 비로그인 사용자: 접근 불가
- 로그인 사용자(Google/GitHub): 자동 가입 후 편집 가능
- 관리자: 사용자/역할/롤백 관리

운영 안전장치:

- 모든 문서 리비전 히스토리 유지
- 저장 시 편집 요약 입력 권장
- 문제 편집은 롤백 우선 대응

## 2) 역할 모델 (BookStack)

기본 역할:

- `Admin`: 시스템 전체 관리
- `Editor`: 문서 생성/수정/삭제
- `Viewer`(선택): 읽기 전용 검수자

현재 합의:

- 베타 단계에서 자동 가입 기본 역할은 `Editor`
- 추후 `request-confirm` 구조(승인형 승급)로 전환 가능
- 운영 근거는 `docs/wiki-policy-benchmark.md` 기준 적용

## 3) 엔트리 메타데이터 모델

각 저널 페이지에 아래 항목 포함:

- `Entry Date`: `YYYY-MM-DD` (필수)
- `Period Label`: 날짜 불명확 시 보조 표기 (예: `1966-01 (approx.)`)
- `Source Page`: 원서 페이지
- `People`: 인물 태그(쉼표 구분)
- `Places`: 장소 태그(쉼표 구분)
- `Topics`: 주제 태그(쉼표 구분)
- `Translation Status`: `draft` | `review` | `final`

태그 규칙:

- 다어절은 소문자 + 하이픈
- 가급적 단수형
- 기존 태그 우선 재사용

## 4) 정보 구조

기본 구조:

- Book: `Movie Journal`
- Chapter: 연도/구간 단위
- Page: 일자별 엔트리

내비게이션 페이지:

- `Index by Date`
- `Index by People`
- `Index by Places`
- `Index by Topics`

듬성듬성한 날짜 구간 처리:

- 맥락이 필요한 긴 공백만 `No Entry` 노트 추가
- 일반 누락 날짜는 생략

## 5) 페이지 템플릿

고정 섹션 순서:

1. 메타데이터
2. 원문
3. 번역문
4. 편집 노트
5. 관련 엔트리

```md
# [Entry title]

Entry Date: 1966-01-12
Period Label:
Source Page: p. 42
People:
Places:
Topics:
Translation Status: draft

## Source Text
[Original text]

## Korean Translation
[Translated text]

## Editorial Notes
- 용어 선택 근거
- 번역 쟁점

## Related Entries
- [[1966-01-11]]
- [[1966-01-15]]
```

## 6) Checkpoint A 승인 항목

1. 비공개 베타 정책(`로그인 필수`, `자동 Editor 부여`)
2. 메타데이터 키/명명
3. 빈 날짜 구간 처리 규칙
4. 엔트리 템플릿 섹션 구조
