---
name: swiftui-patterns
description: SwiftUI 아키텍처 패턴, @Observable 상태 관리, 뷰 컴포지션, 성능 최적화, 최신 iOS/macOS UI 모범 사례.
---

# SwiftUI Patterns

Apple 플랫폼에서 선언적이고 성능 좋은 UI를 만들기 위한 최신 SwiftUI 패턴.
Observation 프레임워크, 뷰 컴포지션, 성능 최적화를 다룬다.

## When to Activate

- SwiftUI 뷰 작성 및 상태 관리 (`@State`, `@Observable`, `@Binding`)
- ViewModel 및 데이터 흐름 구조 설계
- 리스트와 복잡한 레이아웃의 렌더링 성능 최적화
- SwiftUI에서 Environment 값과 의존성 주입 활용

## State Management

### Property Wrapper Selection

가장 단순한 래퍼를 선택한다:

| 래퍼 | 사용 상황 |
|---------|----------|
| `@State` | 뷰 로컬 값 타입 (토글, 폼 필드, 시트 표시) |
| `@Binding` | 부모의 `@State`에 대한 양방향 참조 |
| `@Observable` class + `@State` | 여러 프로퍼티를 가진 소유 모델 |
| `@Observable` class (래퍼 없음) | 부모에서 전달받는 읽기 전용 참조 |
| `@Bindable` | `@Observable` 프로퍼티에 대한 양방향 바인딩 |
| `@Environment` | `.environment()`로 주입하는 공유 의존성 |

### @Observable ViewModel

`ObservableObject` 대신 `@Observable`을 사용한다. 
프로퍼티 단위로 변화를 추적하므로 해당 프로퍼티를 읽는 뷰만 재렌더링된다:

```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""

    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}
```

### View Consuming the ViewModel

```swift
struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel = ItemListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .searchable(text: $viewModel.searchText)
        .overlay { if viewModel.isLoading { ProgressView() } }
        .task { await viewModel.load() }
    }
}
```

### Environment Injection

`@EnvironmentObject` 대신 `@Environment`를 사용한다:

```swift
// 주입
ContentView()
    .environment(authManager)

// 사용
struct ProfileView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        Text(auth.currentUser?.name ?? "Guest")
    }
}
```

## View Composition

### Extract Subviews to Limit Invalidation

뷰를 작고 명확한 struct으로 분리한다. 상태가 변경되면 해당 상태를 읽는 서브뷰만 재렌더링된다:

```swift
struct OrderView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        VStack {
            OrderHeader(title: viewModel.title)
            OrderItemList(items: viewModel.items)
            OrderTotal(total: viewModel.total)
        }
    }
}
```

### ViewModifier for Reusable Styling

```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
```

## Performance

### Use Lazy Containers for Large Collections

`LazyVStack`과 `LazyHStack`은 화면에 보일 때만 뷰를 생성한다:

```swift
ScrollView {
    LazyVStack(spacing: 8) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Stable Identifiers

`ForEach`에는 항상 안정적이고 유일한 ID를 사용한다. 배열 인덱스는 사용하지 않는다:

```swift
// Identifiable 채택 또는 명시적 id 사용
ForEach(items, id: \.stableID) { item in
    ItemRow(item: item)
}
```

### Avoid Expensive Work in body

- `body` 안에서 I/O, 네트워크 호출, 무거운 연산을 절대 수행하지 않는다
- 비동기 작업은 `.task {}`를 사용한다 — 뷰가 사라지면 자동으로 취소된다
- `.sensoryFeedback()`과 `.geometryGroup()`은 스크롤 뷰에서 최소화한다
- 리스트에서 `.shadow()`, `.blur()`, `.mask()`를 남용하지 않는다 — 오프스크린 렌더링을 유발한다

### Equatable Conformance

body 연산 비용이 큰 뷰는 `Equatable`을 채택해 불필요한 재렌더링을 건너뛴다:

```swift
struct ExpensiveChartView: View, Equatable {
    let dataPoints: [DataPoint] // DataPoint도 Equatable을 채택해야 함

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.dataPoints == rhs.dataPoints
    }

    var body: some View {
        // 복잡한 차트 렌더링
    }
}
```

## Previews

인라인 Mock 데이터와 `#Preview` 매크로로 빠르게 반복한다:

```swift
#Preview("빈 상태") {
    ItemListView(viewModel: ItemListViewModel(repository: EmptyMockRepository()))
}

#Preview("데이터 로드됨") {
    ItemListView(viewModel: ItemListViewModel(repository: PopulatedMockRepository()))
}
```

## Anti-Patterns to Avoid

- 새 코드에서 `ObservableObject` / `@Published` / `@StateObject` / `@EnvironmentObject` 사용 — `@Observable`로 마이그레이션
- `body`나 `init` 안에서 직접 비동기 작업 — `.task {}` 또는 명시적 로드 메서드 사용
- 데이터를 소유하지 않는 자식 뷰에서 `@State`로 ViewModel 생성 — 부모에서 전달
- `AnyView` 타입 이레이저 사용 — 조건부 뷰에는 `@ViewBuilder` 또는 `Group` 사용
- 액터 간 데이터 전달 시 `Sendable` 요구사항 무시

## References

관련 스킬: `swift-actor-persistence` — 액터 기반 영속성 패턴.
관련 스킬: `swift-protocol-di-testing` — 프로토콜 기반 DI와 Swift Testing 테스트.

