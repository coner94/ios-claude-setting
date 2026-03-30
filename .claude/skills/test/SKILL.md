---
name: test
description: Swift Testing 프레임워크 기반 테스트 작성 스킬. TDD 에이전트(tester)가 호출하거나 사용자가 /test로 직접 호출할 수 있다.
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Swift Testing 테스트 작성

Swift Testing 프레임워크를 사용하여 테스트 코드를 작성한다.
tester 에이전트의 TDD 사이클에서 호출되거나, 사용자가 `/test {대상}`으로 직접 호출할 수 있다.

컨벤션은 `.claude/rules/testing.md`를 따른다.

## ARGUMENTS

- `$ARGUMENTS`: 테스트 대상 설명 (필수)
  - 예: `/test LoginViewModel 이메일 유효성 검증`
  - 예: `/test UserRepository fetch 메서드`

---

## Phase 1: 대상 분석

- `$ARGUMENTS`에 해당하는 기존 코드를 탐색한다
- 테스트할 타입의 Protocol, 의존성을 파악한다
- 기존 테스트 파일이 있으면 패턴을 따른다
- 테스트 시나리오를 도출하고 사용자에게 확인받는다

---

## Phase 2: Red — 실패하는 테스트 작성

### 테스트 코드 템플릿

```swift
import Testing
@testable import {모듈명}

@Suite("{대상} Tests")
struct {대상}Tests {
    let sut: {테스트 대상 타입}

    init() {
        sut = {테스트 대상 타입}(dependency: Mock{프로토콜명}())
    }

    @Test func {동작}_{조건}_{기대결과}() async throws {
        // Given
        {준비}

        // When
        {실행}

        // Then
        #expect({검증})
    }

    @Test(arguments: [{입력값 목록}])
    func {동작}_{파라미터화_설명}(input: {타입}, expected: {타입}) {
        #expect({검증})
    }

    @Test func {동작}_{에러조건}_{에러타입}() async {
        await #expect(throws: {에러타입}.{케이스}) {
            try await sut.{메서드}()
        }
    }
}
```

### Mock/Stub 템플릿

```swift
struct Mock{프로토콜명}: {프로토콜명} {
    var result: Result<{성공타입}, Error> = .success(.stub)

    func {메서드명}() async throws -> {반환타입} {
        try result.get()
    }
}
```

### 실패 확인

```bash
swift test --filter {테스트Suite명}
```

- 테스트가 **컴파일 에러 또는 실패**하는 것을 확인한다
- 이미 통과하면 시나리오를 재검토한다

---

## Phase 3: Green — 최소한의 구현

- 테스트를 통과시키기 위한 **최소한의 코드**만 작성한다
- 완벽한 설계보다 테스트 통과를 우선한다
- `.claude/rules/swift-style.md` 컨벤션을 준수한다

```bash
swift test --filter {테스트Suite명}
```

- 모든 테스트가 **통과**하는 것을 확인한다

---

## Phase 4: Refactor — 코드 개선

- 중복 코드 제거, 네이밍 개선, 긴 함수 분리
- 테스트 코드도 리팩토링 (중복 setup 정리, 파라미터화 통합)

```bash
swift test --filter {테스트Suite명}
```

- 리팩토링 후에도 모든 테스트가 **통과**하는 것을 확인한다

---

## Phase 5: 결과 보고

```markdown
## TDD 결과: {기능 설명}

### 테스트 시나리오
- 정상 케이스 N개
- 엣지 케이스 N개
- 에러 케이스 N개

### 생성/수정 파일
- 테스트: `{테스트 파일 경로}`
- 구현: `{구현 파일 경로}`
- Mock: `{Mock 파일 경로}`

### 테스트 실행 결과
- 전체: N개 통과 / 0개 실패
```
