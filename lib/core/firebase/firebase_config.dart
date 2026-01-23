/// Firebase configuration for Admin Dashboard.
///
/// This file contains the Firebase options for connecting to the
/// Deliverzler Firebase project (studio-2837415731-5df0e).
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with the Admin Dashboard app.
///
/// Uses the same Firebase project as Deliverzler app for data integration.
class DefaultFirebaseOptions {
  /// Private constructor to prevent instantiation.
  const DefaultFirebaseOptions._();

  /// Returns the appropriate [FirebaseOptions] for the current platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for Web platform.
  ///
  /// Connected to Deliverzler Firebase project: studio-2837415731-5df0e
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJl538WLhVGpdSbi5XcPIpdjRWX5N1SrM',
    appId: '1:896018485696:web:1b1a6225df119d2a087825',
    messagingSenderId: '896018485696',
    projectId: 'studio-2837415731-5df0e',
    authDomain: 'studio-2837415731-5df0e.firebaseapp.com',
    storageBucket: 'studio-2837415731-5df0e.firebasestorage.app',
  );

  /// Firebase options for Android platform.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpl3x3hv2qFjDe0-IOievLH-G1uPbA-Ys',
    appId: '1:896018485696:android:9d4bd734845afa8d087825',
    messagingSenderId: '896018485696',
    projectId: 'studio-2837415731-5df0e',
    storageBucket: 'studio-2837415731-5df0e.firebasestorage.app',
  );

  /// Firebase options for iOS platform.
  ///
  /// Note: iOS configuration needs to be set up via FlutterFire CLI
  /// when deploying to iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '896018485696',
    projectId: 'studio-2837415731-5df0e',
    storageBucket: 'studio-2837415731-5df0e.firebasestorage.app',
    iosBundleId: 'com.example.adminDashboard',
  );
}
