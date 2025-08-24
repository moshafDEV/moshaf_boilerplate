# ProjectName

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=120)

**ProjectName App** is a Flutter-based ...

### Developer Notes

Ensure that Node.js is installed on your system and execute the following commands:


**Prettier:**

Maintaining consistent code style by applying the standard Dart formatting rules, such as indentation, spacing, and line breaks, without the need for manual adjustments. The dot (.) signifies the current directory.

   ```bash
    dart format .
   ```

**Building APK:**

1. Set the environment variables for the desired flavor (dev or prod):

   ```bash
    node set-env.js [dev/prod] (root directory)
   ```

2. Build the APK for the selected flavor:
   
   ```bash
   flutter build apk --split-per-abi --flavor [dev/prod] --target=lib/main_[dev/prod].dart
   ```




**Building IPA (iOS):**

1. Set the environment variables for the desired flavor (dev or prod):

   ```bash
   node set-env.js [dev/prod] (root directory)
   ```

2. Install the necessary CocoaPods dependencies:

   ```bash
   pod install (in ios directory project)
   ```

3. Open the project in Xcode, select the appropriate scheme (dev or prod), and build the archive:

   ```bash
   open Xcode > Select scheme [dev/prod] > Product > Archive
   ```


## Authors

- [@moshaf](https://moshaf.com/)