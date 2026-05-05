---
name: tdd-workflow
description: 새 기능 작성, 버그 수정, 또는 코드 리팩토링 시 이 스킬을 사용하세요. 유닛, 통합, E2E 테스트를 포함해 80% 이상의 커버리지를 갖춘 테스트 주도 개발(TDD)을 적용합니다.
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Test-Driven Development Workflow

이 스킬은 모든 코드 개발이 포괄적인 테스트 커버리지를 갖춘 TDD 원칙을 따르도록 보장합니다.

컨벤션은 `.claude/rules/testing.md`를 따른다.

## When to Activate

- 새 기능 또는 기능 구현 작성
- 버그 또는 이슈 수정
- 기존 코드 리팩토링
- 새 컴포넌트 생성

## Core Principles

### 1. Tests BEFORE Code

항상 테스트를 먼저 작성하고, 테스트를 통과하도록 코드를 구현하세요.

### 2. Coverage Requirements

- 모든 엣지 케이스 커버
- 에러 시나리오 테스트
- 경계 조건 검증

### 3. Test Types

#### Unit Tests (XCTest / Swift Testing)

- 개별 함수 및 유틸리티
- ViewModel 로직
- 순수 함수
- 헬퍼 및 유틸리티

#### Integration Tests

- 서비스 레이어
- 데이터 저장소 (CoreData, SwiftData, SQLite, Realm)
- 네트워크 레이어
- 외부 API 호출

### UI 테스트 (XCUITest)

- 핵심 사용자 플로우
- 내비게이션 흐름
- 폼 입력 및 제출
- 접근성(Accessibility) 검증

### 4. Git Checkpoints

- 저장소가 Git 관리 하에 있다면, 각 TDD 단계 완료 후 체크포인트 커밋을 생성하세요.
- 워크플로우가 완료될 때까지 이 체크포인트 커밋을 스쿼시하거나 재작성하지 마세요.
- 각 체크포인트 커밋 메시지는 해당 단계와 캡처된 정확한 증거를 설명해야 합니다.
- 현재 작업에 대해 현재 활성 브랜치에서 생성된 커밋만 카운트하세요.
- 다른 브랜치, 이전 관련 없는 작업, 또는 오래된 브랜치 히스토리의 커밋을 유효한 체크포인트 증거로 취급하지 마세요.
- 체크포인트를 충족된 것으로 처리하기 전에, 해당 커밋이 현재 활성 브랜치의 HEAD에서 도달 가능하고 현재 작업 시퀀스에 속하는지 확인하세요.
- 권장하는 간결한 워크플로우:
    - 실패하는 테스트 추가 및 RED 검증을 위한 커밋 하나.
    - 최소한의 수정 적용 및 GREEN 검증을 위한 커밋 하나.
    - 리팩토링 완료를 위한 선택적 커밋 하나.
- 테스트 커밋이 명확하게 RED에 해당하고 수정 커밋이 명확하게 GREEN에 해당한다면, 별도의 증거 전용 커밋은 필요하지 않습니다.

## TDD Workflow Steps

```
[역할]로서, [혜택]을 위해 [행동]하고 싶습니다

예시:
사용자로서, 정확한 키워드 없이도 관련 마켓을 찾을 수 있도록
시맨틱하게 마켓을 검색하고 싶습니다.
```

### Step 1: Write User Journeys

각 사용자 여정에 대해 포괄적인 테스트 케이스를 작성하세요:

```
[역할]로서, [혜택]을 위해 [행동]하고 싶습니다

예시:
사용자로서, 정확한 키워드 없이도 관련 마켓을 찾을 수 있도록
시맨틱하게 마켓을 검색하고 싶습니다.
```

### Step 2: Generate Test Cases

