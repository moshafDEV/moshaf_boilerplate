import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// True where `firebase_analytics`/`firebase_messaging` actually ship a
/// native implementation. `firebase_core` itself also supports Windows, but
/// analytics/messaging don't — and AppConfig.initialize() calls both right
/// after Firebase.initializeApp(), so Windows still isn't safe overall.
/// Neither package supports Linux. See DEV_NOTES.md for the platform table.
bool get isFirebaseSupported =>
    kIsWeb || (!Platform.isWindows && !Platform.isLinux);

/// True where `firebase_crashlytics` ships a native implementation:
/// Android/iOS/macOS only — narrower than [isFirebaseSupported] (no web,
/// no Windows, no Linux).
bool get isFirebaseCrashlyticsSupported =>
    !kIsWeb && !Platform.isWindows && !Platform.isLinux;
