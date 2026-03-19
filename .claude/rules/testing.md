# 테스트 규칙

Swift Testing 프레임워크를 사용한다.

## 필수 원칙

- 모든 새 기능에는 테스트를 작성한다
- 버그 수정 시 해당 버그를 재현하는 테스트를 먼저 작성한 뒤 수정한다
- 테스트 없는 PR은 머지하지 않는다
- 테스트는 독립적이어야 하며, 실행 순서에 의존하지 않는다
- 외부 의존성(네트워크, DB)은 반드시 Mock/Stub으로 대체한다

## 네이밍 컨벤션

### 테스트 파일
- `{대상}Tests.swift` (예: `LoginViewModelTests.swift`)
- 테스트 대상과 동일한 디렉토리 구조를 Tests 타겟에 유지한다

### 테스트 함수
- `{동작}_{조건}_{기대결과}` 패턴을 따른다
- 한글 사용 가능. 의미가 명확하면 영문도 허용

```swift
@Test func 로그인_유효한_이메일과_비밀번호_성공() { }
@Test func login_invalidEmail_throwsValidationError() { }
```

### 테스트 구조체
- `@Suite`로 관련 테스트를 그룹핑한다
- 구조체명은 `{대상}Tests`로 한다

```swift
@Suite("LoginViewModel Tests")
struct LoginViewModelTests {
    let sut: LoginViewModel

    init() {
        sut = LoginViewModel(useCase: MockLoginUseCase())
    }
}
```

## 구조

### Given-When-Then

모든 테스트는 3단계로 구분한다. 주석은 생략 가능하나 구조는 유지한다.

```swift
@Test func 로그인_유효한_이메일과_비밀번호_성공() async throws {
    // Given
    let useCase = MockLoginUseCase(result: .success(.stub))
    let sut = LoginViewModel(useCase: useCase)

    // When
    await sut.login(email: "test@test.com", password: "password123")

    // Then
    #expect(sut.isLoggedIn == true)
}
```

### 파라미터화 테스트

동일 로직에 여러 입력을 검증할 때 `@Test(arguments:)`를 사용한다.

```swift
@Test(arguments: [
    ("", false),
    ("invalid", false),
    ("test@test.com", true)
])
func 이메일_유효성_검증(email: String, expected: Bool) {
    #expect(EmailValidator.isValid(email) == expected)
}
```

### 에러 검증

```swift
@Test func 잘못된_비밀번호_에러_발생() async {
    await #expect(throws: AuthError.invalidPassword) {
        try await useCase.login(email: "test@test.com", password: "")
    }
}
```

## 테스트 레이어별 범위

| 레이어 | 테스트 대상 | 필수 여부 |
|---|---|---|
| Domain | UseCase, Entity 로직 | 필수 |
| Data | Repository 구현체, DTO 매핑 | 필수 |
| Presentation | ViewModel 상태 변화, 입력 처리 | 필수 |
| View | SwiftUI Preview 확인 | 권장 |

## Mock 규칙

- Mock은 테스트 타겟 내 `Mocks/` 디렉토리에 둔다
- Protocol 기반으로 Mock을 생성한다
- Mock 네이밍: `Mock{프로토콜명}` (예: `MockLoginUseCase`)
- Stub 데이터: `{Entity}+Stub.swift` (예: `User+Stub.swift`)

```swift
struct MockLoginUseCase: LoginUseCaseProtocol {
    var result: Result<User, Error> = .success(.stub)

    func execute(email: String, password: String) async throws -> User {
        try result.get()
    }
}
```

## 금지사항

- `sleep`이나 임의 대기 사용 금지. 비동기는 `async/await`로 처리
- `try!`, `as!` 등 강제 언래핑 금지. `throws`와 `#expect`를 사용
- 하나의 테스트에 여러 시나리오를 섞지 않는다
- 테스트 간 공유 상태(static var 등)를 사용하지 않는다
