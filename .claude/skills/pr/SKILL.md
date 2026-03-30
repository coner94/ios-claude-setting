---
name: pr
description: git-flow.md, pr-template.md 규칙에 맞게 PR을 생성한다. git 에이전트가 호출하거나 사용자가 /pr로 직접 호출할 수 있다.
allowed-tools: Read, Glob, Grep, Bash
---

# Pull Request 생성

`.claude/rules/git-flow.md`와 `.claude/rules/pr-template.md` 규칙에 따라 PR을 생성한다.
git 에이전트가 호출하거나, 사용자가 `/pr`로 직접 호출할 수 있다.

## 인자

- `$ARGUMENTS`: PR 관련 정보 (선택)
  - 예: `/pr`
  - 예: `/pr PROJ-123`
  - 예: `/pr base:main`

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

### 본문

- `.claude/rules/pr-template.md` 규칙에 따라 본문을 작성한다
- diff를 분석하여 필수/선택 섹션을 자동으로 채운다
- 해당 없는 섹션은 제거한다 (빈 섹션 금지)
- PR 크기가 300줄 초과 시 경고를 출력한다

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
