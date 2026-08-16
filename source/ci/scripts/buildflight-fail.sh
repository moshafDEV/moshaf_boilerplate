#!/bin/bash
set -euo pipefail
# Usage: buildflight-fail.sh <bundle-id> <platform>
# Expects $BUILD_API_TOKEN and $BUILDFLIGHT_API_URL (set via ci/config.groovy).
BUNDLE_ID="$1"
PLATFORM="$2"

curl --fail-with-body --show-error --silent \
    --request POST \
    --url "${BUILDFLIGHT_API_URL}/api/cicd/builds/fail" \
    --header "Authorization: Bearer $BUILD_API_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"bundle_id\":\"$BUNDLE_ID\",\"platform\":\"$PLATFORM\"}"
