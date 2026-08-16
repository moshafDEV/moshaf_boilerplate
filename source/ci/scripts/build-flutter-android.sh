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
else
    FLUTTER="flutter"
    DART="dart"
fi

# Before build_runner, not before the build: envied compiles the values from
# .env into env.g.dart, so a copy made afterwards would ship the wrong
# flavour's API URLs.
cp "$ENV_FILE" .env
$FLUTTER pub get
$DART run build_runner build --delete-conflicting-outputs
$FLUTTER build "$BUILD_TYPE" --release --flavor "$FLAVOR" -t "$ENTRYPOINT"
