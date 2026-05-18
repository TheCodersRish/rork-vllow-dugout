# Firebase Authentication setup (Flutter)

Vllow Dugout Flutter uses **Firebase Authentication** for email/password, Google, and Apple sign-in. This matches the Notion PRD and dev task board.

The native **iOS (Swift) app** in this repo still uses **Stytch**. Plan to migrate iOS to Firebase later, or keep Stytch only on iOS if you need a single IdP across clients (see “Stytch alternative” below).

## 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Create a project (e.g. `vllow-dugout`).
3. Add two apps:
   - **Android** — package name: `com.vllow.vllow_dugout`
   - **iOS** — bundle ID: `com.vllow.vllowDugout`

## 2. Enable sign-in methods

In **Authentication → Sign-in method**, enable:

- Email/Password
- Google
- Apple (required for App Store if you offer other social logins)

## 3. Generate Flutter config

From `flutter_app/`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This overwrites `lib/firebase_options.dart` with real keys. Until then, the app runs in **mock auth** mode (local only).

## 4. Android

1. Download `google-services.json` from Firebase and place it at:
   `android/app/google-services.json`
2. Add SHA-1 and SHA-256 fingerprints in Firebase (Project settings → Your apps → Android):
   ```bash
   cd android && ./gradlew signingReport
   ```
3. Rebuild. The Google Services Gradle plugin applies automatically when `google-services.json` exists.

## 5. iOS

1. Download `GoogleService-Info.plist` into `ios/Runner/`.
2. In Xcode: open `ios/Runner.xcworkspace` → Runner target → **Signing & Capabilities** → add **Sign in with Apple**.
3. For Google Sign-In, add the reversed client ID from `GoogleService-Info.plist` to `ios/Runner/Info.plist` under `CFBundleURLTypes` (FlutterFire usually documents the exact value after configure).

## 6. Verify

```bash
flutter pub get
flutter run
```

On the auth screen you should see **Continue with Google** and **Continue with Apple** (not the “Dev mode” banner). Create a test user in Firebase Console or sign up in-app.

## Stytch alternative

If you want the same IdP as the Swift app (`ios/` uses Stytch password auth), use Stytch on Flutter instead of Firebase. That diverges from the Notion PRD but avoids two user directories. We recommend **Firebase for Flutter** unless you are standardizing on Stytch everywhere.

## Security checklist

- Never commit production service account keys.
- Use Firebase App Check before production.
- Scope `GameDataService` / SharedPreferences by `AuthUser.id` (follow-up task).
- Enforce email verification and 13+ registration when you add the full profile flow.
