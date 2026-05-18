# Firebase setup — hardcoded config (no FlutterFire CLI)

All Firebase keys live in one file:

`lib/config/firebase_config.dart`

You copy values from the Firebase website, paste them there, set `enabled = true`, add two config files to the project, then run the app.

---

## Part A — Firebase Console (do this first)

### Step 1: Create the project

1. Open https://console.firebase.google.com/
2. Click **Create a project** (or use an existing one).
3. Name it e.g. `vllow-dugout` → continue → disable/enable Google Analytics as you like → **Create project**.

### Step 2: Register the Android app

1. On the project home page, click the **Android** icon.
2. **Android package name:** paste exactly:
   ```
   com.vllow.vllow_dugout
   ```
3. App nickname: `Vllow Dugout Android` (optional).
4. Click **Register app**.
5. Click **Download google-services.json**.
6. Save that file to this path in your repo:
   ```
   flutter_app/android/app/google-services.json
   ```
7. Click **Next** until you finish the wizard (you can skip SDK steps for now).

### Step 3: Register the iOS app

1. Back on Project overview, click **Add app** → **iOS**.
2. **Apple bundle ID:** paste exactly:
   ```
   com.vllow.vllowDugout
   ```
3. Click **Register app**.
4. Click **Download GoogleService-Info.plist**.
5. Save it to:
   ```
   flutter_app/ios/Runner/GoogleService-Info.plist
   ```
   (In Xcode, drag it into the Runner target if it is not picked up automatically.)
6. Finish the wizard.

### Step 4: Turn on sign-in methods

1. Left sidebar → **Build** → **Authentication**.
2. Click **Get started** (first time only).
3. Open the **Sign-in method** tab.
4. Enable these three (click each row → Enable → Save):

| Provider | What to do |
|----------|------------|
| **Email/Password** | Enable → Save |
| **Google** | Enable → pick a support email → Save |
| **Apple** | Enable → Save (you will need Apple Developer setup before Apple works on a real device; email/password and Google can work first) |

### Step 5: Copy values into Dart (hardcoded)

1. Click the **gear** next to “Project overview” → **Project settings**.
2. Scroll to **Your apps**.

**Shared (same for every app in the project):**

| Firebase field | Paste into `firebase_config.dart` |
|----------------|----------------------------------|
| Project ID | `projectId` |
| Sender ID (Cloud Messaging) | `messagingSenderId` |
| Storage bucket (often `something.appspot.com`) | `storageBucket` |

**Android app row** (package `com.vllow.vllow_dugout`):

| Firebase field | Paste into `firebase_config.dart` |
|----------------|----------------------------------|
| API Key | `androidApiKey` |
| App ID (looks like `1:123456789:android:abc...`) | `androidAppId` |

**iOS app row** (bundle `com.vllow.vllowDugout`):

| Firebase field | Paste into `firebase_config.dart` |
|----------------|----------------------------------|
| API Key | `iosApiKey` |
| App ID (looks like `1:123456789:ios:abc...`) | `iosAppId` |

3. Open `lib/config/firebase_config.dart` and replace every `YOUR_...` string.
4. Set:
   ```dart
   static const bool enabled = true;
   ```

Example (fake values — use yours):

```dart
static const bool enabled = true;

static const String projectId = 'vllow-dugout';
static const String messagingSenderId = '123456789012';
static const String storageBucket = 'vllow-dugout.appspot.com';

static const String androidApiKey = 'AIzaSy...';
static const String androidAppId = '1:123456789012:android:abcdef';

static const String iosApiKey = 'AIzaSy...';
static const String iosAppId = '1:123456789012:ios:abcdef';
static const String iosBundleId = 'com.vllow.vllowDugout';
```

### Step 6: Google Sign-In on Android (required for “Continue with Google”)

1. Still in **Project settings** → your **Android** app.
2. Click **Add fingerprint**.
3. On your Mac, in Terminal:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Copy **SHA-1** and **SHA-256** into Firebase → Save.
5. Wait a few minutes, then test Google sign-in again.

### Step 7: Apple Sign-In on iOS (when you test on iPhone)

1. [Apple Developer](https://developer.apple.com/) → Identifiers → your App ID → enable **Sign in with Apple**.
2. Firebase Console → **Authentication** → **Sign-in method** → **Apple** → follow Firebase’s link to add Service ID / key if prompted.
3. Xcode → open `flutter_app/ios/Runner.xcworkspace` → Runner target → **Signing & Capabilities** → **+ Capability** → **Sign in with Apple**.

### Step 8: Google Sign-In on iOS (URL scheme)

1. Open `ios/Runner/GoogleService-Info.plist`.
2. Find the key `REVERSED_CLIENT_ID` (value looks like `com.googleusercontent.apps.123456-abc`).
3. Open `ios/Runner/Info.plist` and ensure you have:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>PASTE_REVERSED_CLIENT_ID_HERE</string>
    </array>
  </dict>
</array>
```

(If that block already exists from a template, only replace the string inside `CFBundleURLSchemes`.)

---

## Part B — Run the app

```bash
cd flutter_app
flutter pub get
flutter run
```

You should see **Continue with Google** and **Continue with Apple** on the auth screen.

Test:

1. **Sign up** with email + password → check **Authentication → Users** in Firebase; the user should appear.
2. **Sign out** from profile → sign in again.
3. Try **Google** on a device/emulator with Google Play Services (Android).

---

## Checklist

- [ ] `android/app/google-services.json` exists
- [ ] `ios/Runner/GoogleService-Info.plist` exists
- [ ] `lib/config/firebase_config.dart` has real values and `enabled = true`
- [ ] Email/Password, Google, Apple enabled in Firebase Authentication
- [ ] Android SHA-1 added (for Google)
- [ ] iOS Sign in with Apple capability (for Apple)

---

## If something fails

| Symptom | Fix |
|---------|-----|
| “Dev mode” / no Google button | `FirebaseConfig.enabled` is false or keys still say `YOUR_` |
| Google sign-in failed Android | Add SHA-1 fingerprint in Firebase |
| Apple sign-in failed iOS | Capability + Firebase Apple provider configured |
| Email already in use | Normal — use Sign in instead |

No `flutterfire configure` is required. Everything is hardcoded in `firebase_config.dart`.
