---
name: init-deep
description: 프로젝트 폴더 구조를 깊이 탐색하여 주요 디렉토리마다 CLAUDE.md를 계층적으로 생성한다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Agent
---

# init-deep — 계층적 CLAUDE.md 생성

프로젝트의 폴더 구조와 모듈을 깊이 탐색하여, 의미 있는 디렉토리마다 CLAUDE.md를 생성한다.

## 인자

- `$ARGUMENTS` 없음: 기존 CLAUDE.md 유지 + 새로 필요한 곳에 생성
- `--create-new`: 기존 CLAUDE.md 모두 삭제 후 재생성
- `--max-depth=N`: 탐색 깊이 제한 (기본값: 3)

---

## Phase 1: 탐색 & 분석

### 1-1. 구조 분석 (Bash)

아래 명령을 실행하여 프로젝트 구조를 파악한다:

```bash
# 디렉토리별 파일 수
find . -type f -not -path '*/\.*' -not -path '*/Pods/*' -not -path '*/DerivedData/*' -not -path '*/.build/*' | sed 's|/[^/]*$|/|' | sort | uniq -c | sort -rn | head -30

# 디렉토리 트리 (depth 제한)
find . -type d -not -path '*/\.*' -not -path '*/Pods/*' -not -path '*/DerivedData/*' -not -path '*/.build/*' -maxdepth 4 | sort

# 총 파일 수 & 코드 라인 수
find . -type f -name '*.swift' -not -path '*/Pods/*' -not -path '*/DerivedData/*' | wc -l
find . -type f -name '*.swift' -not -path '*/Pods/*' -not -path '*/DerivedData/*' -exec cat {} + 2>/dev/null | wc -l
```

### 1-2. 코드 분석 (병렬 Agent)

Agent를 활용하여 아래 항목을 병렬로 탐색한다:

1. **진입점 & 앱 구조**: @main, App, Scene, ContentView 등
2. **모듈/패키지 구조**: Package.swift, .xcodeproj 내 타겟, 멀티모듈 구성
3. **주요 프로토콜 & 인터페이스**: Repository, UseCase, Service 등 핵심 추상화
4. **의존성 그래프**: import 관계, 레이어 간 참조 방향

### 1-3. 기존 CLAUDE.md 수집

```bash
find . -name 'CLAUDE.md' -not -path '*/\.*' | sort
```

- `--create-new` 모드: 기존 파일 내용을 읽은 뒤 모두 삭제
- 업데이트 모드: 기존 파일 내용을 읽고 보존, 새로 필요한 곳만 추가

---

## Phase 2: 스코어링 & 위치 결정

각 디렉토리를 아래 기준으로 스코어링한다:

| 항목 | 가중치 | 설명 |
|---|---|---|
| 파일 수 | 3x | Swift 파일이 5개 이상이면 가산 |
| 하위 디렉토리 수 | 2x | 서브 폴더가 3개 이상이면 가산 |
| 코드 비율 | 2x | 전체 파일 중 소스 코드 비율 |
| 심볼 밀도 | 2x | class, struct, protocol, enum 정의 수 |
| 참조 중심성 | 3x | 다른 모듈에서 import되는 빈도 |

### 생성 기준

| 스코어 | 판단 |
|---|---|
| 15 이상 | CLAUDE.md 생성 |
| 8 ~ 14 | 독립된 도메인/모듈일 때만 생성 |
| 7 이하 | 생성하지 않음 |

**항상 생성하는 위치:**
- 프로젝트 루트 (이미 있으면 업데이트)
- 멀티모듈의 각 모듈 루트

**생성하지 않는 위치:**
- Pods, DerivedData, .build, node_modules
- 리소스만 있는 디렉토리 (Assets, Fonts 등)
- 테스트 디렉토리 (단, 복잡한 테스트 인프라가 있으면 예외)

---

## Phase 3: CLAUDE.md 생성

### 루트 CLAUDE.md (50~150줄)

루트에 이미 CLAUDE.md가 있으면 아래 항목이 빠져있는지 확인하고 보완한다:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 개요
{프로젝트 한 줄 설명}

## 기술 스택
{언어, 프레임워크, 최소 지원 버전, 의존성 매니저}

## 아키텍처
{전체 아키텍처 다이어그램 + 레이어 설명}

## 모듈 구조
{각 모듈/디렉토리의 역할 요약, 하위 CLAUDE.md 위치 안내}

## 빌드 & 실행
{빌드, 테스트, 린트 명령어}

## 컨벤션
{.claude/rules/ 파일 참조}
```

### 하위 디렉토리 CLAUDE.md (30~80줄)

```markdown
# {디렉토리명}

## 역할
{이 모듈/디렉토리가 하는 일}

## 주요 컴포넌트
{핵심 파일, 클래스, 프로토콜과 역할}

## 의존 관계
{이 모듈이 의존하는 것, 이 모듈에 의존하는 것}

## 작업 시 주의사항
{이 영역 작업 시 알아야 할 비자명한 규칙이나 제약}
```

---

## Phase 4: 검증 & 정리

생성된 모든 CLAUDE.md를 검토한다:

### 중복 제거
- 상위 CLAUDE.md에 이미 있는 내용을 하위에서 반복하지 않는다
- "코드를 깨끗하게 작성하세요" 같은 일반론은 삭제한다

### 품질 체크
- [ ] 코드를 읽으면 알 수 있는 내용을 반복하고 있지 않은가
- [ ] 추측이 아닌 실제 코드 분석에 기반한 내용인가
- [ ] 상위/하위 간 중복이 없는가

### 결과 보고

생성 완료 후 사용자에게 요약을 보여준다:

```
생성된 CLAUDE.md:
  - ./CLAUDE.md (업데이트)
  - ./Features/Auth/CLAUDE.md (신규)
  - ./Core/Network/CLAUDE.md (신규)
  ...

총 N개 파일 생성, M개 업데이트
```

---

## 금지사항

- 파일/폴더 목록을 단순 나열하지 않는다 (tree 명령 결과 붙여넣기 금지)
- 코드 주석에 이미 있는 설명을 복사하지 않는다
- "~하면 좋습니다" 같은 제안형 문장을 쓰지 않는다. 사실만 기술한다
- 확실하지 않은 내용은 생략한다
- 빈 섹션을 남기지 않는다
