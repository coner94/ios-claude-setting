# Backlog

planner 에이전트가 태스크 선택과 우선순위를 관리한다.
메인 Claude가 상태 업데이트(TODO → IN_PROGRESS → DONE)를 수행한다.

## 상태 정의
- `TODO` — 아직 시작하지 않음
- `IN_PROGRESS` — 현재 진행 중
- `DONE` — 완료
- `BLOCKED` — 진행 불가 (사유 명시)

---

<!-- Phase 단위로 태스크를 그룹핑한다 -->

## Phase 0: {Phase 이름}

| # | 태스크 | 크기 | 상태 | 계획 파일 |
|---|---|---|---|---|
| 0-1 | {태스크 설명} | S/M/L | TODO | |
| 0-2 | {태스크 설명} | S/M/L | TODO | |

<!--
사용 예시:

## Phase 1: 로그인 기능

| # | 태스크 | 크기 | 상태 | 계획 파일 |
|---|---|---|---|---|
| 1-1 | 소셜 로그인 UI | M | DONE | plans/login-screen.md |
| 1-2 | 인증 토큰 관리 | L | IN_PROGRESS | plans/auth-token.md |
| 1-3 | 자동 로그인 처리 | S | TODO | |
-->
