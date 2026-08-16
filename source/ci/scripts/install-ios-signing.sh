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
security import "$CERT_FILE" -k ci.keychain -P "$CERT_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" ci.keychain
security list-keychains -d user -s ci.keychain login.keychain-db

mkdir -p ~/Library/MobileDevice/"Provisioning Profiles"
# Jenkins stages the credential file read-only — cp -f removes an existing
# (possibly read-only, from a prior run) destination instead of failing to
# open it for write.
cp -f "$PROFILE_FILE" ~/Library/MobileDevice/"Provisioning Profiles"/"$IOS_PROVISIONING_PROFILE_FILENAME"

if [ "${HAS_EXTRA_PROFILES:-false}" = "true" ]; then
    unzip -o -q "$EXTRA_PROFILES_ZIP" -d ~/Library/MobileDevice/"Provisioning Profiles"
fi
