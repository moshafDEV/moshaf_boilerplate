# Changelog

## 3.0.0
- Fixed a fresh `create`'s first Android build always failing with an AAR metadata error (`flutter_secure_storage` requires `compileSdk 37`; Flutter's own default is still lower regardless of Flutter version) — `android/app/build.gradle.kts` now sets `compileSdk = maxOf(flutter.compileSdkVersion, 37)` right after `flutter create`. Requires Android SDK Platform 37 installed on whatever machine builds the project (documented in the root/per-project README and `ci/docs/RUN-PIPELINE.md`, including for CI agents, which won't auto-download it the way Android Studio does interactively).
- Translated the remaining Indonesian UI strings in the example login/welcome flow to English (`welcome_page.dart`'s "Mulai" button, the whole login screen — greeting, field hints, "Forgot Password", the login button, "Sign up here." — and the shared `Validators` messages), so the example pages are consistently English end to end; added `docs/release/` (a standalone offline store-launch-checklist tool) to both READMEs and the directory structure.
- Synced the Jenkins CI (`Jenkinsfile` + `ci/`) with the latest state of the original Flutter app it was ported from: `build-flutter-ios.sh` now uploads dSYMs to Crashlytics right after the archive that produces them (previously never uploaded at all, `flutter build ipa` doesn't do this on its own); added `cleanup{}` blocks so a cancelled (not just failed) build still closes out its local build-timeline file instead of leaving a stuck "running" row; `report-stage-status.py` now writes one timeline file per build (`~/jenkins-agent/builds/<job>#<build>.json`) instead of a single shared file, so overlapping jobs/branches on a shared agent can no longer clobber each other's timeline; `compile-testflight-submit.sh` now scopes its build lookup by marketing version (build numbers repeat across versions), sets the mandatory "What to Test" localization before submitting for external Beta App Review (previously failed with `INVALID_QC_STATE`), adds the build to its external group idempotently, and correctly detects/skips an already-submitted or already-closed review instead of erroring or double-submitting.
- Pre-release audit: fixed the developer-tools floating button defaulting to the same corner as the flavor banner ribbon (now bottom-left, was bottom-right); replaced the default `flutter create`-provided `test/widget_test.dart` (referenced a nonexistent `MyApp` class, always failed) with a minimal test that actually passes — every fresh `create` now runs its whole test suite clean, first time this has been true; brought `PROJECT_BLUEPRINT.md` up to date with the Developer Tools and Feature Flags systems (new §11/§12, folder structure, flavor/environment section rewritten for 3 flavors + shared applicationId), and removed a stale `chucker_flutter` code sample left over from its removal.
- Added a second `create` prompt for a human-facing app display name, separate from the project name (which stays a strict Dart-identifier `snake_case` value) — press Enter to derive one automatically (`moshaf_app` → `Moshaf App`). Feeds `MaterialApp`'s title, `flavorizr.yaml`'s per-flavor `app.name`, and `.env.*`'s `APP_NAME`; the package name, imports, and every CI/bundle-id identifier are untouched.
- Added `moshaf_boilerplate flavor icons` — draws a "DEV"/"STAGING" ribbon across the app icon (same red as the in-app flavor banner) and writes matching `flutter_launcher_icons-<flavor>.yaml` files; also emits an unribboned `flutter_launcher_icons-prod.yaml`, since `flutter_launcher_icons` stops processing its base config entirely once any flavor-specific config file exists.
- `dev` and `staging` now share one `applicationId`/`bundleId` (`.staging`) instead of installing as separate apps — a device can only have one of the two installed at a time, matching how Jenkins CI's "STAGING" job already built the `dev` flavor under the hood.
- Feature Flags dialog (Developer Tools) restyled into a scrollable, per-module accordion with ON/OFF badges, plus a "copy expected response" button that copies the exact JSON (and endpoint) a working backend should return — both derive from a single `FeatureFlagState.toJson()`, so adding a module is now a one-place change instead of keeping two hand-written lists in sync. App Information dialog restyled to match.
- Fixed a bug where a throwing `.toDomain()` conversion (auth/profile repository impls) or a failing secure-storage write could leave the login `Bloc` stuck on its loading state forever with no error shown, since neither was guarded by a try/catch; both are now guarded and always resolve to either a success or a visible error.
- `.env.dev`/`.env.staging`/`.env.prod` now ship as real starter files (placeholder values, safe to commit) instead of not existing at all — matches what `flavor add` already generated for new flavors. Renamed on disk to `dot_env.*` so they survive `dart pub publish` (pub strips literal dotfiles from the package tarball).
- Fixed the developer-tools floating button defaulting to the same bottom-right corner as the in-app flavor banner ribbon, where the two visually overlapped; it now defaults bottom-left (still freely draggable) and hides itself entirely while any Developer Tools screen is on screen.
- The hidden developer-tools unlock flow (About page) is now reachable by tapping the logo on the Welcome/Login pages — no visible button, and no longer requires a successful login to reach.
- Added an internal Developer Tools layer (`core/developer_tools/`) — Android-Developer-Options-style, hidden from normal users: on automatically in `dev`, unlocked via a 7-tap gesture on the app version in `staging`/`prod` (optionally PIN-gated via `DEVELOPER_PIN`). A draggable floating button (persists position for the app session, stays within screen bounds) opens a menu with a masked API log viewer (Dio interceptor, self-gates on developer mode, caps at 100 entries, redacts `Authorization`/`password`/`token` before storage, tap-to-detail with copy-response, error snackbar with a direct link), a feature-flag inspector, a remote-config refresh action, and app info. Removed `chucker_flutter` (was an unused dependency — only its `navigatorObserver` was wired in) since this replaces what it would have been used for; this also fixed a pre-existing `deprecated_member_use` analyzer warning that came from it.
- Added a default `staging` flavor alongside `dev`/`prod` (`Flavor.staging`, `lib/main_staging.dart`, `flavorizr.yaml` block, VS Code task) — three flavors set up automatically at generation time, same as `dev`/`prod` were before.
- Added `moshaf_boilerplate flavor add <name>` command — scaffolds a new flavor in an already-generated project (`Flavor` enum entry, `lib/main_<name>.dart`, `flavorizr.yaml` block, starter `.env.<name>`, VS Code task); deliberately does not run `flutter_flavorizr` itself (that regenerates native config for every flavor at once and is worth reviewing first) — prints the exact next steps instead. Also fixed `pre_launch_task`'s env/plist file lookup, previously hardcoded to `dev`/`prod` only, to work for any flavor name by convention.
- Added an example remote feature-flag system (`core/feature_flags/`, `domain/entities/feature_flags/`) — global `ChangeNotifier` + `provider`, state grouped per module (`auth`, `profile`) so each module only reads its own flags; repository fails safe to all-off instead of surfacing errors. Wired into the login page's "Forgot Password" button as a working example. Added `provider` (runtime) and `mocktail` (dev, for the new unit/widget tests) as dependencies.
- **Breaking:** migrated navigation from `MaterialApp.routes` to [`go_router`](https://pub.dev/packages/go_router) — new `core/routes/app_router.dart` (singleton `GoRouter`, centralized `redirect` for the auth gate, reporting `errorBuilder`); `NavigationService` rewritten as a `@lazySingleton` wrapper around it instead of the old unused imperative API.
- Fixed 3 dead-end navigation bugs found during the migration: `Paths.register`/`'/forgot-password'` now resolve to real placeholder pages instead of an unknown-route error; dead `Paths.tnc`/`Paths.email_verification` constants removed.
- Added `moshaf_boilerplate assets` command — generates typed `Assets.images.xxx`/`Assets.svg.xxx`/... constants from the `assets/` folder, no `flutter_gen`/`build_runner` dependency; runs once automatically at generation time, also available as a VS Code task.
- Added a ready-to-adapt Jenkins CI pipeline (`Jenkinsfile` + `ci/`) — Android/iOS build, sign, and ship for `staging`/`production`, with optional TestFlight/Play Store/OTA distribution; every project-specific value centralized in `ci/config.groovy`.
- Expanded `core/constants/colors.dart` and `textstyle.dart` into a fuller design-token base (brand/status/neutral color scale, a `genStyle()` factory covering the full type scale) and bundled the Manrope font (previously referenced but never actually shipped).
- Backported 9 reusable UI components (`chip`, `dialog_popup`, `avatar_profile`, `search_input_custom_widget`, `bottomsheet_manager`, `separator_text`, `switch`, `title_section_widget`, `general_data_list`) from the source Flutter app this boilerplate is derived from.
- Split `flutter_launcher_icons`/`flutter_native_splash` config out of `pubspec.yaml` into their own `flutter_launcher_icons.yaml`/`flutter_native_splash.yaml` files, and added both packages as dev dependencies (previously configured but never actually installed).
- Fixed a `PathExistsException` crash during `create` caused by Flutter's Swift Package Manager integration not being idempotent across the generator's two separate `flutter pub add` batches.
- Fixed binary asset files (fonts, in particular) being corrupted by the template's text-substitution step; generalized the image-only exclusion list to a proper binary-file check.
- Corrected the root and per-project README: navigation section now describes `go_router` instead of the unused `MaterialApp.routes` claim, fixed a dead cross-reference link, updated minimum Flutter/Dart versions, refreshed the directory structure overview.

## 2.1.0
- Replaced static `build.gradle.kts` template with dynamic flavor injection via `_injectFlavorConfig()`, which inserts `flavorDimensions` and `productFlavors` after the generated `buildTypes` block at project creation time.
- Added `pre_launch_task` command to CLI help with full documentation: flavor options (`dev`/`prod`), env/plist copy behavior, build_runner execution strategy (fvm → dart → flutter), and VSCode tasks.json note.
- Updated example README: replaced `node set-env.js` with `moshaf_boilerplate pre_launch_task`, added FVM configuration section, removed `--target` flag from build commands.
- Added `cupertino.dart` import to `theme_data.dart`.

## 2.0.0
- Fixed bugs in iOS project configuration.
- Improved documentation and usage guides.
- Added support for Flutter 3.41.1 and latest versions.
- Enhanced source code for zone-guarded implementations.
- Improved error handling and logging mechanisms.
- Updated dependencies to latest stable versions.

## 1.0.3
- Added support for custom project templates.
- Improved CLI prompts for better user experience.
- Fixed issues with flavor-specific asset generation.
- Updated documentation for new features.
- Enhanced compatibility with latest Flutter versions.

## 1.0.2
- Improved documentation and added usage examples.
- Updated dependencies for better compatibility.
- Fixed minor bugs in flavor configuration.
- Enhanced error handling during project generation.
- Refactored code for maintainability and readability.

## 1.0.1
- Prioritize the use of FVM for Flutter version management.
- Tested and verified with Flutter 3.38.0, now set as the minimum supported version.
- Added Android and iOS source code to support flavor configurations.
- Fixed execution issues with dot files.
- Added comprehensive example project for documentation purposes.
- Various improvements and codebase refinements.

## 1.0.0
- Stable release of `moshaf_boilerplate` version 1.0.0.
- Includes all features from previous dev versions.
- Provides a robust generator for Flutter projects using Clean Architecture and BLoC.
- Ensures compatibility with Flutter 3.32.2 and above.
- Improved source directory resolution and updated dependencies.

## 1.0.0-dev.2
- Enhance boilerplate generator with source directory resolution and update dependencies

## 1.0.0-dev.1
- Initial dev release of `moshaf_boilerplate`.
- Provides a generator for Flutter folder structure based on Clean Architecture.
- Supports state management using BLoC.
- Ensures minimum Flutter version (3.32.2).
- Note: This is an initial dev version and may contain bugs or incomplete features.