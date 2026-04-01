#!/bin/bash
# 빌드 검증 스크립트
# settings.json의 hook에서 호출된다.
#
# 사용법: .claude/scripts/build.sh [--scheme SCHEME] [--destination DEST]

SCHEME="${SCHEME:-__PROJECT_SCHEME__}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --scheme) SCHEME="$2"; shift 2 ;;
        --destination) DESTINATION="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# 스킴 미설정 확인
if [ "$SCHEME" = "__PROJECT_SCHEME__" ]; then
    echo "⚠ 빌드 스킴이 설정되지 않았습니다."
    echo "  .claude/scripts/build.sh의 SCHEME 또는 환경변수를 설정하세요."
    exit 0
fi

echo "빌드 검증 중... (scheme: $SCHEME)"
xcodebuild build \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet \
    2>&1

RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "✗ 빌드 실패."
fi
exit $RESULT
