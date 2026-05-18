/// Hardcoded Firebase values — paste from Firebase Console (see AUTH_SETUP.md).
///
/// Where to copy each value:
/// - [projectId], [messagingSenderId], [storageBucket]
///   → Project settings (gear) → General → Your apps → any app
/// - Android [androidApiKey], [androidAppId]
///   → Project settings → Your apps → Android app
/// - iOS [iosApiKey], [iosAppId]
///   → Project settings → Your apps → iOS app
///
/// Set [enabled] to true only after every value below is replaced (no YOUR_ left).

class FirebaseConfig {
  FirebaseConfig._();

  /// Flip to true after you paste real values from Firebase Console.
  static const bool enabled = false;

  static const String projectId = 'YOUR_PROJECT_ID';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String storageBucket = 'YOUR_PROJECT_ID.appspot.com';

  // --- Android (app: com.vllow.vllow_dugout) ---
  static const String androidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String androidAppId = 'YOUR_ANDROID_APP_ID';

  // --- iOS (app: com.vllow.vllowDugout) ---
  static const String iosApiKey = 'YOUR_IOS_API_KEY';
  static const String iosAppId = 'YOUR_IOS_APP_ID';
  static const String iosBundleId = 'com.vllow.vllowDugout';

  static bool get isReady =>
      enabled &&
      !projectId.startsWith('YOUR_') &&
      !androidApiKey.startsWith('YOUR_') &&
      !iosApiKey.startsWith('YOUR_');
}
