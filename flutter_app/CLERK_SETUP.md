# Clerk authentication setup (Vllow Dugout Flutter)

This app uses [Clerk](https://clerk.com/) via the official `clerk_flutter` SDK. Keys are **hardcoded** in `lib/config/clerk_config.dart` (no `.env` required).

## What you need from Clerk

1. Create an application at [https://dashboard.clerk.com/](https://dashboard.clerk.com/)
2. Copy the **Publishable key** (`pk_test_...` or `pk_live_...`)
3. In **User & Authentication**, enable:
   - Email (password)
   - Google (OAuth and/or native token, depending on your flow)
   - Apple (for iOS)

## Configure the app

Edit `flutter_app/lib/config/clerk_config.dart`:

```dart
static const bool enabled = true;
static const String publishableKey = 'pk_test_YOUR_KEY_HERE';
static const String googleClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
```

- Set `enabled = true` only after `publishableKey` is real (not `REPLACE_ME`).
- `googleClientId` is the **Web** OAuth client ID from Google Cloud Console. Required for the Google ID-token sign-in path. If you leave the placeholder, the app falls back to Clerk’s OAuth browser flow (`ssoSignIn`).

## Run locally

Requirements (from Clerk):

- Flutter **≥ 3.27.4**
- Dart **≥ 3.6.2**

```bash
cd flutter_app
flutter pub get
flutter run
```

## Platform notes

### Android

`INTERNET` permission is already in `AndroidManifest.xml`.

For Google Sign-In, add your app’s **SHA-1** in Firebase/Google Cloud if you use native Google tokens.

### iOS

- Enable **Sign in with Apple** capability in Xcode.
- For OAuth redirects, follow [Clerk Flutter example](https://github.com/clerk/clerk-sdk-flutter/tree/main/packages/clerk_flutter/example) (`app_links` / URL scheme) if you use `ssoSignIn` instead of ID tokens.

## Demo mode (no Clerk keys)

With `enabled = false`, email sign-up/sign-in uses a **local mock session** (stored in SharedPreferences). Google and Apple buttons are hidden until Clerk is enabled.

## Password reset

Forgot password sends a **reset code** by email (Clerk `reset_password_email_code` strategy). The in-app sheet only starts that flow; completing reset with the code can be added later or you can use Clerk’s built-in `ClerkForgottenPasswordPanel` from the SDK.

## What we do **not** put in the app

- **Secret key** (`sk_...`) — server-only; never ship in Flutter.
