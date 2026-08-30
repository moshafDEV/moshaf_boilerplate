# Example App

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=120)

**Example App** is a Flutter app generated from the [`moshaf_boilerplate`](https://pub.dev/packages/moshaf_boilerplate) template — Clean Architecture, BLoC state management, `go_router` navigation, and dev/staging/prod flavors set up out of the box.

### Developer Notes

**FVM Configuration:**

If you're using Flutter Version Manager (fvm), ensure you have set the correct Flutter version for this project. Run the following command in the project root:

```bash
fvm use $version
```

**Prettier:**

Maintaining consistent code style by applying the standard Dart formatting rules, such as indentation, spacing, and line breaks, without the need for manual adjustments. The dot (.) signifies the current directory.

   ```bash
    dart format .
   ```

### ⚠️ Ensure These Steps Are Completed

After completing all the configurations above, you are ready to run the application on an emulator or physical device.

[Go to Flavor Setup](https://pub.dev/packages/moshaf_boilerplate#flavors-android--ios)

**Android SDK requirement:** `android/app/build.gradle.kts` sets `compileSdk = maxOf(flutter.compileSdkVersion, 37)` — a floor required by `flutter_secure_storage`, independent of which Flutter version you use. Building against it needs Android SDK Platform 37 installed (Android Studio's SDK Manager auto-downloads it on first sync, or run `sdkmanager "platforms;android-37"`).

**Building APK:**

1. Set the environment variables for the desired flavor (dev, staging, or prod):

   ```bash
    moshaf_boilerplate pre_launch_task [dev/staging/prod]  (root directory)
   ```

2. Build the APK for the selected flavor:
   
   ```bash
   flutter build apk --split-per-abi --flavor [dev/staging/prod] --target=lib/main_[dev/staging/prod].dart
   ```

**Building IPA (iOS):**

1. Set the environment variables for the desired flavor (dev, staging, or prod):

   ```bash
   moshaf_boilerplate pre_launch_task [dev/staging/prod]  (root directory)
   ```

2. Install the necessary CocoaPods dependencies:

   ```bash
   pod install (in ios directory project)
   ```

3. Open the project in Xcode, select the appropriate scheme (dev, staging, or prod), and build the archive:

   ```bash
   open Xcode > Select scheme [dev/staging/prod] > Product > Archive
   ```


### Type-Safe Assets

`Assets.images.xxx`/`Assets.svg.xxx`/`Assets.fonts.xxx` constants in `lib/core/constants/assets.gen.dart` are generated from whatever's under `assets/`. Added or removed a file there? Regenerate with:

```bash
moshaf_boilerplate assets
```

(also available as the "Regenerate Assets" VS Code task).

### App Icon & Splash Screen

`flutter_launcher_icons.yaml` and `flutter_native_splash.yaml` at the project root point at placeholder images — replace them with your own app icon/splash, then run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Feature Flags

A remote-config-backed feature flag system (`lib/core/feature_flags/`, `lib/domain/entities/feature_flags/`) — fetched once at startup from `GET <API_URL>/v1/config/feature-flags`, grouped per module (`auth`, `profile` out of the box) so each module only ever reads its own flags. Any failure falls back to every flag off, silently. See `password_input_field.dart`'s "Forgot Password" button for a working example of gating UI on a flag.

To add a new flag: create a `<Module>FeatureFlags` entity under `domain/entities/feature_flags/` (give it a `toJson()` mirroring its `fromJson()`), add a field for it on `FeatureFlagState` (and to its own `toJson()`) — the Developer Tools Feature Flags screen picks it up automatically, nothing else to touch.

### Developer Tools

An Android-Developer-Options-style debug layer, invisible to normal users. Tap the logo on the Welcome or Login page (no visible button — that's deliberate) to open the About page, no login required:

- **dev**: developer mode is already on — the tap just gets you to About.
- **staging**: tap the app version 7 times to unlock.
- **prod**: same 7-tap gesture, then a PIN dialog (`DEVELOPER_PIN` in `.env` — unset means no PIN is enforced).

Once unlocked, a draggable floating button appears on every page except the developer-tools screens themselves. Tapping it opens a menu: a masked API log viewer (up to 100 requests, `Authorization`/`password`/`token` redacted before storage), a Feature Flags inspector with a "copy expected response" button, a remote-config refresh action, a cache-clear action, and app info.

### Continuous Integration (Jenkins)

A ready-to-adapt Jenkins pipeline ships in `Jenkinsfile` + `ci/` — builds/signs/ships Android and iOS for `staging` and `production` branches, with optional TestFlight/Play Store/OTA distribution. Every project-specific value (credential IDs, agent labels, bundle IDs) lives in one file: `ci/config.groovy` — that's the only thing to edit, `Jenkinsfile` and `ci/scripts/*.sh` stay untouched. Start with `ci/docs/CREDENTIALS_GUIDE.md`, then `ci/docs/RUN-PIPELINE.md` to test locally before wiring it into Jenkins. Not using Jenkins, or don't need CI right now? Delete `Jenkinsfile` and `ci/` — nothing else in the project depends on them.

### Store Launch Checklist

`docs/release/store-launch-checklist.html` is a single offline HTML file (no build step, no server) with a fixed 60-point App Store/Google Play release checklist plus a copyable privacy policy template. Its Audit and Reference tabs start empty; the prompt in `docs/release/README.md` has Claude Code inspect this repository and fill them in. Toggle English/Indonesian from the top bar. Don't need it? Delete `docs/release/`.

## Authors

- [@moshaf](https://github.com/moshafDEV)