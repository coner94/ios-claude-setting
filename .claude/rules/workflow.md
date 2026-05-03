# workflow

Claude가 태스크를 자율적으로 수행할 때 따르는 실행 사이클이다.

## 실행 사이클

```
SELECT → PLAN → BRANCH → TDD → GATE → COMMIT → PROGRESS → NEXT
```

### 1. SELECT
- `planner` 에이전트를 호출하여 현재 상태를 파악한다
  - planner가 tracking/ 하위 기능별 BACKLOG.md, PROGRESS.md를 읽고 다음 태스크를 선택한다
- planner의 보고를 받아 메인 Claude가 tracking/{기능명}/BACKLOG.md의 상태를 `IN_PROGRESS`로 업데이트한다

### 2. PLAN
- `planner` 에이전트로 구현 계획을 수립한다
- 사용자 확인을 받은 뒤 `/create-plan` 스킬로 저장한다
- 이미 계획이 있으면 건너뛴다

### 3. BRANCH
- `git-manager` 에이전트로 브랜치를 생성한다
- 이미 작업 브랜치에 있으면 건너뛴다

### 4. TDD (Red → Green → Refactor)
- `tester` 에이전트로 TDD 사이클을 수행한다
  - Red: 실패하는 테스트를 먼저 작성한다
  - Green: 테스트를 통과시키기 위한 최소한의 구현을 작성한다
- Gate 1(빌드) + Gate 3(테스트) 통과를 확인한다

### 5. GATE
- `quality-gates.md`의 Gate 1~6을 순서대로 실행한다

### 6. COMMIT
- `git-manager` 에이전트로 커밋한다
- 다중 태스크 시 태스크별로 커밋한다

### 7. PROGRESS
- 메인 Claude가 직접 수행한다 (planner를 호출하지 않는다):
  - 계획 파일의 완료된 태스크를 `[x]`로 체크한다
  - tracking/{기능명}/BACKLOG.md의 태스크를 `DONE`으로 표시한다
  - tracking/{기능명}/PROGRESS.md의 현재 상태를 업데이트한다

### 8. NEXT
- 다음 태스크가 있으면 Step 4(TDD)로 돌아간다
- 모든 태스크 완료 시:
  1. `git-manager` 에이전트로 푸시 + PR 생성
  2. `/handoff` 스킬로 `docs/{기능명}.md` 문서화

## 새 대화 시작 시

1. `planner` 에이전트를 호출하여 상태를 파악한다 (Step 0)
   - planner가 tracking/ 하위 기능별 PROGRESS.md, BACKLOG.md를 분석한다
2. planner의 보고를 바탕으로 사용자에게 현재 상태를 요약한다
3. 이어서 작업할지 사용자에게 확인한다

## 에스컬레이션

아래 상황에서는 자율 실행을 중단하고 사용자에게 판단을 요청한다:
- 아키텍처 또는 모듈 구조 변경이 필요할 때
- 기술 스택 변경이 필요할 때
- 기존 API/인터페이스를 변경해야 할 때
- 동일 게이트에서 3회 연속 실패했을 때
- 계획에 없는 추가 작업이 필요할 때
- 요구사항이 모호하거나 상충할 때

## Integration with Other Rules

| 파일 | 설명 |
|---|---|
| [`quality-gates.md`](.claude/rules/quality-gates.md) | GATE 단계에서 실행하는 게이트 정의 및 실패 정책 |
