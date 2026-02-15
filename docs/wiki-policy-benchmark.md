# 위키 권한 정책 벤치마크 (운영 참고)

## 왜 참고하나

현재 목표는 “로그인만 하면 빠르게 기여 가능”과 “문서 훼손 방지”를 동시에 만족하는 것이다.  
대표적인 위키들은 공통적으로 아래 원칙을 사용한다.

- 기본 편집은 열어두되, 문서/권한 보호 장치 분리
- 신뢰도(가입 기간, 기여량, 운영자 판단)에 따라 권한 승급
- 관리자 권한은 별도 그룹으로 엄격 분리

## 대표 사례 요약

1. Wikipedia
- 문서 보호(특히 semi-protection)를 통해 편집 주체를 제한한다.
- 자동 인증 사용자(autoconfirmed) 개념으로 신뢰 기준을 둔다.

2. Fandom
- 사용자 권한 그룹(예: 관리자/관료) 기반으로 권한을 관리한다.
- 권한 부여/회수는 상위 권한자가 수행한다.

3. MediaWiki 일반 운영 모델
- 사용자 권한은 `UserRights` 같은 전용 관리 절차로 변경한다.
- “자동 인증 사용자”를 별도 집합으로 분리해 기본 제한을 단계적으로 완화한다.

## 우리 프로젝트에 적용할 권한안

### 베타 1단계 (현재)

- 접근: 로그인 필수
- 가입: OAuth 자동 가입
- 기본 역할: `Editor`
- 안전장치:
  - 리비전 히스토리 상시 유지
  - 관리자만 사용자/권한 관리
  - 훼손 발생 시 즉시 롤백

### 베타 2단계 (request-confirm 전환 시)

- 기본 역할을 `Contrib`(제한 편집)로 하향
- `Contrib`는 삭제/구조 변경 금지
- 운영자가 확인 후 `Editor` 승급
- 승급 기준(예시): 누적 기여 10건 + 문제 편집 이력 없음

## BookStack에 맞춘 구현 포인트

- 기본 등록 역할은 현재 `Editor`로 유지
- 전환 시:
  - `Contrib` 역할 신설
  - `Editor`와 `Contrib` 권한 차등
  - 등록 기본값을 `Contrib`로 변경

## 참고 링크

- Wikipedia: Protection policy  
  https://en.wikipedia.org/wiki/Wikipedia:Protection_policy
- Wikipedia: User access levels (autoconfirmed 기준 설명)  
  https://en.wikipedia.org/wiki/Wikipedia:User_access_levels
- Fandom: User rights  
  https://community.fandom.com/wiki/Help:User_rights
- MediaWiki: Manual:Autoconfirmed users  
  https://www.mediawiki.org/wiki/Manual:Autoconfirmed_users
- MediaWiki: Manual:User rights  
  https://www.mediawiki.org/wiki/Manual:User_rights

