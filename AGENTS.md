# AGENTS.md

이 프로젝트에서 작업하기 전에 반드시 아래 파일들을 먼저 읽어야 한다.

## 필수 사전 로드

1. `CLAUDE.md` — 프로젝트 개요, 기술 스택, 워크플로우 진입점
2. `.claude/rules/` 하위 모든 파일 — 코드/테스트/Git/품질 게이트 규칙
3. `.claude/agents/` 하위 모든 파일 — 에이전트 역할 정의
4. `.claude/skills/` 하위 모든 `SKILL.md` — 자동화 스킬 정의
5. `.claude/blueprint/` 하위 모든 파일 — 아키텍처 및 인터페이스 청사진

## 작업 중 참조

- `.claude/tracking/PROGRESS.md` — 세션 간 진행 상태
- `.claude/tracking/BACKLOG.md` — 태스크 백로그
- `.claude/tracking/decisions.md` — 아키텍처 의사결정 기록
- `.claude/plans/` — 태스크별 구현 계획

위 파일들에 정의된 규칙과 워크플로우를 엄격히 준수한다.
