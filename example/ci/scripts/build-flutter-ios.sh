#!/bin/bash
set -euo pipefail
# Usage: build-flutter-ios.sh <env-file> <flavor> <entrypoint> <export-options-plist>
#
# Uses `fvm flutter`/`fvm dart` instead of the bare commands — fvm reads the
# checked-out repo's own .fvmrc and resolves/installs the matching SDK, so
# this stays correct regardless of what's globally on PATH on this Mac agent
# (which may run other Flutter projects pinned to other versions).
ENV_FILE="$1"
FLAVOR="$2"
ENTRYPOINT="$3"
EXPORT_OPTIONS_PLIST="$4"

if ! command -v fvm >/dev/null 2>&1; then
    echo "fvm not found on this agent. Install it (e.g. brew install fvm) and try again." >&2
    exit 1
fi

GOOGLE_SERVICE_INFO="ios/Runner/GoogleService-Info-${FLAVOR}.plist"
if [ ! -f "$GOOGLE_SERVICE_INFO" ]; then
    echo "$GOOGLE_SERVICE_INFO not found" >&2
    exit 1
fi
cp "$GOOGLE_SERVICE_INFO" ios/Runner/GoogleService-Info.plist

fvm install
cp "$ENV_FILE" .env
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs

# Clean pods if pod install fails (outdated specs or lock file conflicts)
echo "Running pod install..."
if ! fvm flutter build ipa --release --flavor "$FLAVOR" -t "$ENTRYPOINT" --export-options-plist="$EXPORT_OPTIONS_PLIST"; then
    echo "First build attempt failed, cleaning pods and retrying..."
    rm -f ios/Podfile.lock
    fvm flutter build ipa --release --flavor "$FLAVOR" -t "$ENTRYPOINT" --export-options-plist="$EXPORT_OPTIONS_PLIST"
fi
