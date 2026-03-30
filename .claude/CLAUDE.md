# iOS Claude Setting

## 개요
iOS 앱 프로젝트 시작 시 공통으로 사용하는 Claude Code 설정 템플릿

## 기술 스택
- 언어: Swift 6
- UI: SwiftUI + Observation 프레임워크
- 동시성: Swift Concurrency (async/await, Actor)
- 최소 지원 버전: iOS 17.0
- 프로젝트 관리: Tuist (선택)
- 의존성 매니저: SPM

## 아키텍처
{프로젝트에 맞게 작성}

## 주요 의존성
- 네트워크: {Alamofire, Moya}
- DI: {Swinject}
- 분석: {Firebase (Google Analytics)}

## 개발 워크플로우

기능 개발 시 아래 순서를 따른다.

1. **계획** — `planner` 에이전트로 구현 계획을 수립하고 사용자 확인을 받은 뒤, `/plan-write` 스킬로 `.claude/plans/{기능명}.md`에 저장한다.
2. **브랜치 생성** — `git` 에이전트로 작업 브랜치를 생성한다
3. **테스트 작성 (Red)** — `tester` 에이전트로 실패하는 테스트를 먼저 작성한다
4. **구현 (Green)** — 테스트를 통과시키기 위한 최소한의 코드를 직접 작성한다
5. **리팩토링** — 코드를 개선한다. 필요시 `refactorer` 에이전트를 호출한다
6. **커밋/푸시/PR** — `git` 에이전트로 커밋, 푸시, PR 생성을 수행한다

- 태스크가 여러 개면 태스크별로 3~6을 반복한다
- 태스크 완료 시 계획 파일의 체크박스를 `[x]`로 업데이트한다
- 버그 수정 시 `debugger` 에이전트를 사용한다 (진단 → 수정 → 검증)
- PR 생성 후 `reviewer` 에이전트로 코드 리뷰를 수행할 수 있다
- **새 대화 시작 시** `.claude/plans/`에 진행 중인 계획이 있으면 확인하고 이어서 작업한다

## 컨벤션
- `.claude/rules/swift-style.md` — Swift 코드 컨벤션
- `.claude/rules/testing.md` — Swift Testing 기반 테스트 규칙
- `.claude/rules/git-flow.md` — Git Flow 브랜치 전략, 커밋 컨벤션
- `.claude/rules/pr-template.md` — PR 작성 규칙
