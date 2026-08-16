#!/bin/bash
set -euo pipefail

# Simulasi Jenkins pipeline flow lokal
# Jalankan stages dalam order: Prepare → Unit Tests → Build Android → Build iOS
# Usage: bash ci/run-pipeline.sh [staging|production] [--skip-tests] [--ios-only] [--android-only]

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH="${1:-staging}"
SKIP_TESTS=false
IOS_ONLY=false
ANDROID_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        staging|production) BRANCH="$1"; shift ;;
        --skip-tests) SKIP_TESTS=true; shift ;;
        --ios-only) IOS_ONLY=true; shift ;;
        --android-only) ANDROID_ONLY=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_stage() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║ $1"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*"
}

log_info() {
    echo -e "${BLUE}[→]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $*"
}

# Load config
load_config() {
    log_info "Loading ci/config.groovy..."

    # Convert branch to uppercase for config keys
    BRANCH_UP=$(echo "$BRANCH" | tr '[:lower:]' '[:upper:]')

    # Extract values
    IOS_ENV_FILE=$(grep "IOS_ENV_FILE_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")
    IOS_FLAVOR=$(grep "IOS_FLAVOR_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")
    IOS_ENTRYPOINT=$(grep "IOS_ENTRYPOINT_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")
    IOS_EXPORT_OPTIONS=$(grep "^[[:space:]]*IOS_EXPORT_OPTIONS_$BRANCH_UP[[:space:]]*:" ci/config.groovy | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")

    ANDROID_ENV_FILE=$(grep "ANDROID_ENV_FILE_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")
    ANDROID_FLAVOR=$(grep "ANDROID_FLAVOR_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")
    ANDROID_ENTRYPOINT=$(grep "ANDROID_ENTRYPOINT_$BRANCH_UP" ci/config.groovy | head -1 | sed "s/.*: '//" | sed "s/',.*//" | sed "s/'$//" | tr -d " ")

    if [[ "$BRANCH" == "staging" ]]; then
        BUILD_TYPE="apk"
    else
        BUILD_TYPE="appbundle"
    fi

    log_success "Config loaded:"
    echo "  iOS: flavor=$IOS_FLAVOR, env=$IOS_ENV_FILE"
    echo "  Android: flavor=$ANDROID_FLAVOR, env=$ANDROID_ENV_FILE, type=$BUILD_TYPE"
}

# Stage 1: Prepare
stage_prepare() {
    log_stage "Stage 1: Prepare"

    log_info "Repo: $REPO_ROOT"
    log_info "Jenkinsfile: $REPO_ROOT/Jenkinsfile"
    log_info "Config: $REPO_ROOT/ci/config.groovy"
    echo ""

    # Simulate syncSource() from Jenkinsfile
    local preserve_native="${PRESERVE_WORKSPACE_NATIVE:-true}"
    local same_agent="${SAME_AGENT:-true}"

    if [ "$preserve_native" = "true" ] && [ "$same_agent" = "true" ]; then
        log_info "syncSource: Native mode (forceDiscardModify + checkout scm)"
        log_info "  forceDiscardModify(): git reset --hard HEAD"
        git reset --hard HEAD
        log_info "  checkout scm: git fetch + git checkout"
    else
        log_info "syncSource: Docker mode (unstash source)"
        log_warning "  Skipped in local test (no stash available)"
    fi

    log_info "Git status..."
    git status
    log_success "Workspace ready"
}

# Stage 2: Run Unit Tests
stage_unit_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        log_stage "Stage 2: Run Unit Tests (SKIPPED)"
        log_warning "Tests skipped with --skip-tests"
        return 0
    fi

    log_stage "Stage 2: Run Unit Tests"

    if ! command -v fvm &>/dev/null; then
        log_error "fvm not installed"
        return 1
    fi

    local test_script="$REPO_ROOT/ci/scripts/run-flutter-tests.sh"
    log_info "Script: $test_script"
    log_info "Running: fvm flutter test"
    if ! bash "$test_script" "$ANDROID_ENV_FILE"; then
        log_error "Unit tests failed"
        return 1
    fi
    log_success "Unit tests passed"
}

# Stage 3: Build Android
stage_build_android() {
    if [ "$IOS_ONLY" = true ]; then
        log_stage "Stage 3: Build Android (SKIPPED)"
        log_warning "Android skipped with --ios-only"
        return 0
    fi

    log_stage "Stage 3: Build Android APK/App Bundle"

    local android_script="$REPO_ROOT/ci/scripts/build-flutter-android.sh"
    log_info "Script: $android_script"
    log_info "Input files:"
    echo "  $REPO_ROOT/$ANDROID_ENV_FILE"
    log_info "Parameters:"
    echo "  env: $ANDROID_ENV_FILE"
    echo "  flavor: $ANDROID_FLAVOR"
    echo "  entrypoint: $ANDROID_ENTRYPOINT"
    echo "  type: $BUILD_TYPE"
    echo ""

    log_info "Running: fvm flutter build $BUILD_TYPE"
    if ! bash "$android_script" "$ANDROID_ENV_FILE" "$ANDROID_FLAVOR" "$ANDROID_ENTRYPOINT" "$BUILD_TYPE"; then
        log_error "Android build failed"
        return 1
    fi
    log_success "Android build successful"
    log_info "Output: $REPO_ROOT/build/app/outputs/"
}

# Stage 4: Build iOS
stage_build_ios() {
    if [ "$ANDROID_ONLY" = true ]; then
        log_stage "Stage 4: Build iOS (SKIPPED)"
        log_warning "iOS skipped with --android-only"
        return 0
    fi

    log_stage "Stage 4: Build iOS IPA"

    local ios_script="$REPO_ROOT/ci/scripts/build-flutter-ios.sh"
    log_info "Script: $ios_script"
    log_info "Input files:"
    echo "  $REPO_ROOT/$IOS_ENV_FILE"
    echo "  $REPO_ROOT/$IOS_EXPORT_OPTIONS"
    echo "  $REPO_ROOT/ios/Runner.xcodeproj"
    log_info "Parameters:"
    echo "  env: $IOS_ENV_FILE"
    echo "  flavor: $IOS_FLAVOR"
    echo "  entrypoint: $IOS_ENTRYPOINT"
    echo "  export options: $IOS_EXPORT_OPTIONS"
    echo ""

    log_info "Running: fvm flutter build ipa"
    if ! bash "$ios_script" "$IOS_ENV_FILE" "$IOS_FLAVOR" "$IOS_ENTRYPOINT" "$IOS_EXPORT_OPTIONS"; then
        log_error "iOS build failed"
        return 1
    fi
    log_success "iOS build successful"
    log_info "Output: $REPO_ROOT/build/ios/ipa/"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           Jenkins Pipeline Simulator - Local Mode           ║"
    echo "║         Branch: $BRANCH | Skip Tests: $SKIP_TESTS                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"

    load_config
    echo ""

    # Run stages
    if ! stage_prepare; then
        log_error "Prepare stage failed"
        exit 1
    fi

    if ! stage_unit_tests; then
        log_error "Unit tests failed"
        exit 1
    fi

    if ! stage_build_android; then
        log_error "Android build failed"
        exit 1
    fi

    if ! stage_build_ios; then
        log_error "iOS build failed"
        exit 1
    fi

    # Success summary
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    ALL STAGES PASSED ✓                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Pipeline flow completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Commit your changes: git commit -am 'fix: ...'"
    echo "  2. Manually trigger Jenkins from UI"
    echo "  3. Push when Jenkins build passes"
    echo ""
}

main "$@"
