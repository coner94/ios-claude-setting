# 실행 루프

Claude가 태스크를 자율적으로 수행할 때 따르는 실행 사이클이다.

## 실행 사이클

```
SELECT → PLAN → BRANCH → RED → GREEN → REFACTOR → VERIFY → COMMIT → PROGRESS → NEXT
```

### 1. SELECT
- `planner` 에이전트를 호출하여 현재 상태를 파악한다
  - planner가 tracking/BACKLOG.md, tracking/PROGRESS.md, plans/를 읽고 다음 태스크를 선택한다
- planner의 보고를 받아 메인 Claude가 tracking/BACKLOG.md의 상태를 `IN_PROGRESS`로 업데이트한다

### 2. PLAN
- `planner` 에이전트로 구현 계획을 수립한다
- 사용자 확인을 받은 뒤 `/plan-write` 스킬로 저장한다
- 이미 계획이 있으면 건너뛴다

### 3. BRANCH
- `git` 에이전트로 `git-flow.md` 규칙에 따라 브랜치를 생성한다
- 이미 작업 브랜치에 있으면 건너뛴다

### 4. RED (테스트 작성)
- `tester` 에이전트로 실패하는 테스트를 작성한다
- 테스트가 실패하는 것(Red 상태)을 확인한다

### 5. GREEN (구현)
- 테스트를 통과시키기 위한 최소한의 코드를 작성한다
- Gate 1(빌드) + Gate 3(테스트) 통과를 확인한다

### 6. REFACTOR (선택)
- 코드 품질 개선이 필요하면 `refactorer` 에이전트를 호출한다
- Gate 1 + Gate 2 + Gate 3 통과를 확인한다
- 불필요하면 건너뛴다

### 7. VERIFY
- `quality-gates.md`의 해당 게이트를 실행한다
- 실패 시 원인을 분석하고 수정한다 (최대 3회)
- 3회 실패 시 BLOCKED → 사용자에게 보고

### 8. COMMIT
- `git` 에이전트로 커밋한다
- 커밋 메시지는 `git-flow.md` 컨벤션을 따른다
- 다중 태스크 시 태스크별로 커밋한다

### 9. PROGRESS
- 메인 Claude가 직접 수행한다 (planner를 호출하지 않는다):
  - 계획 파일의 완료된 태스크를 `[x]`로 체크한다
  - tracking/BACKLOG.md의 태스크를 `DONE`으로 표시한다
  - tracking/PROGRESS.md의 현재 상태를 업데이트한다

### 10. NEXT
- 다음 태스크가 있으면 Step 4(RED)로 돌아간다
- 모든 태스크 완료 시 `git` 에이전트로 푸시 + PR 생성
- `reviewer` 에이전트로 최종 리뷰 (선택)

## 새 대화 시작 시

1. `planner` 에이전트를 호출하여 상태를 파악한다 (Step 0)
   - planner가 tracking/PROGRESS.md, tracking/BACKLOG.md, plans/를 분석한다
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

## 컨텍스트 관리

- 컨텍스트 사용량이 40%를 초과하면 사용자에게 알린다
- 현재까지의 진행 상황을 tracking/PROGRESS.md에 기록한다
- 새 대화에서 이어서 작업할 수 있도록 충분한 정보를 남긴다
