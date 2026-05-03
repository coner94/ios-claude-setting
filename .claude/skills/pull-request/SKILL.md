---
name: pull-request
description: PR을 생성한다.
allowed-tools: Read, Glob, Grep, Bash
---

# Pull Request 생성

PR을 생성한다.

## When to Activate

- `git-manager` 에이전트가 PR 생성을 요청할 때
- 사용자가 `/pull-request`로 직접 호출할 때

## 인자

- `$ARGUMENTS`: PR 관련 정보 (선택)
  - 예: `/pull-request`
  - 예: `/pull-request PROJ-123`
  - 예: `/pull-request base:main`

---

## Phase 1: 상태 확인

```bash
# 현재 브랜치 확인
git branch --show-current

# 커밋되지 않은 변경 확인
git status

# base 브랜치와의 diff 확인
git log {base}...HEAD --oneline
git diff {base}...HEAD --stat
```

- 커밋되지 않은 변경이 있으면 먼저 커밋을 안내한다
- base 브랜치 판단:
  - `$ARGUMENTS`에 `base:`가 있으면 해당 브랜치 사용
  - 다른 feature 브랜치에서 분기한 경우 → 해당 브랜치가 base
  - feature/bugfix/refactor → `develop`
  - hotfix → `main`
  - 판단 기준: `git log --oneline --graph`로 분기 원점 확인

---

## Phase 2: PR 내용 작성

### 제목
```
[티켓번호] 간결한 설명 (70자 이내)
```
- `$ARGUMENTS`에 티켓번호가 있으면 사용
- 없으면 `[NO-TICKET]`

### 본문 템플릿

diff를 분석하여 아래 템플릿을 채운다.
- 해당 없는 선택 섹션은 완전히 제거한다 (빈 섹션 금지)
- PR 크기가 300줄 초과 시 경고를 출력한다
- 자동 생성 파일(xib, storyboard, 패키지)은 줄 수 계산에서 제외한다

```markdown
## 개요

{변경 사항 1~2줄 요약}

## 변경 내용

- {변경 항목 1}
- {변경 항목 2}

## 테스트

- [ ] {테스트 항목 1}
- [ ] {테스트 항목 2}

<!-- 아래 선택 섹션은 해당할 때만 포함 -->

## 다이어그램

```mermaid
{복잡한 로직 변경 시 Mermaid 다이어그램}
```

## 스크린샷

| Before | After |
|--------|-------|
| {이전 스크린샷} | {이후 스크린샷} |

## 참고 사항

{리뷰어가 알아야 할 컨텍스트}
```

---

## Phase 3: PR 생성

```bash
# 리모트 푸시 (아직 안 된 경우)
git push -u origin {branch-name}

# PR 생성
gh pr create --base {base} --title "{title}" --body "{body}"
```

---

## Phase 4: 결과 보고

```markdown
## PR 생성 완료

- PR: {PR URL}
- 브랜치: {branch} → {base}
- 변경: +{additions} -{deletions} ({files} files)
```
