# iOS Claude Setting

iOS 프로젝트에서 Claude Code를 효과적으로 활용하기 위한 설정 모음.
에이전트, 스킬, 규칙, 품질 게이트로 구성된 자율 실행 워크플로우를 제공한다.

---

## 실행 흐름

```
SELECT → PLAN → BRANCH → TDD → GATE → COMMIT → PROGRESS → NEXT
```

각 단계의 상세 정의는 `.claude/rules/workflow.md`를 참조한다.

---

## 디렉토리 구조

```
.claude/
├── agents/          # 자율 실행 에이전트
├── rules/           # 컨벤션 및 실행 규칙
├── skills/          # 슬래시 커맨드 스킬
├── scripts/         # 빌드/린트 자동화 스크립트
├── tracking/        # 태스크 추적 (기능별 하위 디렉토리)
└── docs/            # 구현 완료 스펙 문서
```

---

## Agents

자율적으로 판단하고 실행하는 전문 에이전트.

| 에이전트 | 역할 |
|---|---|
| `planner` | 아키텍처 설계, 태스크 분해, 의존성 식별 |
| `git-manager` | 브랜치 생성, 커밋, 푸시, PR 생성 |
| `debugger` | 에러 분석, 근본 원인 추적, 재현 테스트 작성 |
| `refactoring` | 코드 중복 제거, 구조 개선 (기존 동작 유지) |

---

## Skills

`/스킬명`으로 직접 호출하는 재사용 가능한 절차.

| 스킬 | 설명 |
|---|---|
| `/tdd-workflow` | TDD 사이클 (Red → Green → Refactor) 수행 |
| `/code-review` | 코드 품질, 안전성, 단순성 검토 및 최적화 의견 제시 |
| `/pull-request` | PR 생성 (제목, 본문, base 브랜치 자동 구성) |
| `/create-plan` | 기능명 기반 추적 파일 3종 생성 |
| `/handoff` | 구현 완료 후 스펙 문서를 `docs/`에 저장 |
| `/swiftui-patterns` | SwiftUI 아키텍처, 상태 관리, 성능 최적화 패턴 |
| `/swift-actor-persistence` | Actor 기반 thread-safe 데이터 영속성 패턴 |
| `/swift-protocol-di-testing` | Protocol 기반 DI와 Swift Testing 테스트 패턴 |

---

## Rules

Claude가 항상 따르는 컨벤션 기준 문서.

| 파일 | 설명 |
|---|---|
| `workflow.md` | 자율 실행 사이클 정의 |
| `quality-gates.md` | Gate 1~6 품질 게이트 정의 및 실패 정책 |
| `git-conventions.md` | 브랜치 전략, 커밋 컨벤션, 머지 규칙 |
| `swift-style.md` | Swift 코드 스타일 및 네이밍 규칙 |
| `swift-testing.md` | Swift Testing 기반 테스트 작성 규칙 |

---

## Quality Gates

| 게이트 | 종류 | 설명 |
|---|---|---|
| Gate 1: Build | 자동 | `xcodebuild build` 성공, 경고 0개 |
| Gate 2: Lint | 자동 | `swiftlint --strict` violation 0개 |
| Gate 3: Unit Test | 자동 | 전체 테스트 통과, 새 코드 테스트 존재 |
| Gate 4: Optimization | 수동 | 메인 스레드 블로킹, 무거운 연산 확인 |
| Gate 5: Safety | 수동 | 동시성, 강제 언래핑, 메모리 릭 확인 |
| Gate 6: Code Review | 스킬 | `/code-review` 실행, Critical·Warning 수정 |

---

## Tracking

기능별 작업 상태를 `.claude/tracking/{기능명}/`에 기록한다.

| 파일 | 역할 |
|---|---|
| `BACKLOG.md` | 태스크 목록 및 상태 |
| `PROGRESS.md` | 세션 간 핸드오프 |
| `decisions.md` | 아키텍처 의사결정 기록 |
