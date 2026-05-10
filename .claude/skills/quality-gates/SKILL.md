---
name: quality-gates
description: 태스크 완료 전 실행하는 품질 게이트. Gate 1~8을 순서대로 실행하고 모든 게이트를 통과해야 완료로 처리한다.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

# Quality Gates

Gate 1부터 8까지 순서대로 실행한다. 실패 시 원인을 수정하고 Gate 1부터 재실행한다.

## 출력 형식

각 단계 진입 전, 결과 확인 후, 수정 중, 재시작 시 아래 형식으로 텍스트를 출력한다. 출력을 생략하지 않는다.

| 시점 | 출력 |
|---|---|
| 스킬 시작 | `[Quality Gates] 검증을 시작합니다.` |
| 게이트 실행 | `[Gate N: {이름}] 실행합니다...` |
| 통과 | `[Gate N: {이름}] ✓ 통과` |
| 실패 | `[Gate N: {이름}] ✗ 실패 — {에러 한 줄 요약}` |
| 수정 중 | `[Gate N: {이름}] 수정 중... {수정 내용 한 줄}` |
| Gate 1 재시작 | `[Gate N: {이름}] Gate 1부터 재실행합니다.` |
| 전체 완료 | `[Quality Gates] 모든 게이트를 통과했습니다.` |
| BLOCKED | `[Quality Gates] BLOCKED — {게이트 이름} 3회 연속 실패. 사용자 판단이 필요합니다.` |

---

## Gate 1: Build

```bash
xcodebuild build -scheme {Scheme} -destination 'generic/platform=iOS Simulator' | xcpretty
```

- 통과: exit code 0, 빌드 경고 0개
- 실패: 경고 포함 모든 에러를 수정한 뒤 Gate 1 재실행

## Gate 2: Lint

```bash
swiftlint lint
```

- 통과: error 0개
- SwiftLint 미설치 시: `.claude/rules/swift-style.md` 기준으로 수동 검증
- 실패: 위반 항목 수정 후 Gate 1 재실행

## Gate 3: Unit Test

```bash
xcodebuild test -scheme {Scheme} -destination 'platform=iOS Simulator,OS=latest' | xcpretty
```

- 통과: 전체 테스트 통과, 새 코드에 대한 테스트 존재
- 실패: 테스트 수정 또는 누락 테스트 추가 후 Gate 1 재실행

## Gate 4: Optimization

변경된 코드를 직접 열어 아래 항목을 확인한다. SwiftUI를 사용하지 않는 경우 SwiftUI 렌더링 섹션은 건너뛴다.

### 핫 패스 / 알고리즘

- [ ] 반복 호출되는 경로(셀 렌더링, 스크롤, 타이머)에 O(n²) 이상의 연산이 없는가
- [ ] 루프 안에서 불필요한 객체 생성이 없는가
- [ ] 검색/입력 핸들러에 디바운스가 적용되어 있는가
- [ ] 동일 결과를 반복 계산하는 코드가 없는가 (캐싱 또는 `lazy` 고려)

### SwiftUI 렌더링

- [ ] `body` 안에서 무거운 연산이나 side effect를 수행하지 않는가
- [ ] 리스트 아이템의 `id`에 인라인 `UUID()` 같은 불안정한 값을 쓰지 않는가
- [ ] 대량 데이터를 표시할 때 `LazyVStack` / `LazyHStack` / `List`를 사용하는가
- [ ] 불필요하게 전체 뷰를 리렌더링하는 `@State` 변경이 없는가

### 이미지 / 리소스

- [ ] 이미지를 표시 크기에 맞게 리사이징하는가 (원본 대형 이미지를 그대로 쓰지 않는가)
- [ ] 반복 로드되는 리소스에 캐싱이 적용되어 있는가

이슈 발견 시: 수정 후 Gate 1 재실행

## Gate 5: Concurrency

변경된 코드를 직접 열어 아래 항목을 확인한다. 항목을 건너뛰지 않는다.

### 메인 스레드

- [ ] 메인 스레드에서 동기 I/O, 파일 읽기/쓰기, 네트워크 호출이 없는가
- [ ] `DispatchQueue.main.sync`를 사용하지 않는가
- [ ] `@MainActor` 컨텍스트 안에서 무거운 연산을 수행하지 않는가

### Swift Concurrency

