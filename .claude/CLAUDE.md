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

## 컨벤션
- `.claude/rules/swift-style.md` — Swift 코드 컨벤션
- `.claude/rules/testing.md` — Swift Testing 기반 테스트 규칙
- `.claude/rules/git-flow.md` — Git Flow 브랜치 전략, 커밋 컨벤션
- `.claude/rules/pr-template.md` — PR 작성 규칙
