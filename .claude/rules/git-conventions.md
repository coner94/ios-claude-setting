# git-conventions

## 브랜치 구조

```
main (production)
 └── develop (integration)
      ├── feature/*
      ├── bugfix/*
      └── refactor/*
```

## 주요 브랜치

### main
- 프로덕션 배포 가능한 상태만 유지
- 직접 커밋 금지, PR 머지만 허용
- 태그로 버전 관리 (v1.0.0)

### develop
- 다음 릴리스를 위한 통합 브랜치
- feature, bugfix 브랜치의 머지 대상
- main으로부터 분기

## 작업 브랜치

### feature/*
- 새로운 기능 개발
- develop에서 분기 → develop으로 머지
- 네이밍: `feature/기능명` (예: `feature/login-screen`)

### bugfix/*
- 버그 수정
- develop에서 분기 → develop으로 머지
- 네이밍: `bugfix/버그설명` (예: `bugfix/crash-on-launch`)

### refactor/*
- 기능 변경 없는 코드 개선
- develop에서 분기 → develop으로 머지
- 네이밍: `refactor/대상` (예: `refactor/network-layer`)

### release/*
- 릴리스 준비 (버전 번호 업데이트, 최종 버그 수정)
- develop에서 분기 → main과 develop 양쪽에 머지
- 네이밍: `release/버전` (예: `release/1.2.0`)

### hotfix/*
- 프로덕션 긴급 수정
- main에서 분기 → main과 develop 양쪽에 머지
- 네이밍: `hotfix/설명` (예: `hotfix/payment-error`)

## 워크플로우

### 기능 개발
```
1. develop에서 feature/* 분기
2. 작업 완료 후 PR 생성 (base: develop)
3. 코드 리뷰 후 squash merge
4. feature 브랜치 삭제
```

### 릴리스
```
1. develop에서 release/* 분기
2. 버전 번호 업데이트, 최종 QA
3. main으로 머지 + 태그 생성
4. develop으로 역머지
5. release 브랜치 삭제
```

### 핫픽스
```
1. main에서 hotfix/* 분기
2. 수정 후 main으로 머지 + 태그 생성
3. develop으로 역머지
4. hotfix 브랜치 삭제
```

## 커밋 컨벤션

### 형식
```
type: 간결한 설명

(선택) 본문: 변경 이유나 상세 내용
```

### 타입
| 타입 | 용도 |
|---|---|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 |
| docs | 문서 변경 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 변경 |
| style | 코드 포맷팅 |

### 예시
```
feat: 소셜 로그인 화면 추가

Apple, Google 로그인 버튼 및 인증 플로우 구현
```

## 머지 규칙

- feature → develop: **Squash Merge** (커밋 정리)
- release → main: **Merge Commit** (이력 보존)
- hotfix → main: **Merge Commit** (이력 보존)
- 머지 전 최소 1명 코드 리뷰 필수

## 태그 & 버전

- 시맨틱 버저닝: `v{major}.{minor}.{patch}`
- major: 호환성 깨지는 변경
- minor: 하위 호환 기능 추가
- patch: 하위 호환 버그 수정

## 주의사항

- main, develop 브랜치에 직접 push 금지
- 작업 브랜치는 머지 후 즉시 삭제
- 장기 미머지 브랜치는 주기적으로 develop rebase
- 충돌 발생 시 작업 브랜치에서 해결 후 머지