Swift Testing
``` swift
@Suite("ItemSearch")
struct ItemSearchTests {
    @Test func returnsMatchingItems() async throws {
        let sut = ItemSearchService()
        let results = try await sut.search(query: "swift")
        #expect(!results.isEmpty)
    }

    @Test func returnsEmptyForNoMatch() async throws {
        let sut = ItemSearchService()
        let results = try await sut.search(query: "zzz_no_match")
        #expect(results.isEmpty)
    }

    @Test func throwsOnInvalidQuery() async {
        let sut = ItemSearchService()
        await #expect(throws: SearchError.invalidQuery) {
            try await sut.search(query: "")
        }
    }
}
```

XCTest
```swift
final class ItemSearchTests: XCTestCase {
    func test_search_returnsMatchingItems() async throws {
        let sut = ItemSearchService()
        let results = try await sut.search(query: "swift")
        XCTAssertFalse(results.isEmpty)
    }

    func test_search_emptyQuery_throwsError() async throws {
        let sut = ItemSearchService()
        do {
            _ = try await sut.search(query: "")
            XCTFail("에러가 발생해야 합니다")
        } catch SearchError.invalidQuery {
            // 예상된 에러
        }
    }
}
```

### Step 3: Run Tests (They Should Fail)

테스트를 통과하도록 최소한의 코드를 작성하세요:

```
xcodebuild test \
    -scheme HireDiversity_DEV \
    -destination 'platform=iOS Simulator,name=iPhone 17'
# 테스트는 실패해야 합니다 — 아직 구현하지 않았으므로
```

이 단계는 필수이며 모든 프로덕션 변경에 대한 RED 게이트입니다.
비즈니스 로직 또는 다른 프로덕션 코드를 수정하기 전에, 다음 경로 중 하나를 통해 유효한 RED 상태를 확인해야 합니다:

- 런타임 RED:
    - 관련 테스트 대상이 성공적으로 컴파일됨
    - 새로 작성하거나 변경한 테스트가 실제로 실행됨
    - 결과가 RED임

- 컴파일 타임 RED:
    - 새 테스트가 버그가 있는 코드 경로를 새롭게 인스턴스화, 참조, 또는 실행함
    - 컴파일 실패 자체가 의도된 RED 신호임

- 두 경우 모두, 실패는 의도된 비즈니스 로직 버그, 미정의 동작, 또는 미구현으로 인해 발생해야 함
- 관련 없는 문법 오류, 깨진 테스트 설정, 누락된 의존성, 또는 관련 없는 회귀로 인한 실패는 해당되지 않음

작성만 되고 컴파일 및 실행되지 않은 테스트는 RED로 인정되지 않습니다.
이 RED 상태가 확인될 때까지 프로덕션 코드를 수정하지 마세요.
저장소가 Git 관리 하에 있다면, 이 단계가 검증된 직후 체크포인트 커밋을 생성하세요.

권장 커밋 메시지 형식:
- test: <기능 또는 버그>에 대한 재현 케이스 추가
- 재현 케이스가 컴파일 및 실행되어 의도된 이유로 실패했다면, 이 커밋은 RED 검증 체크포인트로도 사용될 수 있습니다
- 계속 진행하기 전에 이 체크포인트 커밋이 현재 활성 브랜치에 있는지 확인하세요

### Step 4: Implement Code

테스트를 통과하도록 최소한의 코드를 작성하세요:
```swift
struct ItemSearchService {
    func search(query: String) async throws -> [Item] {
        guard !query.isEmpty else { throw SearchError.invalidQuery }
        return items
            .filter { $0.title.localizedCaseInsensitiveContains(query) }
            .sorted { $0.score > $1.score }
    }
}
```
저장소가 Git 관리 하에 있다면, 지금 최소한의 수정을 스테이징하되 5단계에서 GREEN이 검증될 때까지 체크포인트 커밋을 미루세요.

### Step 5: Run Tests Again

```
xcodebuild test \
    -scheme HireDiversity_DEV \
    -destination 'platform=iOS Simulator,name=iPhone 17'
# 테스트가 이제 통과해야 합니다
```

