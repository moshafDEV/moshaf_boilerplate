# Flutter Boilerplate

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=120)

This repository provides a boilerplate source code to streamline the initial setup of new Flutter projects. Developed by moshafDEV, it ensures consistency, scalability, and adherence to best practices through Clean Architecture principles.

## Features

- Clean Architecture structure for maintainability and scalability
- Modular codebase for rapid development
- Pre-configured assets and essential directories
- Ready-to-use templates for common features
- Integrated support for multiple environments using [`flutter_flavor`](https://pub.dev/packages/flutter_flavor)
- State management with [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
- Dependency injection via [`get_it`](https://pub.dev/packages/get_it) + [`injectable`](https://pub.dev/packages/injectable)
- Networking powered by [`dio`](https://pub.dev/packages/dio)
- Local storage setup with [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)
- Declarative navigation via [`go_router`](https://pub.dev/packages/go_router) — a single `redirect` gates the auth flow (splash/welcome/login/home), with a reporting `errorBuilder` for unmatched routes
- Type-safe asset access — `moshaf_boilerplate assets` scans `assets/` and generates `Assets.images.xxx`/`Assets.svg.xxx` constants, no `flutter_gen` dependency needed
- Linting and code quality enforced with [`flutter_lints`](https://pub.dev/packages/flutter_lints)
- Unit and widget testing configuration
- Customizable theme and localization support
- Error handling and logging modules, wired into both crash reporting and routing
- Analytics integration for screen tracking
- Example implementation for authentication (login/profile)
- Separation of data, domain, and presentation layers
- Configurable environment variables and DI modules
- Ready-to-adapt Jenkins CI pipeline (`Jenkinsfile` + `ci/`) for Android + iOS staging/production builds

## Installation Guide

Follow these steps to install `moshaf_boilerplate` globally using Dart Pub:

1. **Install Dart SDK**  
   Ensure Dart SDK is installed on your system.  
   Refer to the official guide: [dart.dev/get-dart](https://dart.dev/get-dart).

2. **Open Terminal or Command Prompt**  
   Use your preferred terminal (Linux/Mac) or Command Prompt (Windows).

3. **Run Installation Command**  
   Execute the following command to install `moshaf_boilerplate` globally:
   ```bash
   dart pub global activate moshaf_boilerplate
   ```

4. **Verify Installation**  
   Confirm the installation by running:
   ```bash
   moshaf_boilerplate --help
   ```
   If help information is displayed, the installation was successful.

5. **Add Dart Pub Global Path (if required)**  
   If the command is not recognized, add Dart's global pub path to your environment variables:
   - **Linux/Mac:** `$HOME/.pub-cache/bin`
   - **Windows:** `%USERPROFILE%\.pub-cache\bin`

   Example for Linux/Mac:
   ```bash
   export PATH="$PATH:$HOME/.pub-cache/bin"
   ```

## Usage Guide

Once installation is complete, follow these steps to initialize your Flutter project using `moshaf_boilerplate`:

1. **Open CLI in Your Workspace Directory**  
   Navigate to the folder where you keep your projects (e.g. `~/dev`) — not a folder named after the project itself.

2. **Run the Boilerplate Creation Command**  
   Execute the following command:
   ```bash
   moshaf_boilerplate create
   ```
   You'll be prompted for a project name, then a new folder with that name is created right there with the full Clean Architecture structure and templates inside it — nothing outside that new folder is touched.

> **Note:**  
> After generating your project, it is highly recommended to review and customize your `.gitignore` file to ensure that unnecessary files and directories are excluded from version control. This helps maintain a clean repository and prevents accidental commits of sensitive or build-related files.

## Running on macOS

macOS builds need one manual, per-machine step that no CLI generator can do
for you: `flutter_secure_storage` uses Keychain, which under App Sandbox
requires a real signing identity. After generating your project:

1. Open `macos/Runner.xcworkspace` in Xcode.
2. Select **Runner** → **Signing & Capabilities**.
3. Pick your Team (a personal Apple ID works for local development).

Without this, `flutter run -d macos` fails to build with `"Runner" has
entitlements that require signing with a development certificate.` Android
and iOS don't need this step.

## Flavors (Android & iOS)

`dev` and `prod` flavors — application id/bundle id, display name, app icon,
launch screen — are set up automatically at generation time by
[`flutter_flavorizr`](https://pub.dev/packages/flutter_flavorizr), driven by
`flavorizr.yaml` at the project root. No manual Xcode configuration-duplication
or Gradle editing is required; `flutter run --flavor dev -t lib/main_dev.dart`
(or `prod`) works right after generation.

### Changing a flavor, or adding a new one

Edit `flavorizr.yaml`, then re-run:
```bash
dart run flutter_flavorizr -f
```
This only touches native Android/iOS flavor config (application id, bundle
id, app name, icons, launch screen) — it never touches `lib/`, so your own
Dart code (including `main_dev.dart`/`main_prod.dart` and this boilerplate's
`flutter_flavor`-based `FlavorConfig`) is untouched.

### Adding your Firebase config per flavor

Firebase config files are secrets and can't be templated, so add them
yourself, then point `flavorizr.yaml` at them:

- **Android**: place `google-services.json` in `android/app/src/dev/` (and
  `.../prod/`), then uncomment the matching `firebase.config` line under that
  flavor in `flavorizr.yaml`.
- **iOS**: place `GoogleService-Info.plist` wherever you like in the repo
  (e.g. `ios/config/dev/GoogleService-Info.plist`), then uncomment and point
  the matching `firebase.config` line to it.

Re-run `dart run flutter_flavorizr -f` afterwards to wire them in.

## App Icon & Splash Screen

Config for [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) and
[`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) ships as
`flutter_launcher_icons.yaml`/`flutter_native_splash.yaml` at the project root (both
auto-detected by their default filename, no extra flag needed). They point at placeholder
image paths — drop in your own icon/splash images at those paths, then run:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
Neither runs automatically at generation time, since there's no real app icon to generate
from yet.

## Type-Safe Assets

`moshaf_boilerplate assets` scans `assets/` and (re)writes
`lib/core/constants/assets.gen.dart` — one generated class per top-level folder
(`Assets.images.imgLanding`, `Assets.svg.iconSearch`, ...), plain `String` constants, no
`flutter_gen`/`build_runner` dependency. Runs once automatically at generation time; re-run
it yourself any time you add or remove files under `assets/` (also available as a VS Code
task, "Regenerate Assets").

## Continuous Integration (Jenkins)

A ready-to-adapt Jenkins pipeline ships as `Jenkinsfile` + `ci/` — builds, signs, and ships
Android and iOS for `staging`/`production` branches, with optional TestFlight/Play
Store/OTA distribution. Every project-specific value (credential IDs, agent labels, bundle
IDs) lives in one file, `ci/config.groovy`; `Jenkinsfile` and `ci/scripts/*.sh` stay
untouched. Start with `ci/docs/CREDENTIALS_GUIDE.md`, then `ci/docs/RUN-PIPELINE.md` to test
locally before wiring it into Jenkins. Not using Jenkins? Delete `Jenkinsfile` and `ci/` —
nothing else in the project depends on them.

---

## Directory Structure Overview

> **Note:** The following diagram illustrates the recommended folder structure, demonstrating clear separation of concerns in accordance with Clean Architecture.

```
├── ci                            # Jenkins pipeline scripts/docs (optional, deletable)
├── Jenkinsfile
├── flavorizr.yaml
├── flutter_launcher_icons.yaml
├── flutter_native_splash.yaml
├── assets
│   ├── fonts
│   ├── images
│   ├── svg
│   └── translations
├── build.yaml
├── config.json
├── lib
│   ├── app.dart
│   ├── core
│   │   ├── analytics
│   │   │   └── screen_analytics
│   │   ├── config
│   │   │   ├── di_module
│   │   │   └── loggers
│   │   ├── constants                # colors.dart, textstyle.dart, generated assets.gen.dart
│   │   ├── env
│   │   ├── error
│   │   ├── http_client
│   │   │   ├── interceptors
│   │   ├── routes                   # app_router.dart (GoRouter), app_routes.dart, app_path.dart
│   │   ├── services
│   │   └── utils
│   ├── data
│   │   ├── datasources
│   │   │   ├── local
│   │   │   └── remote
│   │   ├── models
│   │   │   ├── login
│   │   │   │   ├── request
│   │   │   │   └── response
│   │   │   └── profile
│   │   │       └── response
│   │   └── repository_impls
│   ├── domain
│   │   ├── entities
│   │   │   ├── auth
│   │   │   ├── general_data_list
│   │   │   ├── login_param
│   │   │   ├── profile
│   │   │   └── text_input_field
│   │   ├── repositories
│   │   └── usecase
│   │       └── login
│   └── presentation
│       ├── bloc
│       │   └── login
│       ├── components                # shared widgets: chip, dialog, avatar, switch, ...
│       └── pages
│           ├── forgot_password
│           ├── home
│           │   ├── components
│           ├── login
│           │   ├── components
│           ├── register
│           ├── splash_screen
│           │   ├── components
│           └── welcome
│               ├── components
```

## Recommended Versions

For best compatibility and performance, use the following versions:

- **Flutter: >= 3.38.0**
  Check your version:
  ```bash
  flutter --version
  ```

- **Dart: >= 3.9.0**
  Check your version:
  ```bash
  dart --version
  ```

Refer to the official Dart installation guide: [https://dart.dev/get-dart](https://dart.dev/get-dart).

After installation, ensure the Dart SDK path is added to your system's environment variables.  
Example for macOS/Linux:
```bash
export PATH="$PATH:/usr/local/bin/dart"
```
On Windows, add the Dart SDK path (e.g., `C:\tools\dart-sdk\bin`) to your system's PATH variable.

## References

- [Dart Pub Documentation](https://dart.dev/tools/pub/cmd/pub-global)
- [moshaf_boilerplate Package](https://pub.dev/packages/moshaf_boilerplate)

## Authors

- [@moshaf](https://github.com/moshafDEV)
