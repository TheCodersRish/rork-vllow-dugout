# Kinde authentication setup (Vllow Dugout Flutter)

This app uses [Kinde](https://kinde.com/) via `kinde_flutter_sdk`. Values are **hardcoded** in `lib/config/kinde_config.dart` (no `.env` required).

## What you need from Kinde

1. Create a business at [https://app.kinde.com/](https://app.kinde.com/)
2. **Settings → Applications → [Your app] → View details**
   - **Domain** (e.g. `https://yourapp.kinde.com`) → `authDomain`
   - **Client ID** → `authClientId`
3. **Allowed callback URLs** (must match exactly, no trailing slash):
   - `com.vllow.vllow_dugout://kinde_callback`
4. **Allowed logout redirect URLs**:
   - `com.vllow.vllow_dugout://kinde_logoutcallback`
5. **User authentication**: enable Email, Google, Apple, etc. on the hosted Kinde sign-in page (the Flutter SDK opens that page; there are no in-app email/password fields when Kinde is enabled).
6. **(Optional) API audience**: Settings → Applications → APIs → copy audience → `audience` in config

## Configure the app

Edit `flutter_app/lib/config/kinde_config.dart`:

```dart
static const bool enabled = true;
static const String authDomain = 'https://yourapp.kinde.com';
static const String authClientId = 'your_client_id';
// loginRedirectUri / logoutRedirectUri already use com.vllow.vllow_dugout — change only if you change the app ID
```

## Copy-paste template for your agent / teammate

```text
Kinde auth domain: https://_____.kinde.com
Kinde client ID: _______________
Enable Kinde: yes
Custom redirect scheme (default): com.vllow.vllow_dugout
Kinde audience (optional):
Auth methods enabled in dashboard: email / Google / Apple
```

## Platform setup (already wired in repo)

### Android

- `android/app/build.gradle.kts`: `manifestPlaceholders` for `appAuthRedirectScheme`
- `AndroidManifest.xml`: `taskAffinity` set for OAuth redirect (minSdk &lt; 30)

### iOS

- `ios/Runner/Info.plist`: `CFBundleURLSchemes` → `com.vllow.vllow_dugout`

## Demo mode (no Kinde keys)

With `enabled = false`, email sign-up/sign-in uses a **local mock session** (SharedPreferences). Tapping Sign In / Create Account uses the in-app form.

## Sign-in flow with Kinde enabled

Sign In / Create Account opens Kinde’s hosted UI (browser). Google and Apple are configured in the Kinde dashboard, not as separate native buttons in the app.

Password reset is handled on Kinde’s hosted sign-in page (Forgot password link there).

## What we do **not** put in the app

- **Client secret** — backend only; never ship in Flutter

## SDK version note

The project uses `kinde_flutter_sdk: ^1.1.1` for compatibility with Dart 3.6+. To use SDK 2.x, upgrade Flutter/Dart per [pub.dev](https://pub.dev/packages/kinde_flutter_sdk).
