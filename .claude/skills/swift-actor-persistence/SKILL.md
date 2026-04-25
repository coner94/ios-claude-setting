---
name: swift-actor-persistence
description: Thread-safe data persistence in Swift using actors — in-memory cache with file-backed storage, eliminating data races by design.
---

# Swift Actors for Thread-Safe Persistence

Swift actor를 사용해 스레드 안전한 데이터 영속성 레이어를 구축하는 패턴. 인메모리 캐싱과 파일 기반 저장소를 결합하고, 컴파일 타임에 데이터 레이스를 제거한다.

## When to Activate

- 여러 곳에서 동시에 접근하는 공유 가변 상태를 직접 관리하는 경우
- 동시성 보호가 없는 저장소를 직접 읽고 쓰는 경우
- 수동 동기화(lock, DispatchQueue)를 제거하고 싶은 경우

## When NOT to Use an Actor

저장소가 이미 내부적으로 스레드 안전성을 보장한다면 actor는 불필요하다:

| 저장소 | 이유 |
|--------|------|
| `UserDefaults` | 내부적으로 thread-safe. actor로 감싸면 불필요한 async 오버헤드만 발생 |
| `Keychain` (Security framework) | 시스템이 동기화를 처리 |
| Core Data `NSPersistentContainer` | `performBackgroundTask`가 컨텍스트 격리를 제공 |
| SwiftData `ModelContainer` | 자체 동시성 모델 보유 |

핵심 판단 기준: **내가 직접 동시성을 제어해야 하는가?** 그렇지 않다면 actor는 오버헤드만 추가한다.

## Core Pattern

### Actor-Based Repository

Actor 모델은 직렬화된 접근을 보장한다 — 컴파일러가 강제하는 데이터 레이스 없음.

```swift
public actor LocalRepository<T: Codable & Identifiable> where T.ID == String {
    private var cache: [String: T] = [:]
    private let fileURL: URL

    public init(directory: URL = .documentsDirectory, filename: String = "data.json") {
        self.fileURL = directory.appendingPathComponent(filename)
        // Synchronous load during init (actor isolation not yet active)
        self.cache = Self.loadSynchronously(from: fileURL)
    }

    // MARK: - Public API

    public func save(_ item: T) throws {
        cache[item.id] = item
        try persistToFile()
    }

    public func delete(_ id: String) throws {
        cache[id] = nil
        try persistToFile()
    }

    public func find(by id: String) -> T? {
        cache[id]
    }

    public func loadAll() -> [T] {
        Array(cache.values)
    }

    // MARK: - Private

    private func persistToFile() throws {
        let data = try JSONEncoder().encode(Array(cache.values))
        try data.write(to: fileURL, options: .atomic)
    }

    private static func loadSynchronously(from url: URL) -> [String: T] {
        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

### Usage

Actor 격리로 인해 모든 호출은 자동으로 async가 된다:

```swift
let repository = LocalRepository<Question>()

// 읽기 — 인메모리 캐시에서 O(1) 조회
let question = await repository.find(by: "q-001")
let allQuestions = await repository.loadAll()

// 쓰기 — 캐시를 업데이트하고 파일에 원자적으로 저장
try await repository.save(newQuestion)
try await repository.delete("q-001")
```

### Combining with @Observable ViewModel

```swift
@Observable
final class QuestionListViewModel {
    private(set) var questions: [Question] = []
    private let repository: LocalRepository<Question>

    init(repository: LocalRepository<Question> = LocalRepository()) {
        self.repository = repository
    }

    func load() async {
        questions = await repository.loadAll()
    }

    func add(_ question: Question) async throws {
        try await repository.save(question)
        questions = await repository.loadAll()
    }
}
```

## Key Design Decisions

| 결정 | 이유 |
|----------|-----------|
| Actor (class + lock 대신) | 컴파일러가 강제하는 스레드 안전성, 수동 동기화 불필요 |
| 인메모리 캐시 + 파일 영속성 | 캐시에서 빠른 읽기, 디스크에 내구성 있는 쓰기 |
| 동기식 init 로딩 | 비동기 초기화 복잡성 회피 |
| ID로 키잉된 Dictionary | 식별자로 O(1) 조회 |
| `Codable & Identifiable` 제네릭 | 어떤 모델 타입에도 재사용 가능 |
| 원자적 파일 쓰기 (`.atomic`) | 크래시 시 부분 쓰기 방지 |

## Best Practices

- **`Sendable` 타입 사용** — actor 경계를 넘는 모든 데이터에 적용
- **actor의 public API를 최소화** — 도메인 연산만 노출하고 영속성 세부사항은 숨김
- **`.atomic` 쓰기 사용** — 앱 크래시 중간에 쓰기가 발생해도 데이터 손상 방지
- **`init`에서 동기 로딩** — 비동기 초기화는 로컬 파일에서 얻는 이점 대비 복잡성이 크다
- **`@Observable` ViewModel과 결합** — 반응형 UI 업데이트 구현

## Anti-Patterns to Avoid

- 새 Swift 동시성 코드에서 actor 대신 `DispatchQueue` 또는 `NSLock` 사용
- 내부 캐시 딕셔너리를 외부 호출자에게 노출
- 유효성 검사 없이 파일 URL을 외부에서 설정 가능하게 만들기
- actor 메서드 호출이 모두 `await`임을 잊는 것 — 호출자는 비동기 컨텍스트를 처리해야 함
- actor 격리를 우회하기 위해 `nonisolated` 사용 (목적에 위배)

