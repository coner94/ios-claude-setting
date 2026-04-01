# 패키지 구조 청사진

프로젝트의 디렉토리 구조를 사전에 정의한다.
planner 에이전트가 새 파일 배치를 결정할 때 이 청사진을 참조한다.

## 구조 템플릿

```
{ProjectName}/
├── App/
│   ├── {ProjectName}App.swift          # @main 진입점
│   ├── AppDelegate.swift               # (필요 시) UIKit 라이프사이클
│   └── DI/
│       └── Container.swift             # DI 컨테이너 설정
│
├── Presentation/
│   ├── {Feature}/
│   │   ├── {Feature}View.swift         # SwiftUI View
│   │   ├── {Feature}ViewModel.swift    # @Observable ViewModel
│   │   └── Components/                 # Feature 전용 UI 컴포넌트
│   └── Common/
│       ├── Components/                 # 공통 UI 컴포넌트
│       └── Modifiers/                  # 공통 ViewModifier
│
├── Domain/
│   ├── Entities/                       # 비즈니스 모델
│   ├── UseCases/                       # 비즈니스 로직 (Protocol + Impl)
│   └── Repositories/                   # Repository Protocol 정의
│
├── Data/
│   ├── Repositories/                   # Repository 구현체
│   ├── Network/
│   │   ├── APIs/                       # API 엔드포인트 정의
│   │   ├── DTOs/                       # 네트워크 응답 모델
│   │   └── NetworkService.swift        # 네트워크 클라이언트
│   └── Storage/
│       ├── UserDefaults/               # UserDefaults 래퍼
│       └── KeyChain/                   # 키체인 래퍼
│
├── Core/
│   ├── Extensions/                     # Swift 타입 Extension
│   ├── Constants/                      # 앱 상수
│   └── Utilities/                      # 유틸리티 (필요 시에만)
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.xcstrings
    └── Info.plist
```

## Tests 구조

```
{ProjectName}Tests/
├── Domain/
│   ├── UseCases/
│   │   └── {UseCase}Tests.swift
│   └── Entities/
│       └── {Entity}Tests.swift
│
├── Data/
│   ├── Repositories/
│   │   └── {Repository}Tests.swift
│   └── Network/
│       └── {API}Tests.swift
│
├── Presentation/
│   └── {Feature}/
│       └── {Feature}ViewModelTests.swift
│
└── Mocks/
    ├── Mock{Repository}.swift
    ├── Mock{UseCase}.swift
    └── {Entity}+Stub.swift
```

## 의존성 규칙

```
Presentation → Domain ← Data
                ↑
               Core
```

- **Presentation** → Domain에만 의존. Data를 직접 참조하지 않는다.
- **Domain** → 어디에도 의존하지 않는다. (순수 비즈니스 로직)
- **Data** → Domain에만 의존. (Repository Protocol 구현)
- **Core** → 어디에도 의존하지 않는다. (공통 유틸리티)
- **App** → 모든 레이어에 의존. (DI 조립)

## 파일 배치 규칙

- 새 기능은 `Presentation/{Feature}/`에 폴더를 만든다
- Entity는 `Domain/Entities/`에, UseCase는 `Domain/UseCases/`에 둔다
- Repository Protocol은 `Domain/Repositories/`, 구현체는 `Data/Repositories/`에 둔다
- DTO는 `Data/Network/DTOs/`에 두고, Entity와 분리한다
- Extension 파일명은 `{Type}+{기능}.swift` 형식을 따른다
- 테스트 파일은 소스와 동일한 디렉토리 구조를 유지한다
