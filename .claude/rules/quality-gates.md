# quality-gates

모든 태스크는 완료 전 해당하는 품질 게이트를 통과해야 한다.

## 게이트 정의

### Gate 1: Build
```bash
xcodebuild build -scheme {Scheme} -destination 'generic/platform=iOS Simulator' | xcpretty
```
- 통과 조건: exit code 0, 빌드 경고 0개
- 빌드 경고가 있으면 원인을 파악하고 제거한다

### Gate 2: Lint
```bash
swiftlint lint --strict
```
- 통과 조건: violation 0개
- SwiftLint 미설치 시 `.claude/rules/swift-style.md` 기준으로 수동 검증
- `--strict` 옵션으로 warning도 실패로 처리

### Gate 3: Unit Test
```bash
xcodebuild test -scheme {Scheme} -destination 'platform=iOS Simulator,OS=latest' | xcpretty
```
- 통과 조건: 전체 테스트 통과, 새 코드에 대한 테스트 존재
- 테스트 없는 코드는 머지하지 않는다

### Gate 4: Optimization
- 메인 스레드를 블로킹하는 동기 작업이 없는가
- 반복 호출되는 경로에 무거운 연산이 없는가
- SwiftUI 최적화는 `/swiftui-patterns` 스킬의 Performance 섹션을 참조한다
- 이슈 발견 시 수정 후 Gate 1부터 재실행한다

### Gate 5: Safety
- Swift 6 Concurrency 데이터 레이스 위험이 없는가
- 강제 언래핑(`!`)이 없는가
- 에러 핸들링 누락이 없는가
- 메모리 릭, 강한 순환 참조가 없는가
- 이슈 발견 시 수정 후 Gate 1부터 재실행한다

### Gate 6: Code Review
- `/code-review` 스킬을 실행한다
- Critical, Warning 이슈 발견 시 수정 후 Gate 1부터 재실행한다

## 실패 정책

1. 게이트 실패 시 원인을 분석하고 수정한다
2. 동일 게이트에서 **3회 연속 실패** 시 BLOCKED 상태로 전환한다
3. BLOCKED 시 사용자에게 상황을 보고하고 판단을 요청한다
4. 자동 수정 시도는 최대 3회까지만 허용한다
