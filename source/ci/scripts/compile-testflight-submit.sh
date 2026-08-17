#!/bin/bash
set -euo pipefail
# Usage: compile-testflight-submit.sh <bundle-id> <build-number> <internal-group-id> <external-group-id>
# Env:   APPSTORE_API_KEY_FILE, APPSTORE_API_KEY_ID, APPSTORE_API_ISSUER_ID
#
# Runs ON the Mac build agent (has python3 + openssl + curl + the ASC .p8 key).
# Does all the credential-bound work up front — mints the ES256 JWT and resolves
# the App Store Connect app id — then emits to STDOUT a fully self-contained
# submission script with the token and ids baked in. The downstream job just
# executes that text; it needs only curl (no python3, no credentials, no key) —
# the controller's built-in node has curl but not python3, so the emitted body
# parses JSON with grep and lets Apple filter by processingState server-side.
#
# Token validity is 20 min (Apple's hard max for an ASC JWT). The emitted script
# must finish within that window — fine in practice, since the just-uploaded
# build is usually processed within a few minutes. If Apple processing ever runs
# past ~20 min the emitted script fails on auth and the submission is re-run.
BUNDLE_ID="$1"; BUILD_NUMBER="$2"; INTERNAL_GROUP_ID="$3"; EXTERNAL_GROUP_ID="$4"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_BASE="https://api.appstoreconnect.apple.com/v1"

TOKEN="$(python3 "$SCRIPT_DIR/generate-asc-jwt.py" "$APPSTORE_API_KEY_FILE" "$APPSTORE_API_KEY_ID" "$APPSTORE_API_ISSUER_ID")"

# Match the bundle id EXACTLY. filter[bundleId] returns every app whose bundle
# id starts with the value, so a prefix bundle (e.g. com.x.familia) also matches
# its own suffixes (com.x.familia.staging). Taking data[0] blindly can pick the
# wrong app; pick the one whose bundleId equals BUNDLE_ID.
APP_ID="$(curl --fail-with-body --show-error --silent --globoff \
    --header "Authorization: Bearer $TOKEN" \
    "$API_BASE/apps?filter[bundleId]=$BUNDLE_ID" \
    | ASC_BUNDLE_ID="$BUNDLE_ID" python3 -c "import json,os,sys; d=json.load(sys.stdin)['data']; b=os.environ['ASC_BUNDLE_ID']; m=[a['id'] for a in d if a.get('attributes',{}).get('bundleId')==b]; print(m[0] if m else '')")"
if [ -z "$APP_ID" ]; then
    echo "ERROR: no App Store Connect app found with exact bundle id $BUNDLE_ID (the app record must exist there first)" >&2
    exit 1
fi

# --- emit the self-contained executor script to stdout ----------------------
# First heredoc is UNQUOTED so the values below (token/ids) are substituted now,
# on the Mac. Second heredoc is QUOTED so the runtime logic is emitted verbatim.
cat <<HEADER
#!/usr/bin/env bash
set -euo pipefail
API_BASE="$API_BASE"
TOKEN="$TOKEN"
APP_ID="$APP_ID"
BUILD_NUMBER="$BUILD_NUMBER"
INTERNAL_GROUP_ID="$INTERNAL_GROUP_ID"
EXTERNAL_GROUP_ID="$EXTERNAL_GROUP_ID"
HEADER
cat <<'BODY'
for tool in curl grep sed; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: required tool '$tool' not found on this agent" >&2; exit 1; }
done

asc_get() { curl --fail-with-body --show-error --silent --globoff --header "Authorization: Bearer $TOKEN" "$API_BASE$1"; }
asc_post() { curl --fail-with-body --show-error --silent --globoff --request POST --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json" --data "$2" "$API_BASE$1"; }

# Apple's backend lags the VALID state by a few minutes for external-assign /
# review — retry only while the response still matches a transient pattern.
asc_post_retry() {
    pattern="$1"; endpoint="$2"; body="$3"
    for _ in $(seq 1 20); do
        set +e
        response=$(asc_post "$endpoint" "$body")
        rc=$?
        set -e
        if [ $rc -eq 0 ]; then return 0; fi
        if ! echo "$response" | grep -q "$pattern"; then
            echo "ERROR: request to $endpoint failed:" >&2
            echo "$response" >&2
            exit $rc
        fi
        # Transient per the pattern — but surface Apple's actual detail every
        # time, so a persistent 422 (e.g. missing external test info) is visible
        # instead of hiding behind a generic "retrying" line.
        echo "Apple rejected $endpoint (transient? retrying in 30s). Response: $response" >&2
        sleep 30
    done
    echo "ERROR: $endpoint still failing after the retry window. Last response:" >&2
    echo "$response" >&2
    exit 1
}

if [ -z "$INTERNAL_GROUP_ID" ] && [ -z "$EXTERNAL_GROUP_ID" ]; then
    echo "No beta group IDs configured — nothing to submit, skipping."
    exit 0
fi

echo "Waiting for build $BUILD_NUMBER to finish processing (can take several minutes)..."
BUILD_ID=""
for _ in $(seq 1 40); do
    # Let Apple filter to the VALID build server-side so there's no id<->state
    # pairing to do in shell; the response data is then 0 or 1 build. Guard
    # against set -e/pipefail: a transient curl failure OR a no-match grep (build
    # not VALID yet) must mean "retry", not "abort" — hence set +e and || true.
    set +e
    RESPONSE=$(asc_get "/builds?filter[app]=$APP_ID&filter[version]=$BUILD_NUMBER&filter[processingState]=VALID&sort=-uploadedDate")
    rc=$?
    set -e
    if [ $rc -eq 0 ]; then
        BUILD_ID=$(printf '%s' "$RESPONSE" | grep -Eo '"type"[[:space:]]*:[[:space:]]*"builds"[[:space:]]*,[[:space:]]*"id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/' || true)
        if [ -z "$BUILD_ID" ]; then
            # Fallback if key order ever differs: first "id" in the payload.
            BUILD_ID=$(printf '%s' "$RESPONSE" | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | sed -E 's/.*"([^"]*)"$/\1/' || true)
        fi
    fi
    if [ -n "$BUILD_ID" ]; then break; fi
    sleep 30
done

if [ -z "$BUILD_ID" ]; then
    echo "ERROR: build $BUILD_NUMBER never reached processingState VALID within the wait window" >&2
    exit 1
fi
echo "Build id: $BUILD_ID"

if [ -n "$INTERNAL_GROUP_ID" ]; then
    echo "Internal group $INTERNAL_GROUP_ID: build available automatically, no action needed."
fi

if [ -n "$EXTERNAL_GROUP_ID" ]; then
    echo "Waiting ~90s for the build to become externally assignable..."
    for _ in $(seq 1 3); do echo "  ...still processing, waiting..."; sleep 30; done
    echo "Adding build to external group $EXTERNAL_GROUP_ID..."
    asc_post_retry "externally assignable" "/betaGroups/$EXTERNAL_GROUP_ID/relationships/builds" '{"data":[{"type":"builds","id":"'"$BUILD_ID"'"}]}'
    echo "Submitting build for Beta App Review (external testing)..."
    asc_post_retry "INVALID_QC_STATE" "/betaAppReviewSubmissions" '{"data":{"type":"betaAppReviewSubmissions","relationships":{"build":{"data":{"type":"builds","id":"'"$BUILD_ID"'"}}}}}'
    echo "Submitted. External testers get access once Apple review clears (not instant)."
fi
BODY
