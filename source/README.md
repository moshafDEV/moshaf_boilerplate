# ProjectName

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=120)

**ProjectName** is a Flutter app generated from the [`moshaf_boilerplate`](https://pub.dev/packages/moshaf_boilerplate) template — Clean Architecture, BLoC state management, `go_router` navigation, and dev/prod flavors set up out of the box.

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

**Building APK:**

1. Set the environment variables for the desired flavor (dev or prod):

   ```bash
    moshaf_boilerplate pre_launch_task [dev/prod]  (root directory)
   ```

2. Build the APK for the selected flavor:
   
   ```bash
   flutter build apk --split-per-abi --flavor [dev/prod] --target=lib/main_[dev/prod].dart
   ```

**Building IPA (iOS):**

1. Set the environment variables for the desired flavor (dev or prod):

   ```bash
   moshaf_boilerplate pre_launch_task [dev/prod]  (root directory)
   ```

2. Install the necessary CocoaPods dependencies:

   ```bash
   pod install (in ios directory project)
   ```

3. Open the project in Xcode, select the appropriate scheme (dev or prod), and build the archive:

   ```bash
   open Xcode > Select scheme [dev/prod] > Product > Archive
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

### Continuous Integration (Jenkins)

A ready-to-adapt Jenkins pipeline ships in `Jenkinsfile` + `ci/` — builds/signs/ships Android and iOS for `staging` and `production` branches, with optional TestFlight/Play Store/OTA distribution. Every project-specific value (credential IDs, agent labels, bundle IDs) lives in one file: `ci/config.groovy` — that's the only thing to edit, `Jenkinsfile` and `ci/scripts/*.sh` stay untouched. Start with `ci/docs/CREDENTIALS_GUIDE.md`, then `ci/docs/RUN-PIPELINE.md` to test locally before wiring it into Jenkins. Not using Jenkins, or don't need CI right now? Delete `Jenkinsfile` and `ci/` — nothing else in the project depends on them.

## Authors

- [@moshaf](https://github.com/moshafDEV)