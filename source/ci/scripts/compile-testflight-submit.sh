#!/bin/bash
set -euo pipefail
# Usage: compile-testflight-submit.sh <bundle-id> <build-number> <internal-group-id> <external-group-id> [marketing-version]
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
# Marketing version (CFBundleShortVersionString, e.g. 1.5.4). Build numbers are
# only unique WITHIN a version — after a version bump resets the build number,
# an old build can share the same number (1.5.3 (1) and 1.5.4 (1)). Looking up
# by build number alone then matches the old build (and, since the fresh upload
# is still processing, the VALID filter leaves ONLY the old one), so the job
# would silently act on the wrong build. Scope the lookup by version too.
APP_VERSION="${5:-}"

# External Beta App Review requires "What to Test" (test information) set on the
# build — the same field the manual "Submit for Review" dialog forces you to
# fill before it enables the button. Without it Apple refuses the API
# submission with INVALID_QC_STATE. Overridable via env; keep it one line and
# free of double quotes so it stays JSON-safe when baked in below.
WHATS_NEW="${TESTFLIGHT_WHATS_NEW:-Bug fixes and improvements.}"

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
APP_VERSION="$APP_VERSION"
INTERNAL_GROUP_ID="$INTERNAL_GROUP_ID"
EXTERNAL_GROUP_ID="$EXTERNAL_GROUP_ID"
WHATS_NEW="$WHATS_NEW"
HEADER
cat <<'BODY'
for tool in curl grep sed; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: required tool '$tool' not found on this agent" >&2; exit 1; }
done

