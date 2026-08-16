#!/bin/bash
set -euo pipefail
# Usage: upload-playstore.sh <service-account-json> <package-name> <aab-file> <track>
# Uploads an .aab and assigns it to a Play Console track (e.g. 'internal') via
# the Play Developer Publishing API — no Gradle plugin, plain curl, same
# style as the App Store Connect scripts.
KEY_FILE="$1"
PACKAGE_NAME="$2"
AAB_FILE="$3"
TRACK="$4"

# curl's --fail-with-body still emits Google's actual error JSON on a 4xx/5xx
# — but piping that straight into a python parser expecting a success field
# (e.g. 'versionCode') just dies with a KeyError and hides the real reason.
# This checks the curl exit code first so a failure prints Google's message
# instead.
call_api() {
    local response rc
    set +e
    response=$(curl --fail-with-body --show-error --silent "$@")
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
        echo "ERROR: Play Developer API request failed:" >&2
        echo "$response" >&2
        exit $rc
    fi
    echo "$response"
}

JWT=$(python3 "$(dirname "$0")/generate-google-jwt.py" "$KEY_FILE" "https://www.googleapis.com/auth/androidpublisher")

ACCESS_TOKEN=$(call_api \
    --request POST \
    --url "https://oauth2.googleapis.com/token" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" \
    --data-urlencode "assertion=${JWT}" \
    | python3 -c "import json, sys; print(json.load(sys.stdin)['access_token'])")

# Every change (upload, track assignment) happens inside one "edit" — nothing
# is live until it's explicitly committed at the end.
EDIT_ID=$(call_api \
    --request POST \
    --url "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/edits" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    | python3 -c "import json, sys; print(json.load(sys.stdin)['id'])")

VERSION_CODE=$(call_api \
    --request POST \
    --url "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/bundles?uploadType=media" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary "@${AAB_FILE}" \
    | python3 -c "import json, sys; print(json.load(sys.stdin)['versionCode'])")

call_api \
    --request PUT \
    --url "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/tracks/${TRACK}" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "{\"releases\":[{\"versionCodes\":[\"${VERSION_CODE}\"],\"status\":\"completed\"}]}" \
    > /dev/null

call_api \
    --request POST \
    --url "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/edits/${EDIT_ID}:commit" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    > /dev/null

echo "Uploaded versionCode ${VERSION_CODE} to Play Console track '${TRACK}'"
