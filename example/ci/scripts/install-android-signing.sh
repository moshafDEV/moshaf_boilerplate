#!/bin/bash
set -euo pipefail
# Expects $KEYSTORE_FILE and $KEY_PROPERTIES_FILE (bound by Jenkins withCredentials).

# storeFile in key.properties is the single source of truth for the
# keystore's filename — read it back instead of assuming one, so the two
# secrets can't drift out of sync with each other.
# -f: Jenkins Secret-file credentials are staged read-only, and so is a
# prior run's copy at the destination — plain cp can't open that for
# writing on a retry/second run, hence -f (same fix as install-ios-signing.sh).
cp -f "$KEY_PROPERTIES_FILE" android/key.properties
STORE_FILE=$(grep ^storeFile= android/key.properties | cut -d= -f2-)
# storeFile comes in two valid shapes, depending on how build.gradle(.kts)
# resolves it:
#   - bare name ("release.jks")      -> resolved relative to android/app/
#   - path with a dir ("app/x.jks")  -> resolved relative to android/, i.e. a
#     project using rootProject.file()
# Without telling them apart the second shape becomes android/app/app/x.jks
# and cp fails.
case "$STORE_FILE" in
    */*) KEYSTORE_DEST="android/$STORE_FILE" ;;
    *)   KEYSTORE_DEST="android/app/$STORE_FILE" ;;
esac
mkdir -p "$(dirname "$KEYSTORE_DEST")"
cp -f "$KEYSTORE_FILE" "$KEYSTORE_DEST"
