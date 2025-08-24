# Flutter Boilerplate

![Logo](https://avatars.githubusercontent.com/u/153476629?v=4&size=120)

This repository provides a boilerplate source code to streamline the initial setup of new Flutter projects. Developed by moshafDEV, it ensures consistency, scalability, and adherence to best practices through Clean Architecture principles.

## Features

- Clean Architecture structure for maintainability and scalability
- Modular codebase for rapid development
- Pre-configured assets and essential directories
- Ready-to-use templates for common features

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

1. **Open CLI in Your Project Directory**  
   Navigate to the folder where you want to create your new Flutter project.

2. **Run the Boilerplate Creation Command**  
   Execute the following command:
   ```bash
   moshaf_boilerplate create
   ```
   This will scaffold your project with the recommended structure and templates.

> **Note:**  
> After generating your project, it is highly recommended to review and customize your `.gitignore` file to ensure that unnecessary files and directories are excluded from version control. This helps maintain a clean repository and prevents accidental commits of sensitive or build-related files.


## Directory Structure Overview

> **Note:** The following diagram illustrates the recommended folder structure, demonstrating clear separation of concerns in accordance with Clean Architecture.

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

## Recommended Versions

For best compatibility and performance, use the following versions:

- **Flutter:** 3.32.2  
  Check your version:
  ```bash
  flutter --version
  ```

- **Dart:**  
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
