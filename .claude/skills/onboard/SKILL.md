---
name: onboard
description: 기존 iOS 프로젝트에 하네스를 적용할 때, 프로젝트를 스캔하여 blueprint, settings, CLAUDE.md를 프로젝트에 맞게 초기화한다.
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Agent
---

# onboard — 하네스 초기화

기존 iOS 프로젝트의 구조를 분석하여 `.claude/` 하네스 설정을 프로젝트에 맞게 채운다.
새 프로젝트가 아닌 **이미 코드가 있는 프로젝트**에 하네스를 최초 적용할 때 사용한다.

## ARGUMENTS

- `$ARGUMENTS` 없음: 전체 온보딩 (Phase 1~4)
- `--scan-only`: 스캔만 수행하고 결과를 보여준다 (파일 수정 없음)
- `--phase=N`: 특정 Phase만 실행한다

---

## Phase 1: 프로젝트 스캔

### 1-1. 기본 구조 파악 (Bash)

```bash
# Xcode 프로젝트/워크스페이스 찾기
find . -maxdepth 2 \( -name "*.xcodeproj" -o -name "*.xcworkspace" -o -name "Package.swift" -o -name "Project.swift" \) -not -path "*/DerivedData/*"

# 디렉토리 트리
find . -type d -maxdepth 4 -not -path '*/\.*' -not -path '*/Pods/*' -not -path '*/DerivedData/*' -not -path '*/.build/*' -not -path '*/Tuist/*' | sort

# Swift 파일 분포
find . -type f -name '*.swift' -not -path '*/Pods/*' -not -path '*/DerivedData/*' -not -path '*/.build/*' | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -20

# Xcode scheme 목록
xcodebuild -list -json 2>/dev/null || echo "xcodebuild 불가"
```

### 1-2. 아키텍처 분석 (병렬 Agent)

아래 4개를 병렬 Agent로 동시 탐색한다:

**Agent 1: 레이어 구조 & 네비게이션**
- 최상위 디렉토리명으로 아키텍처 패턴 추정 (Domain/, Data/, Presentation/, Feature/ 등)
- 레이어 간 import 방향 분석
- 멀티 모듈 여부 (Package.swift, SPM local packages)
- 화면 전환 패턴 (NavigationStack, Coordinator, Router, TabView 구조 등)

**Agent 2: 핵심 타입 & Protocol**
- Repository, UseCase, Service, ViewModel 등 주요 Protocol 수집
- `@Observable`, `ObservableObject` 사용 패턴
- DI 방식 (Swinject, Factory, manual injection 등)

**Agent 3: 네트워크 & 데이터**
- 네트워크 라이브러리 (Alamofire, Moya, URLSession 등)
- API 엔드포인트 정의 패턴
- DTO ↔ Entity 매핑 방식
- 로컬 저장소 (UserDefaults, CoreData, SwiftData, Realm 등)

**Agent 4: 테스트 & 빌드**
- 테스트 프레임워크 (Swift Testing, XCTest)
- 테스트 디렉토리 구조와 네이밍 패턴
- Mock/Stub 작성 패턴
- 사용 중인 Xcode scheme과 타겟

---

## Phase 2: Blueprint 생성

스캔 결과를 바탕으로 blueprint 파일을 **프로젝트 실제 구조에 맞게** 채운다.

### 2-1. package-structure.md

- 템플릿의 구조를 프로젝트 실제 디렉토리로 교체한다
- 실제로 존재하는 폴더와 역할을 기술한다
- 의존성 규칙은 import 분석 결과를 반영한다
- 파일 배치 규칙은 기존 패턴을 따른다

```markdown
# 작성 기준
- 템플릿의 {placeholder}를 실제 경로로 교체
- 프로젝트에 없는 레이어는 제거
- 프로젝트에만 있는 레이어는 추가
- 의존성 방향 다이어그램은 실제 import 기반으로 작성
```

### 2-2. interfaces.md

- 프로젝트에서 실제 사용하는 Protocol을 수집하여 기록한다
- 템플릿의 제네릭 패턴을 프로젝트 실제 패턴으로 교체한다
- 공통 타입(에러, 상태 enum 등)이 있으면 기록한다

```markdown
# 작성 기준
- 실제 프로젝트에 있는 Protocol만 기록 (없는 것을 만들지 않는다)
- 파일 경로를 함께 기록한다
- 네이밍 패턴은 기존 코드에서 추출한다
```

---

## Phase 3: 설정 초기화

### 3-1. CLAUDE.md 업데이트

```markdown
# 채울 항목:
- 기술 스택: 실제 Swift 버전, 최소 지원 버전, 프레임워크
- 아키텍처: 분석된 패턴 (MVVM, Clean, TCA 등) + blueprint 참조
- 주요 의존성: Package.swift 또는 Podfile에서 추출
```

### 3-2. scripts/build.sh 설정

- 감지된 scheme으로 `SCHEME` 값을 설정한다
- 여러 scheme이 있으면 사용자에게 선택을 요청한다

### 3-3. decisions.md 초기 기록

프로젝트에서 이미 내려진 아키텍처 결정을 기록한다:

```markdown
# 기록 대상 (코드에서 추론 가능한 것):
- 아키텍처 패턴 선택 (예: "MVVM + Clean Architecture 채택")
- UI 프레임워크 선택 (예: "SwiftUI 단독, UIKit 미사용")
- 화면 전환 방식 (예: "Coordinator 패턴", "NavigationStack 직접 사용")
- 네트워크 라이브러리 선택
- DI 방식 선택
- 상태 관리 방식 (@Observable vs ObservableObject)
```

각 결정에 대해:
- **결정**: 무엇을 선택했는가 (코드에서 확인)
- **이유**: "(기존 프로젝트에서 채택됨)" — 이유는 모르므로 추측하지 않는다
- **영향**: 이 결정이 영향을 미치는 파일/레이어

---

## Phase 4: 검증 & 보고

### 4-1. 정합성 검증

- [ ] package-structure.md의 디렉토리가 실제로 존재하는가
- [ ] interfaces.md의 Protocol이 실제로 존재하는가
- [ ] CLAUDE.md의 기술 스택이 실제와 일치하는가
- [ ] build.sh의 scheme이 유효한가
- [ ] 의존성 방향이 import 분석과 일치하는가

### 4-2. 결과 보고

```markdown
## 온보딩 결과

### 프로젝트 요약
- 프로젝트: {이름}
- 아키텍처: {패턴}
- Swift 파일: {N}개 / {M} 라인
- 테스트 파일: {N}개
- 모듈: {목록}

### 생성/수정된 파일
- blueprint/package-structure.md — {프로젝트 구조 반영}
- blueprint/interfaces.md — Protocol {N}개 기록
- tracking/decisions.md — 결정 {N}개 기록
- scripts/build.sh — scheme: {scheme명}
- CLAUDE.md — 기술 스택, 아키텍처, 의존성 업데이트

### 사용자 확인 필요
- {자동으로 판단하지 못한 항목 목록}
```

---

## 금지사항

- 프로젝트에 없는 구조를 임의로 추가하지 않는다
- 아키텍처 결정의 이유를 추측하지 않는다 (이유 불명이면 그대로 기록)
- 기존 코드를 수정하지 않는다 (`.claude/` 내 파일만 수정)
- 존재하지 않는 Protocol이나 타입을 interfaces.md에 넣지 않는다
- 스캔 결과와 맞지 않는 템플릿 내용을 그대로 남기지 않는다