수정 후 동일한 관련 테스트 대상을 재실행하고 이전에 실패했던 테스트가 이제 GREEN인지 확인하세요.
유효한 GREEN 결과가 나온 후에만 리팩토링을 진행할 수 있습니다.
저장소가 Git 관리 하에 있다면, GREEN이 검증된 직후 체크포인트 커밋을 생성하세요.

권장 커밋 메시지 형식:
- fix: <기능 또는 버그>
- 동일한 관련 테스트 대상을 재실행하여 통과했다면, 수정 커밋은 GREEN 검증 체크포인트로도 사용될 수 있습니다
- 계속 진행하기 전에 이 체크포인트 커밋이 현재 활성 브랜치에 있는지 확인하세요

### Step 6: Refactor

테스트를 그린 상태로 유지하면서 코드 품질을 개선하세요:
- 중복 제거
- 네이밍 개선
- 성능 최적화
- 가독성 향상

저장소가 Git 관리 하에 있다면, 리팩토링이 완료되고 테스트가 그린 상태를 유지한 직후 체크포인트 커밋을 생성하세요.

권장 커밋 메시지 형식:
- refactor: <기능 또는 버그> 구현 후 정리
- TDD 사이클이 완료된 것으로 간주하기 전에 이 체크포인트 커밋이 현재 활성 브랜치에 있는지 확인하세요

## Testing Patterns

### Unit Test Pattern (Swift Testing)
```swift
@Suite("ItemListViewModel")
struct ItemListViewModelTests {
    @Test func load_populatesItems() async throws {
        let mockRepo = MockItemRepository(items: [.stub(), .stub()])
        let sut = ItemListViewModel(repository: mockRepo)

        await sut.load()

        #expect(sut.items.count == 2)
        #expect(!sut.isLoading)
    }

    @Test func load_failure_setsErrorMessage() async throws {
        let mockRepo = MockItemRepository(error: URLError(.notConnectedToInternet))
        let sut = ItemListViewModel(repository: mockRepo)

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test func searchText_filtersItems() async throws {
        let mockRepo = MockItemRepository(items: [.stub(title: "Swift"), .stub(title: "Kotlin")])
        let sut = ItemListViewModel(repository: mockRepo)
        await sut.load()

        sut.searchText = "Swift"

        #expect(sut.filteredItems.count == 1)
    }
}
```

### Integration Test Pattern (Network)

```swift
final class APIClientTests: XCTestCase {
    var sut: APIClient!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut = APIClient(session: URLSession(configuration: config))
    }

    func test_fetchItems_success() async throws {
        MockURLProtocol.requestHandler = { _ in
            let data = try JSONEncoder().encode([Item.stub()])
            let response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let items = try await sut.fetchItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_fetchItems_serverError_throws() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                           statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await #expect(throws: APIError.serverError(500)) {
            try await sut.fetchItems()
        }
    }
}
```

### E2E Test Pattern (XCUITest)
```swift
final class ItemListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func test_searchAndFilter() {
        let searchField = app.searchFields["아이템 검색"]
        searchField.tap()
        searchField.typeText("Swift")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
        XCTAssertTrue(firstCell.staticTexts["Swift"].exists)

        app.buttons["활성"].tap()
        XCTAssertEqual(app.cells.count, 3)
    }

    func test_createItem() {
        app.navigationBars.buttons["추가"].tap()

        app.textFields["이름"].typeText("테스트 아이템")
        app.textViews["설명"].typeText("테스트 설명")

        app.buttons["저장"].tap()

        XCTAssertTrue(app.staticTexts["아이템이 생성되었습니다"].waitForExistence(timeout: 3))
    }
}
```


## Test File Organization

