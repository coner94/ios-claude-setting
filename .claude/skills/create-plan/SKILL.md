---
name: create-plan
description: 기능명 기반으로 추적 파일 3종을 생성한다.
allowed-tools: Read, Glob, Grep, Write, Edit
---

# create-plan — 추적 파일 생성

## When to Activate

- planner 에이전트가 계획 저장을 요청할 때
- 사용자가 `/create-plan`으로 직접 호출할 때

## 인자

- `$ARGUMENTS`: 기능명 (필수, kebab-case)
  - 예: `/create-plan login-screen`

---

## 생성 위치

`.claude/tracking/{기능명}/` 아래에 3개 파일을 생성한다.
이미 폴더가 있으면 사용자에게 확인한다.

---

## BACKLOG.md

```markdown
# {기능명} Backlog

## 상태 정의
- `TODO` — 아직 시작하지 않음
- `IN_PROGRESS` — 현재 진행 중
- `DONE` — 완료
- `BLOCKED` — 진행 불가 (사유 명시)

---

## Phase 1: {Phase 이름}

| # | 태스크 | 크기 | 상태 |
|---|---|---|---|
| 1-1 | {태스크 설명} | S/M/L | TODO |
```

## PROGRESS.md

```markdown
# {기능명} Progress

세션 간 핸드오프를 위한 진행 상태 파일.

---

## 현재 상태
- 마지막 완료: (없음)
- 진행 중: (없음)
- 다음 태스크: (없음)

## 세션 기록

### Session 1 (YYYY-MM-DD)
- 완료: {완료한 태스크 목록}
- 진행 중: {아직 끝나지 않은 태스크}
- 다음: {다음에 이어서 할 작업}
- 참고: {다음 세션에서 알아야 할 컨텍스트}
```

## decisions.md

```markdown
# {기능명} Architecture Decisions

기술적 의사결정을 기록한다. 왜 그렇게 결정했는지(Why)를 중심으로 작성한다.

---

## AD-001: {결정 제목}
- **일자**: YYYY-MM-DD
- **상태**: 채택 / 폐기 / 검토중
- **결정**: {무엇을 선택했는가}
- **이유**: {왜 이 선택을 했는가}
- **대안**: {검토했지만 선택하지 않은 것들}
- **영향**: {이 결정이 영향을 미치는 범위}
```
