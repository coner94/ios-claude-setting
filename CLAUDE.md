# CLAUDE.md

Claude Code 하네스 진입점. 에이전트 역할 분담, 자율 실행 루프, 품질 게이트를 정의한다.

## 프로젝트 정보

프로젝트 관련 정보는 **`README.md`** 를 참조한다.

## 실행 모델

### 워크플로우

```
SELECT → PLAN → BRANCH → TDD → VERIFY → COMMIT → PROGRESS → NEXT
```

상세 → `.claude/rules/execution-loop.md`

### 에이전트 역할 순서

```
planner → git(브랜치) → tester(TDD) → reviewer → git(커밋/PR)
```

| 에이전트 | 역할 | 모델 |
|---|---|---|
| planner | 상태 파악, 요구사항 분석, 태스크 분해 | opus |
| tester | TDD 사이클(Red → Green → Refactor) 수행 | sonnet |
| reviewer | 코드 품질, 컨벤션, 잠재 버그 검토 | sonnet |
| git | 브랜치, 커밋, 푸시, PR | sonnet |
| refactorer | 동작 변경 없는 코드 개선 (요청 시에만 호출) | sonnet |
| debugger | 진단 → 수정 → 검증 (버그 발생 시에만 호출) | opus |

### 품질 게이트

| Gate | 검증 | 도구 |
|---|---|---|
| 1. 빌드 | 컴파일 성공, 경고 0 | xcodebuild |
| 2. 린트 | 스타일 위반 0 | SwiftLint |
| 3. 테스트 | 전체 통과, 새 코드 커버리지 | xcodebuild test |
| 4. 컨벤션 | Swift/Git/테스트 규칙 준수 | 수동 체크 |
| 5. PR | 300줄 이하, 템플릿 준수 | gh |

상세 → `.claude/rules/quality-gates.md`

### Hook 자동화

| 시점 | 동작 | 스크립트 |
|---|---|---|
| 커밋 전 (PreToolUse) | staged Swift 파일 SwiftLint 검증 | `.claude/scripts/lint.sh` |
| 파일 수정 후 (PostToolUse) | xcodebuild 빌드 검증 | `.claude/scripts/build.sh` |

### 프로젝트 추적

| 파일 | 역할 | 관리 주체 |
|---|---|---|
| `.claude/tracking/BACKLOG.md` | 태스크 백로그 | planner(선택) + 메인(업데이트) |
| `.claude/tracking/PROGRESS.md` | 세션 간 핸드오프 | planner(읽기) + 메인(쓰기) |
| `.claude/tracking/decisions.md` | 아키텍처 의사결정 기록 | 필요 시 기록 |

### 새 대화 시작 시

1. `planner`를 호출하여 `.claude/tracking/PROGRESS.md`, `.claude/tracking/BACKLOG.md`, `.claude/plans/`를 확인한다
2. 사용자에게 현재 상태를 요약한다
3. 이어서 작업할지 확인한다

## 규칙 및 청사진

- 규칙 → `.claude/rules/`
- 에이전트 정의 → `.claude/agents/`
- 스킬 정의 → `.claude/skills/`
