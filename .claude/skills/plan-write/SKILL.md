---
name: plan-write
description: 구현 계획을 정해진 템플릿으로 작성하고 .claude/plans/에 저장한다.
allowed-tools: Read, Glob, Grep, Write, Edit
---

# plan-write — 구현 계획 작성 및 저장

planner 에이전트의 분석 결과를 `.claude/plans/`에 저장한다.

## When to Activate

- planner 에이전트가 설계 분석을 완료하고 계획 저장을 요청할 때
- 사용자가 `/plan-write`로 직접 호출할 때

## 인자

- `$ARGUMENTS`: 기능명 (필수)
  - 예: `/plan-write login-screen`

---

## 템플릿

```markdown
# {plan name}

## 개요
- 구현할 기능에 대한 1~2줄 요약

## 태스크
- [ ] Task 1: {제목} (S/M/L)
- [ ] Task 2: {제목} (S/M/L)
- [ ] Task 3: {제목} (S/M/L)
```

---

## 저장 규칙

- `.claude/plans/{기능명}.md`에 저장한다 (kebab-case)
- 태스크 완료 시 `[x]`로 업데이트한다
- 모든 태스크 완료 시 파일명에 `_done` 접미사를 붙인다
- 이미 동일 파일이 있으면 사용자에게 확인한다
