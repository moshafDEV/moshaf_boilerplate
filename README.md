# Flutter Boilerplate

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=460)

This repository contains a source code boilerplate designed to facilitate the initial setup of new Flutter projects. It serves as the standard coding template for projects developed by moshafDEV, ensuring consistency and adherence to best practices.

The structure of this boilerplate follows the principles of Clean Architecture, providing a scalable and maintainable foundation for both small and large applications. By using this boilerplate, developers can quickly begin working on the core business logic of their projects while maintaining an organized and modular codebase.


## Clean Architecture Directory Overview
> **Note:** The following diagram is an illustration of the directory folder structure for this project. It is intended to demonstrate how each layer interacts while maintaining clear boundaries in accordance with Clean Architecture principles.
   ```
      ├── assets
      │   ├── animations
      │   ├── fonts
      │   ├── icons
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
      │   │   ├── constants
      │   │   ├── env
      │   │   ├── error
      │   │   ├── http_client
      │   │   │   ├── interceptors
      │   │   ├── routes
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
      │   │   │   ├── login_param
      │   │   │   ├── profile
      │   │   │   └── text_input_field
      │   │   ├── repositories
      │   │   └── usecase
      │   │       └── login
      │   └── presentation
      │       ├── bloc
      │       │   └── login
      │       ├── component
      │       └── pages
      │           ├── home
      │           │   ├── components
      │           ├── login
      │           │   ├── components
      │           ├── splash_screen
      │           │   ├── components
      │           └── welcome
      │               ├── components
   ```


### Recommended Versions:

For optimal compatibility and performance, we recommend using the following versions of Flutter:

**Flutter**

Recommended Version: **Flutter 3.32.2**

To check your current Flutter version, run the following command in your terminal:

   ```bash
    flutter --version
   ```
   **Dart**

   To check your current Dart version, run:

   ```bash
   dart --version
   ```

   ### Install Dart

   Follow the official installation guide at [https://dart.dev/get-dart](https://dart.dev/get-dart).

   After installation, ensure the Dart SDK path is added to your system's environment variables. For example, on macOS or Linux, add the following to your `.bashrc`, `.zshrc`, or `.profile`:

   ```bash
   export PATH="$PATH:/usr/local/bin/dart"
   ```

   On Windows, add the Dart SDK path (e.g., `C:\tools\dart-sdk\bin`) to your system's PATH variable.

   Once installed, verify Dart is accessible from your CLI `dart --version`.

## Authors

- [@moshaf](https://github.com/moshafDEV)