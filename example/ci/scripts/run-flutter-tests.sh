#!/bin/bash
set -euo pipefail
# Usage: run-flutter-tests.sh <env-file>
ENV_FILE="$1"

# Same fvm-or-bare dance as build-flutter-android.sh: native Mac agent has
# fvm, the pinned Docker image doesn't need it.
if command -v fvm >/dev/null 2>&1; then
    FLUTTER="fvm flutter"
    DART="fvm dart"
else
    FLUTTER="flutter"
    DART="dart"
fi

# Tests may exercise generated code (envied .env.g.dart, mocks, etc.) — same
# setup as a real build, just without the platform build step at the end.
cp "$ENV_FILE" .env
$FLUTTER pub get
$DART run build_runner build --delete-conflicting-outputs
$FLUTTER test
