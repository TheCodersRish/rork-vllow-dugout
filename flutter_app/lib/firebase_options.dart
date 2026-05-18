import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'config/firebase_config.dart';

class DefaultFirebaseOptions {
  static bool get isConfigured => FirebaseConfig.isReady;

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
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is only configured for Android and iOS.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: FirebaseConfig.androidApiKey,
        appId: FirebaseConfig.androidAppId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        authDomain: '${FirebaseConfig.projectId}.firebaseapp.com',
        storageBucket: FirebaseConfig.storageBucket,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: FirebaseConfig.androidApiKey,
        appId: FirebaseConfig.androidAppId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        storageBucket: FirebaseConfig.storageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: FirebaseConfig.iosApiKey,
        appId: FirebaseConfig.iosAppId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        storageBucket: FirebaseConfig.storageBucket,
        iosBundleId: FirebaseConfig.iosBundleId,
      );
}
