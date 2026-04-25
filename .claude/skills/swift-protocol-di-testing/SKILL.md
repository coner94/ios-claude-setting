---
name: swift-protocol-di-testing
description: Protocol-based dependency injection for testable Swift code — mock file system, network, and external APIs using focused protocols and Swift Testing.
origin: ECC
---

# Swift Protocol-Based Dependency Injection for Testing

외부 의존성(파일 시스템, 네트워크, iCloud)을 작고 명확한 프로토콜 뒤로 추상화해 Swift 코드를 테스트 가능하게 만드는 패턴. I/O 없이 결정론적 테스트를 작성할 수 있다.

## When to Activate

- 파일 시스템, 네트워크, 외부 API에 접근하는 Swift 코드를 작성할 때
- 실제 실패를 유발하지 않고 에러 핸들링 경로를 테스트해야 할 때
- 앱, 테스트, SwiftUI 프리뷰 등 여러 환경에서 동작하는 모듈을 만들 때
- Swift 동시성(actor, Sendable)으로 테스트 가능한 아키텍처를 설계할 때

## Core Pattern

### 1. Define Small, Focused Protocols

각 프로토콜은 정확히 하나의 외부 관심사만 다룬다.

```swift
// 파일 시스템 접근
public protocol FileSystemProviding: Sendable {
    func containerURL(for purpose: Purpose) -> URL?
}

// 파일 읽기/쓰기 작업
public protocol FileAccessorProviding: Sendable {
    func read(from url: URL) throws -> Data
    func write(_ data: Data, to url: URL) throws
    func fileExists(at url: URL) -> Bool
}

// 북마크 저장 (샌드박스 앱 등에서 사용)
public protocol BookmarkStorageProviding: Sendable {
    func saveBookmark(_ data: Data, for key: String) throws
    func loadBookmark(for key: String) throws -> Data?
}
```

### 2. Create Default (Production) Implementations

```swift
public struct DefaultFileSystemProvider: FileSystemProviding {
    public init() {}

    public func containerURL(for purpose: Purpose) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)
    }
}

public struct DefaultFileAccessor: FileAccessorProviding {
    public init() {}

    public func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }

    public func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}
```

### 3. Create Mock Implementations for Testing

```swift
public final class MockFileAccessor: FileAccessorProviding, @unchecked Sendable {
    public var files: [URL: Data] = [:]
    public var readError: Error?
    public var writeError: Error?

    public init() {}

    public func read(from url: URL) throws -> Data {
        if let error = readError { throw error }
        guard let data = files[url] else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        return data
    }

    public func write(_ data: Data, to url: URL) throws {
        if let error = writeError { throw error }
        files[url] = data
    }

    public func fileExists(at url: URL) -> Bool {
        files[url] != nil
    }
}
```

### 4. Inject Dependencies with Default Parameters

프로덕션 코드는 기본값을 사용하고, 테스트에서만 Mock을 주입한다.

```swift
public actor SyncManager {
    private let fileSystem: FileSystemProviding
    private let fileAccessor: FileAccessorProviding

    public init(
        fileSystem: FileSystemProviding = DefaultFileSystemProvider(),
        fileAccessor: FileAccessorProviding = DefaultFileAccessor()
    ) {
        self.fileSystem = fileSystem
        self.fileAccessor = fileAccessor
    }

    public func sync() async throws {
        guard let containerURL = fileSystem.containerURL(for: .sync) else {
            throw SyncError.containerNotAvailable
        }
        let data = try fileAccessor.read(
            from: containerURL.appendingPathComponent("data.json")
        )
        // Process data...
    }
}
```

### 5. Write Tests with Swift Testing

```swift
import Testing

@Test("Sync manager handles missing container")
func testMissingContainer() async {
    let mockFileSystem = MockFileSystemProvider(containerURL: nil)
    let manager = SyncManager(fileSystem: mockFileSystem)

    await #expect(throws: SyncError.containerNotAvailable) {
        try await manager.sync()
    }
}

@Test("Sync manager reads data correctly")
func testReadData() async throws {
    let mockFileAccessor = MockFileAccessor()
    mockFileAccessor.files[testURL] = testData

    let manager = SyncManager(fileAccessor: mockFileAccessor)
    let result = try await manager.loadData()

    #expect(result == expectedData)
}

@Test("Sync manager handles read errors gracefully")
func testReadError() async {
    let mockFileAccessor = MockFileAccessor()
    mockFileAccessor.readError = CocoaError(.fileReadCorruptFile)

    let manager = SyncManager(fileAccessor: mockFileAccessor)

    await #expect(throws: SyncError.self) {
        try await manager.sync()
    }
}
```

## Best Practices

- **단일 책임**: 각 프로토콜은 하나의 관심사만 다룬다 — 메서드가 많은 "God Protocol" 생성 금지
- **Sendable 채택**: actor 경계를 넘어 프로토콜을 사용할 때 필수
- **기본 파라미터**: 프로덕션 코드는 기본값으로 실제 구현체를 사용하고, 테스트에서만 Mock을 지정
- **에러 시뮬레이션**: 실패 경로 테스트를 위해 Mock에 설정 가능한 에러 프로퍼티를 두도록 설계
- **경계만 Mock**: 외부 의존성(파일 시스템, 네트워크, API)만 Mock하고 내부 타입은 Mock하지 않는다

## Anti-Patterns to Avoid

- 모든 외부 접근을 하나의 거대한 프로토콜로 묶기
- 외부 의존성이 없는 내부 타입을 Mock하기
- 올바른 의존성 주입 대신 `#if DEBUG` 조건부 컴파일 사용
- actor와 함께 사용할 때 `Sendable` 채택 누락
- 과잉 설계: 외부 의존성이 없는 타입에는 프로토콜이 필요 없다

