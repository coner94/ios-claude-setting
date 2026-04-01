# 품질 게이트

모든 태스크는 완료 전 해당하는 품질 게이트를 통과해야 한다.

## 게이트 정의

### Gate 1: 빌드
```bash
xcodebuild build -scheme {Scheme} -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty
```
- 통과 조건: exit code 0, 빌드 경고 0개
- 빌드 경고가 있으면 원인을 파악하고 제거한다

### Gate 2: 린트
```bash
swiftlint lint --strict
```
- 통과 조건: violation 0개
- SwiftLint 미설치 시 `.claude/rules/swift-style.md` 기준으로 수동 검증
- `--strict` 옵션으로 warning도 실패로 처리

### Gate 3: 단위 테스트
```bash
xcodebuild test -scheme {Scheme} -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty
```
- 통과 조건: 전체 테스트 통과, 새 코드에 대한 테스트 존재
- 테스트 없는 코드는 머지하지 않는다

### Gate 4: 컨벤션 준수
수동 체크리스트:
- [ ] 네이밍이 `swift-style.md` 규칙을 따르는가
- [ ] 접근 제어가 최소 권한으로 설정되었는가
- [ ] 강제 언래핑(`!`)이 없는가
- [ ] `async/await`를 사용하고 completion handler가 없는가
- [ ] `@MainActor`가 ViewModel/UI 코드에만 적용되었는가
- [ ] 테스트가 Given-When-Then 구조를 따르는가
- [ ] 커밋 메시지가 `git-flow.md` 컨벤션을 따르는가

### Gate 5: PR 준수
- [ ] PR 크기 300줄 이하 (자동 생성 파일 제외)
- [ ] `pr-template.md` 형식에 맞는 제목과 본문
- [ ] 테스트 체크리스트 포함

## 에이전트별 게이트 요구사항

| 에이전트 | 필수 게이트 |
|---|---|
| planner | 없음 (계획만 수립) |
| tester | Gate 1, 3 |
| 구현 (메인) | Gate 1, 2, 3 |
| refactorer | Gate 1, 2, 3 |
| reviewer | Gate 4 |
| git (PR) | Gate 1, 2, 3, 4, 5 |

## 실패 정책

1. 게이트 실패 시 원인을 분석하고 수정한다
2. 동일 게이트에서 **3회 연속 실패** 시 BLOCKED 상태로 전환한다
3. BLOCKED 시 사용자에게 상황을 보고하고 판단을 요청한다
4. 자동 수정 시도는 최대 3회까지만 허용한다
