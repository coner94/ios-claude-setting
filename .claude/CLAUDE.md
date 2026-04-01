# iOS Claude Setting

## 개요

iOS 앱 프로젝트를 위한 Claude Code 하네스 설정.
에이전트 역할 분담, 자율 실행 루프, 품질 게이트, 설계 청사진을 통해 일관된 개발 워크플로우를 제공한다.

## 기술 스택

- 언어: Swift 6
- UI: SwiftUI + Observation 프레임워크
- 동시성: Swift Concurrency (async/await, Actor)
- 최소 지원 버전: iOS 17.0
- 프로젝트 관리: Tuist (선택)
- 의존성 매니저: SPM

## 아키텍처

- 디렉토리 구조 및 의존성 규칙 → `blueprint/package-structure.md`
- Protocol 템플릿 및 공통 타입 → `blueprint/interfaces.md`
- 의사결정 기록 → `tracking/decisions.md`

## 주요 의존성

- 네트워크: {Alamofire, Moya}
- DI: {Swinject}
- 분석: {Firebase (Google Analytics)}

## 시작하기

- **기존 프로젝트에 적용**: `/onboard` — 프로젝트를 스캔하여 blueprint, CLAUDE.md, 설정을 자동 초기화
- **새 프로젝트**: blueprint 템플릿을 직접 채우고 시작

## 실행 모델

### 워크플로우

```
SELECT → PLAN → BRANCH → RED → GREEN → REFACTOR → VERIFY → COMMIT → PROGRESS → NEXT
```

상세 → `rules/execution-loop.md`

### 에이전트 역할 순서

```
planner → git(브랜치) → tester(Red) → 구현(Green) → refactorer → reviewer → git(커밋/PR)
```

| 에이전트 | 역할 | 모델 |
|---|---|---|
| planner | 상태 파악, 요구사항 분석, 태스크 분해 | opus |
| tester | TDD Red Phase — 실패하는 테스트 작성 | sonnet |
| refactorer | 동작 변경 없는 코드 개선 | sonnet |
| reviewer | 코드 품질, 컨벤션, 잠재 버그 검토 | sonnet |
| debugger | 진단 → 수정 → 검증 | opus |
| git | 브랜치, 커밋, 푸시, PR | sonnet |

상세 → `rules/roles.md`

### 품질 게이트

| Gate | 검증 | 도구 |
|---|---|---|
| 1. 빌드 | 컴파일 성공, 경고 0 | xcodebuild |
| 2. 린트 | 스타일 위반 0 | SwiftLint |
| 3. 테스트 | 전체 통과, 새 코드 커버리지 | xcodebuild test |
| 4. 컨벤션 | Swift/Git/테스트 규칙 준수 | 수동 체크 |
| 5. PR | 300줄 이하, 템플릿 준수 | gh |

상세 → `rules/quality-gates.md`

### Hook 자동화

| 시점 | 동작 | 스크립트 |
|---|---|---|
| 커밋 전 (PreToolUse) | staged Swift 파일 SwiftLint 검증 | `scripts/lint.sh` |
| 파일 수정 후 (PostToolUse) | xcodebuild 빌드 검증 | `scripts/build.sh` |

### 프로젝트 추적

| 파일 | 역할 | 관리 주체 |
|---|---|---|
| `tracking/BACKLOG.md` | 태스크 백로그 | planner(선택) + 메인(업데이트) |
| `tracking/PROGRESS.md` | 세션 간 핸드오프 | planner(읽기) + 메인(쓰기) |
| `tracking/decisions.md` | 아키텍처 의사결정 기록 | 필요 시 기록 |

### 새 대화 시작 시

1. `planner`를 호출하여 `tracking/PROGRESS.md`, `tracking/BACKLOG.md`, `plans/`를 확인한다
2. 사용자에게 현재 상태를 요약한다
3. 이어서 작업할지 확인한다

## 컨벤션

| 규칙 | 파일 |
|---|---|
| Swift 코드 스타일 | `rules/swift-style.md` |
| Swift Testing 테스트 | `rules/testing.md` |
| Git Flow 브랜치/커밋 | `rules/git-flow.md` |
| PR 작성 | `rules/pr-template.md` |

## 디렉토리 구조

```
.claude/
├── CLAUDE.md              ← 진입점 (이 파일)
├── settings.json          ← hook, 플러그인 설정
├── agents/                ← 에이전트 정의 (6개)
├── rules/                 ← 불변 규칙 (7개)
├── skills/                ← 자동화 스킬
├── plans/                 ← 구현 계획 (태스크별)
├── blueprint/             ← 설계 청사진
├── tracking/              ← 프로젝트 추적
├── scripts/               ← hook 스크립트
└── docs/                  ← 기타 문서
```
