#!/bin/bash
# 커밋 전 SwiftLint 검증 스크립트
# settings.json의 PreToolUse hook에서 호출된다.

# SwiftLint 설치 확인
if ! command -v swiftlint &> /dev/null; then
    echo "⚠ SwiftLint가 설치되어 있지 않습니다. 린트를 건너뜁니다."
    echo "  설치: brew install swiftlint"
    exit 0
fi

# 변경된 Swift 파일만 린트 (staged files)
STAGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.swift')

if [ -z "$STAGED_SWIFT_FILES" ]; then
    exit 0
fi

echo "SwiftLint 검증 중..."
echo "$STAGED_SWIFT_FILES" | xargs swiftlint lint --strict --quiet

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "✗ SwiftLint 위반 발견. 수정 후 다시 커밋하세요."
fi
exit $RESULT
