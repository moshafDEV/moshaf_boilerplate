# run-pipeline.sh — Jenkins Pipeline Simulator

Simulates the Jenkins pipeline flow locally, matching the Jenkinsfile stages.

## Usage

```bash
bash ci/run-pipeline.sh [staging|production] [options]
```

## Examples

### Full pipeline (staging)
```bash
bash ci/run-pipeline.sh staging
# Runs: Prepare → Unit Tests → Build Android → Build iOS
```

### Skip unit tests
```bash
bash ci/run-pipeline.sh staging --skip-tests
```

### Android only
```bash
bash ci/run-pipeline.sh staging --android-only
# Runs: Prepare → Unit Tests → Build Android
```

### iOS only
```bash
bash ci/run-pipeline.sh staging --ios-only
# Runs: Prepare → Unit Tests → Build iOS
```

### Production build
```bash
bash ci/run-pipeline.sh production
```

### Combine options
```bash
bash ci/run-pipeline.sh staging --skip-tests --android-only
# Runs: Prepare → Build Android (no tests, no iOS)
```

## Stages

**1. Prepare** — Git checkout & workspace validation

**2. Run Unit Tests** — `flutter test` (skip with `--skip-tests`)

**3. Build Android** — `flutter build apk` (staging) or `appbundle` (production)

**4. Build iOS** — `flutter build ipa`

## Options

| Option | Description |
|--------|-------------|
| `staging` | Build for staging environment (default) |
| `production` | Build for production environment |
| `--skip-tests` | Skip unit tests stage |
| `--android-only` | Run Android build only (still runs Prepare + Tests) |
| `--ios-only` | Run iOS build only (still runs Prepare + Tests) |

## Configuration

Script extracts parameters from `ci/config.groovy`:
- `IOS_ENV_FILE_STAGING/PRODUCTION`
- `IOS_FLAVOR_STAGING/PRODUCTION`
- `IOS_ENTRYPOINT_STAGING/PRODUCTION`
- `IOS_EXPORT_OPTIONS_STAGING/PRODUCTION`
- `ANDROID_ENV_FILE_STAGING/PRODUCTION`
- `ANDROID_FLAVOR_STAGING/PRODUCTION`
- `ANDROID_ENTRYPOINT_STAGING/PRODUCTION`

No need to edit script — all config is in `ci/config.groovy`.

## Output

Shows each stage with:
- Stage name
- Parameters (env file, flavor, entrypoint, etc)
- Real build output
- Success/failure status

Exit code: **0** if all stages pass, **1** if any stage fails

## Workflow

```bash
# 1. Edit Jenkinsfile/scripts locally
vim Jenkinsfile

# 2. Test with pipeline simulator
bash ci/run-pipeline.sh staging --skip-tests --android-only

# 3. If OK, commit
git commit -am "fix: ..."

# 4. Manually trigger Jenkins from UI (don't push yet)

# 5. If Jenkins passes, push to git
git push origin staging
```

## Troubleshooting

### "fvm not installed"
```bash
brew install fvm
```

### Build fails
Check error output in console. Script exits immediately on failure.

### "Module not found" or gradle errors
```bash
# Clean and retry
flutter clean
bash ci/run-pipeline.sh staging --skip-tests --android-only
```

### Android build fails with an "AAR metadata"/compileSdk mismatch
`android/app/build.gradle.kts` sets `compileSdk = maxOf(flutter.compileSdkVersion, 37)` — a floor, since `flutter_secure_storage` requires compileSdk 37 while Flutter's own default is still lower as of this writing. Building against it requires Android SDK Platform 37 to be installed on this agent, not just on developer machines — Android Studio auto-downloads a missing platform interactively, but a headless CI agent won't prompt for the SDK license, so install it explicitly once per agent:
```bash
sdkmanager "platforms;android-37"   # bump to match compileSdk's floor if that number changes
```

## Requirements

- `fvm` installed
- Flutter SDK via fvm
- Android SDK Platform 37 (or whatever `compileSdk`'s floor in `android/app/build.gradle.kts` currently is) installed on the agent
- `.env.dev` and `.env.prod` files exist
- Export options plist files exist (iOS)

## Notes

- Script uses `fvm flutter` (respects `.fvmrc` version)
- Generated files from `build_runner` are handled in build scripts
- Git state is shown in Prepare stage
- Full build output is shown (not filtered)
