/// Hardcoded Kinde settings — paste from https://app.kinde.com/
///
/// Settings → Applications → [Your app] → View details
/// Set [enabled] to true once values are real (no REPLACE_ME).

class KindeConfig {
  KindeConfig._();

  static const bool enabled = false;

  /// e.g. https://yourbusiness.kinde.com or yourbusiness.kinde.com
  static const String authDomain = 'https://REPLACE_ME.kinde.com';

  /// Application Client ID
  static const String authClientId = 'REPLACE_CLIENT_ID';

  /// Must match Allowed callback URLs in Kinde (and Android/iOS URL scheme).
  static const String loginRedirectUri =
      'com.vllow.vllow_dugout://kinde_callback';

  /// Must match Allowed logout redirect URLs in Kinde.
  static const String logoutRedirectUri =
      'com.vllow.vllow_dugout://kinde_logoutcallback';

  /// Custom URL scheme (first segment of redirect URIs above).
  static const String urlScheme = 'com.vllow.vllow_dugout';

  /// Optional: Settings → Applications → APIs → Audience
  static const String audience = '';

  static bool get isReady =>
      enabled &&
      !authClientId.contains('REPLACE') &&
      !authDomain.contains('REPLACE_ME');
}
