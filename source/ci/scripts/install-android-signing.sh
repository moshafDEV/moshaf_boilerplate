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
cp -f "$KEYSTORE_FILE" "android/app/$STORE_FILE"
