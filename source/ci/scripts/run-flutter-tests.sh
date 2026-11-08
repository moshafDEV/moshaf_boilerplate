#!/bin/bash
set -euo pipefail
# Usage: run-flutter-tests.sh <env-file>
ENV_FILE="$1"

# Same fvm-or-bare dance as build-flutter-android.sh: native Mac agent has
# fvm, the pinned Docker image doesn't need it.
if command -v fvm >/dev/null 2>&1; then
    FLUTTER="fvm flutter"
    DART="fvm dart"
    # install the SDK pinned in .fvmrc if missing (no-op when already there)
    fvm install
else
    FLUTTER="flutter"
    DART="dart"
fi

# Tests may exercise generated code (envied .env.g.dart, mocks, etc.) — same
# setup as a real build, just without the platform build step at the end.
cp "$ENV_FILE" .env
$FLUTTER pub get
# Not every project uses codegen; run build_runner only when it's installed
# (`set -e` would otherwise fail the script on a missing package).
# envied reads .env (copied above) via lib/core/env/env.dart, and env.g.dart
# is git-ignored, so build_runner has to run here.
if grep -qE '^[[:space:]]+build_runner:' pubspec.yaml; then
    # .env is a hidden file, so build_runner doesn't track changes to it:
    # without a clean, env.g.dart from a previous run (another flavor, with the
    # workspace reused via PRESERVE_WORKSPACE_NATIVE) would carry over and prod
    # could end up using the staging API.
    $DART run build_runner clean
    $DART run build_runner build --delete-conflicting-outputs
else
    echo "build_runner not in pubspec.yaml — skipping codegen."
fi
$FLUTTER test
