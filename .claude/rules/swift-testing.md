# swift-testing

Swift Testing 프레임워크를 사용한다.

## 필수 원칙

- 모든 새 기능에는 테스트를 작성한다
- 버그 수정 시 해당 버그를 재현하는 테스트를 먼저 작성한 뒤 수정한다
- 테스트 없는 PR은 머지하지 않는다
- 테스트는 독립적이어야 하며, 실행 순서에 의존하지 않는다
- 외부 의존성(네트워크, DB)은 반드시 Mock/Stub으로 대체한다

## 네이밍 규칙

- 테스트 파일: `{대상}Tests.swift`
- 테스트 구조체: `{대상}Tests`, `@Suite`로 그룹핑
- 테스트 함수: `{동작}_{조건}_{기대결과}` 패턴. 한글 허용
- Mock: `Mock{프로토콜명}` (Protocol 기반)
- Stub: `{Entity}+Stub.swift`
- 테스트 대상과 동일한 디렉토리 구조를 Tests 타겟에 유지한다

## 구조 규칙

- 모든 테스트는 Given-When-Then 3단계로 구분한다
- 동일 로직에 여러 입력 검증 시 `@Test(arguments:)`를 사용한다
- 에러 검증은 `#expect(throws:)`를 사용한다
- Mock은 테스트 타겟 내 `Mocks/` 디렉토리에 둔다

## 테스트 레이어별 범위

| 레이어 | 테스트 대상 | 필수 여부 |
|---|---|---|
| Domain | UseCase, Entity 로직 | 필수 |
| Data | Repository 구현체, DTO 매핑 | 필수 |
| Presentation | ViewModel 상태 변화, 입력 처리 | 필수 |
| View | SwiftUI Preview 확인 | 권장 |

## 금지사항

- `sleep`이나 임의 대기 사용 금지. 비동기는 `async/await`로 처리
- `try!`, `as!` 등 강제 언래핑 금지. `throws`와 `#expect`를 사용
- 하나의 테스트에 여러 시나리오를 섞지 않는다
- 테스트 간 공유 상태(static var 등)를 사용하지 않는다
