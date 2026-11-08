#!/bin/bash
set -euo pipefail
# Expects $CERT_FILE, $CERT_PASSWORD, $PROFILE_FILE, $KEYCHAIN_PASSWORD
# (bound by Jenkins withCredentials), and $IOS_PROVISIONING_PROFILE_FILENAME
# (from ci/config.groovy, broadcast as an env var in the Jenkinsfile).
#
# Optionally also $HAS_EXTRA_PROFILES + $EXTRA_PROFILES_ZIP — apps with
# extension targets (a Notification Service Extension for rich push, a Share
# Extension, etc.) need one provisioning profile PER TARGET, each with its
# own explicit bundle ID (e.g. com.example.app.NotificationService), because
# `flutter build ipa`/xcodebuild exports every embedded target, not just the
# main app. Rather than adding N more Jenkins credentials + Groovy bindings
# per extension, every extra profile is bundled into one .zip credential and
# unzipped here — install-ios-signing.sh and the Jenkinsfile don't change
# per-project no matter how many extensions a given app has.

# Throwaway keychain per build instead of unlocking login.keychain — no GUI
# session needed, and it's torn down by cleanup-ios-keychain.sh regardless
# of build outcome. Delete any stale leftover first (e.g. a prior run that
# got killed before its post{always} cleanup ran) so create doesn't fail.
security delete-keychain ci.keychain 2>/dev/null || true
security create-keychain -p "$KEYCHAIN_PASSWORD" ci.keychain
security set-keychain-settings -lut 21600 ci.keychain
security unlock-keychain -p "$KEYCHAIN_PASSWORD" ci.keychain
# Describe each credential before importing. `security import` only ever says
# "Unknown format in import" without naming what is wrong, and the cause is
# almost never the certificate itself — it is the wrong file landing in the
# Jenkins credential: a .p12 that was zipped, base64-encoded, or a
# .mobileprovision dropped into the certificate slot. Without this the only
# way to tell them apart is a manual Replay. The sha256 is printed so the
# bytes the agent received can be matched against the file on the machine
# that exported it; the .p12 contents themselves stay password-encrypted.
describe_credential() {
    local label="$1" path="$2"
    if [ ! -f "$path" ]; then
        echo "[$label] missing: $path"
        return
    fi
    echo "[$label] $(wc -c < "$path" | tr -d ' ') bytes, sha256 $(shasum -a 256 "$path" | cut -d' ' -f1)"
    echo "[$label] file(1): $(file -b "$path")"
    echo "[$label] first 4 bytes: $(head -c 4 "$path" | xxd -p)"
}

# Magic bytes: DER (.p12/.cer) starts with 0x3082 (long-form SEQUENCE), zip
# with "PK\x03\x04", base64/PEM is always ASCII.
verify_pkcs12() {
    local path="$1" magic
    magic=$(head -c 2 "$path" | xxd -p)
    case "$magic" in
        3082) ;;
        504b) echo "[cert] WRONG: this is a ZIP archive, not a .p12. Upload the .p12 itself, uncompressed." >&2; return 1 ;;
        *)
            if head -c 64 "$path" | LC_ALL=C grep -q '^[A-Za-z0-9+/=-]*$'; then
                echo "[cert] WRONG: contents are text (base64 or PEM), not a binary .p12. Upload the original file as-is." >&2
            else
                echo "[cert] WRONG: magic bytes 0x$magic are not a .p12 (expected 0x3082)." >&2
            fi
            return 1 ;;
    esac
    # A usable .p12 must carry a pkcs8ShroudedKeyBag (OID 1.2.840.113549.1.12.10.1.2).
    # Without it the file holds only the certificate: the import still succeeds,
    # and the build fails much later in codesign with "No signing certificate
    # found" — an error that points nowhere near the actual cause.
    if command -v openssl >/dev/null 2>&1; then
        if openssl asn1parse -inform DER -in "$path" 2>/dev/null | grep -qi '2A864886F70D010C0A0102'; then
            echo "[cert] contains a private key (pkcs8ShroudedKeyBag) — OK"
        else
            echo "[cert] WARNING: no private key inside, certificate only." >&2
            echo "[cert] Re-export from Keychain Access selecting the identity's parent row, not the certificate alone." >&2
        fi
    fi
}

# A .mobileprovision is a CMS-signed plist, so file(1) can only call it
# "data". Decode it instead: a mismatched team, an expired profile or an
# app-identifier that does not match the target are all invisible until
# xcodebuild fails at export time with a generic message.
describe_profile() {
    local label="$1" path="$2" plist type devices
    [ -f "$path" ] || { echo "[$label] missing: $path"; return; }
    plist=$(security cms -D -i "$path" 2>/dev/null) || { echo "[$label] not a valid .mobileprovision (CMS decode failed)"; return; }
    extract() { printf '%s' "$plist" | plutil -extract "$1" raw - 2>/dev/null; }
    # ProvisionsAllDevices marks an Enterprise in-house profile; a device list
    # means Ad Hoc or Development; neither means App Store.
    if [ "$(extract ProvisionsAllDevices)" = "true" ]; then
        type="enterprise (in-house)"
    elif devices=$(extract ProvisionedDevices.0) && [ -n "$devices" ]; then
        type="ad hoc / development"
    else
        type="app store"
    fi
    echo "[$label] name:    $(extract Name)"
    echo "[$label] app id:  $(extract Entitlements.application-identifier)"
    echo "[$label] team:    $(extract TeamIdentifier.0)"
    echo "[$label] type:    $type"
    echo "[$label] expires: $(extract ExpirationDate)"
    echo "[$label] uuid:    $(extract UUID)"
}

