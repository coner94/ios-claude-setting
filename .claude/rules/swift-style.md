# swift-style

Swift.org API Design Guidelines를 기본으로 따른다.

## 포맷팅

- **SwiftFormat**: 자동 포맷팅 도구. 커밋 전 실행한다
- **SwiftLint**: 스타일 규칙 강제. `--strict` 옵션으로 warning도 실패 처리
- Xcode 16+에 내장된 `swift-format`을 대안으로 사용할 수 있다

## 네이밍

[Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)를 따른다.

프로젝트 추가 규칙:
- 약어를 피한다 (`btn` → `button`, `vc` → `viewController`)
- Bool 변수는 `is`, `has`, `should`, `can` 접두사 (예: `isLoading`, `hasError`)
- 팩토리 메서드는 `make` 접두사 (예: `makeViewModel()`)
- 상수는 전역 상수 대신 `static let`을 사용한다
- 파일명은 주요 타입명과 일치시킨다 (예: `LoginViewModel.swift`)
- Extension 파일: `{타입}+{기능}.swift` (예: `String+Validation.swift`)

## 코드 구조

### 접근 제어
- 기본은 `private`으로 시작하고, 필요 시 범위를 넓힌다
- `internal`은 명시하지 않는다 (기본값)
- `open`은 상속이 반드시 필요한 경우에만 사용한다

### MARK 주석
타입 내부를 섹션으로 구분한다:

```swift
// MARK: - Properties
// MARK: - Initializer
// MARK: - Public Methods
// MARK: - Private Methods
```

### Extension 활용
- Protocol 채택은 별도 Extension으로 분리한다

```swift
struct LoginViewModel {
    // 핵심 로직
}

// MARK: - LoginViewModelProtocol
extension LoginViewModel: LoginViewModelProtocol {
    // 프로토콜 구현
}
```

### 타입 멤버 순서
1. 중첩 타입 (nested type)
2. 프로퍼티 (static → stored → computed)
3. Initializer
4. 메서드 (public → internal → private)

## 스타일

### 들여쓰기 & 공백
- 들여쓰기: 4 spaces
- 콜론: 좌측 붙임 (예: `name: String`, `case .loading:`)
- 빈 줄: 섹션 사이 1줄, 2줄 이상 금지

### 옵셔널 처리
- `guard let`으로 early return 우선
- `if let` 축약 문법 사용 (예: `if let value { }`)
- 강제 언래핑(`!`) 금지. 테스트에서도 금지

```swift
// Good
guard let user else { return }

// Bad
let name = user!.name
```

### 클로저
- 단일 표현식이면 `return` 생략
- 후행 클로저 사용. 단, 2개 이상 클로저 파라미터 시 후행 클로저 사용하지 않음
- 파라미터 타입 추론 가능하면 생략

```swift
// Good
users.filter { $0.isActive }

// Bad
users.filter({ (user: User) -> Bool in return user.isActive })
```

### self
- 필요한 경우(클로저 캡처, 이름 충돌)에만 `self`를 명시한다

### 타입 추론
- 변수 선언 시 타입이 명확하면 생략
- 타입이 불명확하면 명시

```swift
// Good
let name = "Claude"
let count: Int = computeValue()

// Bad
let name: String = "Claude"
```

## Swift 고유 패턴

### enum
- 연관값 있는 enum 활용을 권장한다
- 모든 case를 다루는 `switch`에서 `default` 사용 금지

### 불변성
- `let`을 기본으로 선언하고, 컴파일러가 요구할 때만 `var`로 변경한다
- 값 타입(`struct`)을 기본으로 사용한다. 참조 시맨틱이 필요하거나 상속이 필요할 때만 `class`
- `@Observable` 사용 시 `class` 허용

### 에러 처리
- 커스텀 에러는 `Error` 프로토콜을 채택한 enum으로 정의
- 에러 케이스명은 구체적으로 (예: `networkTimeout`, `invalidResponse`)
- Swift 6+에서는 typed throws를 사용한다

```swift
// Good
func load(id: String) throws(LoadError) -> Item {
    guard let data = try? read(from: path) else {
        throw .fileNotFound(id)
    }
    return try decode(data)
}
```

### 동시성
- Swift 6 strict concurrency checking을 활성화한다
- `async/await` 사용, completion handler 지양
- `@MainActor`는 ViewModel과 UI 관련 코드에 적용
- `Task`는 View나 ViewModel에서만 생성
- 격리 경계를 넘는 데이터는 `Sendable` 값 타입을 사용한다
- 공유 가변 상태는 `actor`로 보호한다
- 비구조적 `Task {}` 대신 구조적 동시성(`async let`, `TaskGroup`)을 우선한다