asc_get() { curl --fail-with-body --show-error --silent --globoff --header "Authorization: Bearer $TOKEN" "$API_BASE$1"; }
asc_post() { curl --fail-with-body --show-error --silent --globoff --request POST --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json" --data "$2" "$API_BASE$1"; }
asc_patch() { curl --fail-with-body --show-error --silent --globoff --request PATCH --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json" --data "$2" "$API_BASE$1"; }

# Runs a one-shot write (no VALID-lag involved) with a light retry for network
# blips, and — crucially — surfaces Apple's response body on failure instead of
# letting set -e abort silently (the old `>/dev/null` swallowed the reason).
asc_write_checked() {
    method="$1"; endpoint="$2"; body="$3"; label="$4"
    for _ in $(seq 1 3); do
        set +e
        if [ "$method" = PATCH ]; then resp=$(asc_patch "$endpoint" "$body"); else resp=$(asc_post "$endpoint" "$body"); fi
        rc=$?
        set -e
        if [ $rc -eq 0 ]; then return 0; fi
        echo "WARN: $label failed (rc=$rc), retrying in 10s. Response: $resp" >&2
        sleep 10
    done
    echo "ERROR: $label failed after retries. Response:" >&2
    echo "$resp" >&2
    exit $rc
}

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

# Scope by marketing version when known, so a same-numbered build from an older
# version can never be picked up (see APP_VERSION note in the compiler).
VERSION_FILTER=""
if [ -n "$APP_VERSION" ]; then
    VERSION_FILTER="&filter[preReleaseVersion.version]=$APP_VERSION"
    echo "Looking for build $BUILD_NUMBER of version $APP_VERSION..."
else
    echo "WARNING: no marketing version given — matching by build number alone, which can hit an older version's build with the same number." >&2
fi
echo "Waiting for build $BUILD_NUMBER to finish processing (can take several minutes)..."
BUILD_ID=""
for _ in $(seq 1 40); do
    # Let Apple filter to the VALID build server-side so there's no id<->state
    # pairing to do in shell; the response data is then 0 or 1 build. Guard
    # against set -e/pipefail: a transient curl failure OR a no-match grep (build
    # not VALID yet) must mean "retry", not "abort" — hence set +e and || true.
    set +e
    RESPONSE=$(asc_get "/builds?filter[app]=$APP_ID&filter[version]=$BUILD_NUMBER$VERSION_FILTER&filter[processingState]=VALID&sort=-uploadedDate")
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
    # Ensure the build is in the external group — idempotently. A new build gets
    # added (with the externally-assignable retry); a build that is ALREADY a
    # member (an existing/approved version re-run) is left alone, so a duplicate
    # POST can't fail the whole job. Either way it ends up in the group (ET).
    GROUPS_JSON=$(asc_get "/builds/$BUILD_ID/relationships/betaGroups" 2>/dev/null || true)
    if printf '%s' "$GROUPS_JSON" | grep -q "$EXTERNAL_GROUP_ID"; then
        echo "Build already in external group $EXTERNAL_GROUP_ID, no action needed."
    else
        echo "Adding build to external group $EXTERNAL_GROUP_ID..."
        asc_post_retry "externally assignable" "/betaGroups/$EXTERNAL_GROUP_ID/relationships/builds" '{"data":[{"type":"builds","id":"'"$BUILD_ID"'"}]}'
    fi

    # "What to Test" is mandatory for external Beta App Review — the manual
    # "Submit for Review" dialog greys out its button until this is filled, and
    # the API rejects the submission with INVALID_QC_STATE if it's missing even
    # when the build shows "Ready to Submit". A build gets a betaBuildLocalization
    # per locale automatically (whatsNew empty); set whatsNew on the existing one,
    # or create an en-US one if somehow none exists yet.
    echo "Setting 'What to Test' information on the build..."
    LOC_JSON=$(asc_get "/builds/$BUILD_ID/betaBuildLocalizations" || true)
    LOC_ID=$(printf '%s' "$LOC_JSON" | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | sed -E 's/.*"([^"]*)"$/\1/' || true)
    if [ -n "$LOC_ID" ]; then
        asc_write_checked PATCH "/betaBuildLocalizations/$LOC_ID" '{"data":{"type":"betaBuildLocalizations","id":"'"$LOC_ID"'","attributes":{"whatsNew":"'"$WHATS_NEW"'"}}}' "set What to Test"
    else
        asc_write_checked POST "/betaBuildLocalizations" '{"data":{"type":"betaBuildLocalizations","attributes":{"locale":"en-US","whatsNew":"'"$WHATS_NEW"'"},"relationships":{"build":{"data":{"type":"builds","id":"'"$BUILD_ID"'"}}}}}' "create What to Test localization"
    fi

    # With What to Test set, submit for review. Only skip if there is an ACTIVE
    # submission (WAITING_FOR_REVIEW / IN_REVIEW / APPROVED) — read the related
    # submission resource and its betaReviewState, NOT the relationship linkage
    # (that false-matched and skipped the real submit, leaving builds stuck at
    # "Ready to Submit"). REJECTED/CANCELED/none -> actually submit.
    echo "Submitting build for Beta App Review (external testing)..."
    SUBMITTED=""
    CLOSED=""
    for _ in $(seq 1 20); do
        SUB=$(asc_get "/builds/$BUILD_ID/betaAppReviewSubmission" 2>/dev/null || true)
        STATE=$(printf '%s' "$SUB" | grep -Eo '"betaReviewState"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | sed -E 's/.*"([^"]*)"$/\1/' || true)
        case "$STATE" in
            WAITING_FOR_REVIEW|IN_REVIEW|APPROVED)
                echo "Build already submitted for Beta App Review (state: $STATE)."
                SUBMITTED=yes; break
                ;;
        esac
        [ -n "$STATE" ] && echo "Existing Beta App Review state: $STATE — submitting a fresh one."
        set +e
        RESP=$(asc_post "/betaAppReviewSubmissions" '{"data":{"type":"betaAppReviewSubmissions","relationships":{"build":{"data":{"type":"builds","id":"'"$BUILD_ID"'"}}}}}')
        RC=$?
        set -e
        if [ $RC -eq 0 ]; then echo "Submitted for Beta App Review."; SUBMITTED=yes; break; fi
        if echo "$RESP" | grep -q "INVALID_QC_STATE"; then
            echo "Not submittable yet (awaiting QC), rechecking in 30s. Response: $RESP" >&2
            sleep 30; continue
        fi
        # CLOSED_VERSION: the marketing version was already submitted to the App
        # Store, so Apple closes it (and prior) for external Beta App Review.
        # Don't fail — keep retrying inside the same external flow (in case the
        # state clears), and if it never does, skip external gracefully at the
        # end. Internal testing still works; bump the marketing version to
        # external-test new builds.
        if echo "$RESP" | grep -q "CLOSED_VERSION"; then
            CLOSED=yes
            echo "Version closed for external Beta App Review (already at the App Store), rechecking in 30s. Response: $RESP" >&2
            sleep 30; continue
        fi
        echo "ERROR: /betaAppReviewSubmissions failed:" >&2
        echo "$RESP" >&2
        exit $RC
    done
    if [ -z "$SUBMITTED" ]; then
        if [ -n "$CLOSED" ]; then
            echo "External submission skipped: version is closed for beta review (already at the App Store). Internal testing is available. Bump the marketing version to external-test new builds."
        else
            echo "ERROR: build never reached a submitted Beta App Review state within the wait window." >&2
            exit 1
        fi
    else
        echo "Submitted. External testers get access once Apple review clears (not instant)."
    fi
fi
BODY
