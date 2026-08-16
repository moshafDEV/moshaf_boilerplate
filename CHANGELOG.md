# Changelog

## 3.0.0
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