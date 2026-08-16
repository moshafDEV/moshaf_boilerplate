#!/bin/bash
set -euo pipefail
# Usage: buildflight-upload.sh <search-dir> <apk|ipa> <platform> <filename>
# Expects $BUILD_API_TOKEN and $BUILDFLIGHT_API_URL (set via ci/config.groovy).
SEARCH_DIR="$1"
EXTENSION="$2"
PLATFORM="$3"
FILENAME="$4"

FILE=$(find "$SEARCH_DIR" -name "*.$EXTENSION" -type f | head -n 1)
if [ -z "$FILE" ]; then
    echo "ERROR: .$EXTENSION file not found under $SEARCH_DIR" >&2
    exit 1
fi

curl --fail-with-body --show-error --silent \
    --request POST \
    --url "${BUILDFLIGHT_API_URL}/api/cicd/builds" \
    --header "Authorization: Bearer $BUILD_API_TOKEN" \
    --form "file=@$FILE;filename=$FILENAME" \
    --form "platform=$PLATFORM"