```
  HireVisaUnitTests/
  ├── HireVisaUnitTests.swift          # 테스트 진입점
  ├── NetworkManagerUnitTests.swift    # 네트워크 유닛 테스트
  ├── Chatting/
  │   ├── Mocks/
  │   │   └── MockChatRepository.swift
  │   └── UseCases/                    # UseCase 통합 테스트
  │       ├── EnterChatRoomUseCaseIntegrationTests.swift
  │       ├── SendTextMessageUseCaseIntegrationTests.swift
  │       ├── SendImageMessageUseCaseIntegrationTests.swift
  │       ├── MarkAsReadUseCaseIntegrationTests.swift
  │       ├── OnMessageReceivedUseCaseIntegrationTests.swift
  │       ├── RetryMessageUseCaseIntegrationTests.swift
  │       ├── CleanupChatMessageStateUseCaseIntegrationTests.swift
  │       └── LeaveChatRoomUseCaseIntegrationTests.swift
  ├── TabBar/
  │   ├── TabBarControllerTests.swift
  │   ├── TabBarViewModelTests.swift
  │   ├── TabBarFactoryTests.swift
  │   └── TabBarIntegrationTests.swift
  └── UI_HDSKit/
      └── Components/
          └── Button/
              └── ActionButtonTests.swift
```

## Mocking External Services

### Protocol 기반 목
```swift
protocol ItemRepositoryProtocol {
    func fetchItems() async throws -> [Item]
    func search(query: String) async throws -> [Item]
}

// 테스트용 목
struct MockItemRepository: ItemRepositoryProtocol {
    var items: [Item] = []
    var error: Error?

    func fetchItems() async throws -> [Item] {
        if let error { throw error }
        return items
    }

    func search(query: String) async throws -> [Item] {
        if let error { throw error }
        return items.filter { $0.title.contains(query) }
    }
}
```

### Stub Data
```swift
extension Item {
    static func stub(
        id: UUID = UUID(),
        title: String = "테스트 아이템",
        isActive: Bool = true,
        score: Double = 0.9
    ) -> Item {
        Item(id: id, title: title, isActive: isActive, score: score)
    }
}
```


## Common Testing Mistakes to Avoid

잘못된 방법: 구현 세부사항 테스트
```swift
// ❌ 내부 상태를 직접 테스트
XCTAssertEqual(viewModel.internalCache.count, 3)
```
올바른 방법: 사용자가 보는 동작 테스트
```swift
// ✅ 외부로 노출된 상태를 테스트
XCTAssertEqual(viewModel.items.count, 3)
```

잘못된 방법: sleep으로 비동기 대기
```swift
swift// ❌ 불안정하고 느림
Thread.sleep(forTimeInterval: 1.0)
XCTAssertFalse(viewModel.isLoading)
```

올바른 방법: async/await 사용
```swift
// ✅ 안정적이고 빠름
await viewModel.load()
XCTAssertFalse(viewModel.isLoading)
```

잘못된 방법: 테스트 간 공유 상태
```swift
// ❌ 테스트들이 서로 의존
static var sharedViewModel = ItemListViewModel()
```

올바른 방법: 독립적인 테스트
```swift
// ✅ 각 테스트가 자체 인스턴스 생성
override func setUp() {
    sut = ItemListViewModel(repository: MockItemRepository())
}
```

## Best Practices

1. **Write Tests First** - Always TDD
2. **One Assert Per Test** - Focus on single behavior
3. **Descriptive Test Names** - Explain what's tested
4. **Arrange-Act-Assert** - Clear test structure
5. **Mock External Dependencies** - Isolate unit tests
6. **Test Edge Cases** - Null, undefined, empty, large
7. **Test Error Paths** - Not just happy paths
8. **Keep Tests Fast** - Unit tests < 50ms each
9. **Clean Up After Tests** - No side effects
10. **Review Coverage Reports** - Identify gaps

## Success Metrics

- 80%+ code coverage achieved
- All tests passing (green)
- No skipped or disabled tests
- Fast test execution (< 30s for unit tests)
- E2E tests cover critical user flows
- Tests catch bugs before production
