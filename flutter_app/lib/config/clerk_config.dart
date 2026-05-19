/// Hardcoded Clerk keys — paste from https://dashboard.clerk.com/
///
/// After creating an application:
/// 1. Copy **Publishable key** (starts with `pk_test_` or `pk_live_`) → [publishableKey]
/// 2. Optional, for Google sign-in: GCP **Web client ID** → [googleClientId]
///
/// Set [enabled] to true once [publishableKey] is real (no REPLACE_ME).

class ClerkConfig {
  ClerkConfig._();

  static const bool enabled = false;

  /// Clerk Dashboard → API Keys → Publishable key
  static const String publishableKey = 'pk_test_REPLACE_ME';

  /// Google Cloud Console → OAuth 2.0 Web client ID (only if using Google sign-in)
  static const String googleClientId = 'REPLACE_GOOGLE_WEB_CLIENT_ID';

  static bool get isReady =>
      enabled &&
      publishableKey.startsWith('pk_') &&
      !publishableKey.contains('REPLACE');
}
