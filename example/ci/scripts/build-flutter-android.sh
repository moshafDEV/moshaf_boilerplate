#!/bin/bash
set -euo pipefail
# Usage: build-flutter-android.sh <env-file> <flavor> <entrypoint> <apk|appbundle>
ENV_FILE="$1"
FLAVOR="$2"
ENTRYPOINT="$3"
BUILD_TYPE="$4"

# Runs two different ways: inside the pinned Flutter Docker image (bare
# `flutter` is already the right version, and `fvm` isn't installed there —
# no need for it) — or natively on a Mac agent when ANDROID_BUILD_MODE=native
# (Android + iOS sharing one Mac, no Docker daemon required). `fvm` reads the
# checked-out repo's own .fvmrc, so this stays correct either way.
if command -v fvm >/dev/null 2>&1; then
    FLUTTER="fvm flutter"
    DART="fvm dart"
    # install the SDK pinned in .fvmrc if missing (no-op when already there)
    fvm install
else
    FLUTTER="flutter"
    DART="dart"
fi

# Before build_runner, not before the build: envied compiles the values from
# .env into env.g.dart, so a copy made afterwards would ship the wrong
# flavour's API URLs.
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
$FLUTTER build "$BUILD_TYPE" --release --flavor "$FLAVOR" -t "$ENTRYPOINT"