describe_credential cert "$CERT_FILE"
describe_credential profile "$PROFILE_FILE"
describe_profile profile "$PROFILE_FILE"
if [ "${HAS_EXTRA_PROFILES:-false}" = "true" ]; then
    describe_credential extra-profiles "$EXTRA_PROFILES_ZIP"
    # Names only here — each profile is decoded in full after it is unpacked.
    unzip -l "$EXTRA_PROFILES_ZIP" 2>/dev/null | awk 'NR>3 && $4 != "" {print "[extra-profiles] " $4}' || true
fi
verify_pkcs12 "$CERT_FILE"

# -f pkcs12 is not optional here. `security import` picks the format from the
# FILE EXTENSION, not the contents, and Jenkins stages a secret file under a
# temporary name that does not end in .p12 — so a perfectly valid certificate
# is rejected with "Unknown format in import" before its bytes are ever read.
# Naming the format explicitly removes the guess.
#
# A wrong password and a genuinely wrong file then print different messages —
# split them so it is obvious which credential needs fixing.
if ! import_out=$(security import "$CERT_FILE" -k ci.keychain -P "$CERT_PASSWORD" -f pkcs12 -T /usr/bin/codesign -T /usr/bin/security 2>&1); then
    echo "$import_out" >&2
    case "$import_out" in
        *"MAC verification failed"*|*"passphrase you entered is not correct"*|*"invalid password"*)
            echo "[cert] Password does not match this .p12 — fix the CERT_PASSWORD credential, not the file." >&2 ;;
        *)
            echo "[cert] The .p12 itself was rejected. Compare the sha256 above with the source file on the machine that exported it." >&2 ;;
    esac
    exit 1
fi
[ -n "$import_out" ] && echo "$import_out"

# Ask the keychain what it actually holds rather than parsing the import
# output: with -f pkcs12 `security` succeeds silently, so the old
# "1 identity imported" wording is not emitted at all. An identity is a
# certificate with its private key — without one codesign has nothing to
# sign with, however healthy the import looked.
# Authorise codesign to use the imported key without an interactive prompt,
# then put ci.keychain into the user's keychain search list — xcodebuild looks
# up signing identities through that list and cannot see a keychain that is
# only referenced by name.
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" ci.keychain >/dev/null
security list-keychains -d user -s ci.keychain login.keychain-db

identity_count=$(security find-identity -v -p codesigning ci.keychain 2>/dev/null | awk '/^ *[0-9]+\)/ {c++} END {print c+0}')
if [ "$identity_count" -gt 0 ]; then
    echo "[cert] $identity_count signing identity/identities available in ci.keychain"
else
    echo "[cert] WARNING: no usable signing identity in the keychain after import — codesign will fail." >&2
fi

# What xcodebuild will see: it consults the user's keychain SEARCH LIST, not
# ci.keychain by name. If these two disagree, the search list is the problem,
# not the certificate.
echo "[chain] keychain search list: $(security list-keychains -d user | tr -d ' "' | tr '\n' ' ')"
echo "[chain] identities visible via the search list: $(security find-identity -v -p codesigning 2>/dev/null | awk '/^ *[0-9]+\)/ {c++} END {print c+0}')"
security find-certificate -a ci.keychain 2>/dev/null | awk -F'"' '/"labl"/ {print "[chain] in ci.keychain: " $4}'

# A profile embeds the exact certificates it will accept. When the cert and
# the profile come from different credentials — as they do in this setup — they can
# drift apart silently: both files are individually valid, so every check
# above passes, and the build only dies at export with "doesn't include
# signing certificate". Comparing SHA-1 fingerprints catches it up front.
check_cert_matches_profile() {
    local keychain_shas profile_plist i b64 sha
    # find-certificate -Z rather than find-identity: the latter filters on
    # extended key usage and stays silent for anything it does not consider a
    # codesigning identity, which would turn a real mismatch into no output.
    keychain_shas=$(security find-certificate -a -Z ci.keychain 2>/dev/null | awk '/SHA-1 hash:/ {print $3}')
    [ -n "$keychain_shas" ] || return 0
    profile_plist=$(security cms -D -i "$PROFILE_FILE" 2>/dev/null) || return 0
    i=0
    while b64=$(printf '%s' "$profile_plist" | plutil -extract "DeveloperCertificates.$i" raw - 2>/dev/null) && [ -n "$b64" ]; do
        sha=$(printf '%s' "$b64" | base64 -d 2>/dev/null | shasum | awk '{print toupper($1)}')
        if printf '%s\n' "$keychain_shas" | grep -qi "^$sha$"; then
            echo "[cert] $sha matches a certificate listed in the profile — OK"
            return 0
        fi
        i=$((i + 1))
    done
    echo "[cert] WARNING: none of the imported certificates are among the $i certificate(s) this profile accepts." >&2
    echo "[cert]   imported: $(printf '%s' "$keychain_shas" | tr '\n' ' ')" >&2
    echo "[cert] The certificate and the profile belong to different identities — codesign will fail at export." >&2
    echo "[cert] Either upload the .p12 the profile was built against, or regenerate the profile against this certificate." >&2
}
check_cert_matches_profile

mkdir -p ~/Library/MobileDevice/"Provisioning Profiles"
# Jenkins stages the credential file read-only — cp -f removes an existing
# (possibly read-only, from a prior run) destination instead of failing to
# open it for write.
cp -f "$PROFILE_FILE" ~/Library/MobileDevice/"Provisioning Profiles"/"$IOS_PROVISIONING_PROFILE_FILENAME"

if [ "${HAS_EXTRA_PROFILES:-false}" = "true" ]; then
    unzip -o -q "$EXTRA_PROFILES_ZIP" -d ~/Library/MobileDevice/"Provisioning Profiles"
fi