- [ ] `await` 이후 actor의 상태가 바뀔 수 있음을 인지하고 재확인하는가 (Actor Reentrancy)
- [ ] actor 경계를 넘는 타입이 `Sendable`을 준수하는가
- [ ] `@unchecked Sendable`을 사용했다면 내부에서 직접 동기화(Lock, Mutex)를 보장하는가
- [ ] `static var` 전역 가변 상태가 actor로 보호되어 있는가
- [ ] 장시간 실행되는 `Task`에서 `try Task.checkCancellation()` 또는 `Task.isCancelled`를 확인하는가
- [ ] 구조적 동시성(`async let`, `TaskGroup`)을 사용할 수 있는 곳에 비구조적 `Task { }`를 쓰지 않는가

이슈 발견 시: 수정 후 Gate 1 재실행

## Gate 6: Safety

변경된 코드를 직접 열어 아래 항목을 확인한다. 항목을 건너뛰지 않는다.

### 타입 안전성

- [ ] 강제 언래핑(`!`)이 없는가 — 테스트 코드 포함. `guard let` / `if let` / `??`로 대체
- [ ] 강제 캐스팅(`as!`)이 없는가 — `as?` + 적절한 처리로 대체
- [ ] `Any` / `AnyObject`를 사용하는 경우 제네릭 또는 구체 타입으로 대체 가능한가
- [ ] 정수 연산에서 오버플로우 가능성이 있는가 — 범위가 불확실하면 범위 검증 추가

### 에러 처리

- [ ] `try?`로 에러를 묵살하지 않는가 — 무시해도 되는 경우에만 허용
- [ ] `try!`가 없는가
- [ ] 리소스(파일, 스트림, 락) 해제가 `defer`로 보장되는가
- [ ] `catch` 블록이 에러를 단순 출력만 하고 복구 로직이 없는 경우, 의도적인지 확인한다

### ARC / 메모리

- [ ] `@escaping` 클로저에서 `self`를 강하게 캡처해 순환 참조가 생기지 않는가 (`[weak self]` / `[unowned self]` 적용)
- [ ] `delegate` 프로퍼티가 `weak`로 선언되어 있는가
- [ ] `unowned`를 사용했다면 캡처 대상의 생명주기가 반드시 더 길다고 보장되는가 — 불확실하면 `weak`로 교체
- [ ] `NotificationCenter` 옵저버를 `deinit` 또는 명시적 해제 시점에 `removeObserver` 하는가
- [ ] `Timer`를 `deinit`에서 `invalidate()` 하는가
- [ ] 완료 핸들러(`completion:`)가 객체를 강하게 캡처한 채 장기간 살아있지 않는가
- [ ] 메모리 독점 접근 위반이 없는가 — 동일 변수를 in-out으로 동시에 넘기거나 읽기/쓰기가 겹치지 않는가

이슈 발견 시: 수정 후 Gate 1 재실행

## Gate 7: Design

변경된 코드를 직접 열어 아래 항목을 확인한다.

### SOLID

- [ ] 하나의 타입이 하나의 책임만 지는가 — 여러 역할이 섞여 있으면 분리한다 (SRP)
- [ ] 기능 추가 시 기존 타입을 수정하지 않고 확장할 수 있는 구조인가 (OCP)
- [ ] 프로토콜 채택 타입이 프로토콜의 계약을 완전히 이행하는가 (LSP)
- [ ] 프로토콜이 불필요한 메서드를 강제하지 않는가 — 비대한 프로토콜은 목적별로 분리한다 (ISP)
- [ ] 구체 타입을 직접 생성하지 않고 프로토콜 또는 생성자 주입으로 의존성을 받는가 (DIP)

### POP / 의존성

- [ ] 상속보다 프로토콜 채택과 컴포지션을 우선하는가
- [ ] 모듈 또는 타입 간 순환 의존성이 없는가

### 테스트 가능성

- [ ] 외부 시스템(네트워크, DB, 파일)을 주입받아 Mock으로 대체 가능한가
- [ ] 메서드 내부에서 싱글턴에 직접 접근하지 않는가 (`UserDefaults.standard`, `URLSession.shared` 등 하드코딩 금지)
- [ ] 타입을 단독으로 인스턴스화해서 테스트할 수 있는가

이슈 발견 시: 수정 후 Gate 1 재실행

## Gate 8: Code Review

`/code-review` 스킬을 실행하여 이번 변경 코드에 대한 리뷰를 받는다.

- 리뷰 결과에서 Critical / Warning 이슈를 확인한다
- 이슈가 있으면 직접 수정하고 Gate 1부터 재실행한다.
- 리뷰 결과가 Approve이거나 Suggestion만 남으면 통과로 처리한다

---

## 실패 정책

1. 실패 시 원인 분석 후 수정하고 Gate 1부터 재실행한다
2. 동일 게이트에서 **3회 연속 실패** 시 BLOCKED로 전환한다
3. BLOCKED 시 사용자에게 상황을 보고하고 판단을 요청한다
