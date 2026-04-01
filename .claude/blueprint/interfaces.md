# 인터페이스 청사진

프로젝트의 핵심 Protocol을 사전에 정의한다.
planner 에이전트가 기술 설계 시 이 청사진을 참조하여 일관된 인터페이스를 유지한다.

## Protocol 정의 템플릿

### Repository

```swift
/// Domain 레이어에 정의 (Domain/Repositories/)
protocol {Entity}Repository: Sendable {
    func fetch{Entity}(id: String) async throws -> {Entity}
    func fetch{Entity}List() async throws -> [{Entity}]
    func save{Entity}(_ entity: {Entity}) async throws
    func delete{Entity}(id: String) async throws
}
```

### UseCase

```swift
/// Domain 레이어에 정의 (Domain/UseCases/)
protocol {Action}{Entity}UseCase: Sendable {
    func execute({param}: {Type}) async throws -> {Result}
}

/// 구현체
struct {Action}{Entity}UseCaseImpl: {Action}{Entity}UseCase {
    private let repository: {Entity}Repository

    func execute({param}: {Type}) async throws -> {Result} {
        // 비즈니스 로직
    }
}
```

### ViewModel

```swift
/// Presentation 레이어에 정의 (Presentation/{Feature}/)
@Observable
@MainActor
final class {Feature}ViewModel {
    // MARK: - Properties
    private(set) var state: ViewState = .idle
    private let useCase: {Action}{Entity}UseCase

    // MARK: - Initializer
    init(useCase: {Action}{Entity}UseCase) {
        self.useCase = useCase
    }

    // MARK: - Actions
    func onAppear() async { }
    func onTapButton() async { }
}
```

### NetworkService

```swift
/// Data 레이어에 정의 (Data/Network/)
protocol NetworkService: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
```

### Endpoint

```swift
/// Data 레이어에 정의 (Data/Network/APIs/)
protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}
```

## 공통 타입

### ViewState

```swift
/// 화면 상태를 표현하는 공통 enum
enum ViewState {
    case idle
    case loading
    case loaded
    case error(Error)
}
```

### AppError

```swift
/// 앱 전역 에러 타입
enum AppError: Error, LocalizedError {
    case networkError(underlying: Error)
    case decodingError
    case notFound
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error): error.localizedDescription
        case .decodingError: "데이터 처리에 실패했습니다"
        case .notFound: "요청한 정보를 찾을 수 없습니다"
        case .unauthorized: "인증이 필요합니다"
        case .unknown: "알 수 없는 오류가 발생했습니다"
        }
    }
}
```

## 네이밍 규칙

| 종류 | 패턴 | 예시 |
|---|---|---|
| Repository Protocol | `{Entity}Repository` | `UserRepository` |
| Repository 구현체 | `{Entity}RepositoryImpl` | `UserRepositoryImpl` |
| UseCase Protocol | `{Action}{Entity}UseCase` | `FetchUserUseCase` |
| UseCase 구현체 | `{Action}{Entity}UseCaseImpl` | `FetchUserUseCaseImpl` |
| ViewModel | `{Feature}ViewModel` | `LoginViewModel` |
| View | `{Feature}View` | `LoginView` |
| DTO | `{Entity}DTO` | `UserDTO` |
| Mock | `Mock{Protocol}` | `MockUserRepository` |
| Stub | `{Entity}+Stub` | `User+Stub` |

## 이 청사진의 사용법

- 프로젝트 초기에 아키텍처에 맞게 수정한다
- planner가 새 기능 설계 시 여기에 정의된 패턴을 따른다
- 프로젝트에 없는 새로운 패턴이 필요하면 `decisions.md`에 기록한다
