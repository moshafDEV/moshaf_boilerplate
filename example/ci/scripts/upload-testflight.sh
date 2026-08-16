#!/bin/bash
set -euo pipefail
# Usage: upload-testflight.sh <search-dir>
# Expects $APPSTORE_API_KEY_FILE (the .p8), $APPSTORE_API_KEY_ID, $APPSTORE_API_ISSUER_ID.
SEARCH_DIR="$1"

IPA_FILE=$(find "$SEARCH_DIR" -name "*.ipa" -type f | head -n 1)
if [ -z "$IPA_FILE" ]; then
    echo "ERROR: .ipa file not found under $SEARCH_DIR" >&2
    exit 1
fi

# altool resolves the API key by Key ID from a fixed lookup path — it won't
# take the .p8 content directly, so it has to be staged there first.
KEYS_DIR="$HOME/.appstoreconnect/private_keys"
mkdir -p "$KEYS_DIR"
cp -f "$APPSTORE_API_KEY_FILE" "$KEYS_DIR/AuthKey_${APPSTORE_API_KEY_ID}.p8"

xcrun altool --upload-app \
    -f "$IPA_FILE" \
    -t ios \
    --apiKey "$APPSTORE_API_KEY_ID" \
    --apiIssuer "$APPSTORE_API_ISSUER_ID"
