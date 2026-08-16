#!/bin/bash
set -euo pipefail
# Usage: buildflight-start.sh <bundle-id> <platform> <version> <build>
# Expects $BUILD_API_TOKEN and $BUILDFLIGHT_API_URL (set via ci/config.groovy).
# version/build are explicit args, not read from pubspec.yaml here — iOS's
# real CFBundleVersion doesn't always match pubspec.yaml (project.pbxproj
# can hardcode its own FLUTTER_BUILD_NUMBER, which then wins over pubspec.yaml
# at build time), so the Jenkinsfile passes whichever value is actually true
# for the platform being reported.
BUNDLE_ID="$1"
PLATFORM="$2"
VERSION="$3"
BUILD="$4"

curl --fail-with-body --show-error --silent \
    --request POST \
    --url "${BUILDFLIGHT_API_URL}/api/cicd/builds/start" \
    --header "Authorization: Bearer $BUILD_API_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"bundle_id\":\"$BUNDLE_ID\",\"platform\":\"$PLATFORM\",\"version\":\"$VERSION\",\"build\":\"$BUILD\"}"
