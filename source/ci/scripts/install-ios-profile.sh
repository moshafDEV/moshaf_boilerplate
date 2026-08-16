#!/bin/bash
set -euo pipefail
# Install just the provisioning profile(s), not the certificate.
# Used when switching profiles mid-build (e.g., 'both' mode: Ad Hoc first,
# then App Store without re-importing the same cert).
# Expects $PROFILE_FILE, $IOS_PROVISIONING_PROFILE_FILENAME, and optionally
# $EXTRA_PROFILES_ZIP and $HAS_EXTRA_PROFILES (bound by Jenkins withCredentials).

PROFILES_DIR=~/Library/MobileDevice/Provisioning\ Profiles
mkdir -p "$PROFILES_DIR"

cp -f "$PROFILE_FILE" "$PROFILES_DIR/$IOS_PROVISIONING_PROFILE_FILENAME"

if [ "${HAS_EXTRA_PROFILES:-false}" = "true" ]; then
    unzip -o "$EXTRA_PROFILES_ZIP" -d "$PROFILES_DIR"
fi
