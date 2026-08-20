# Google Sign-In Setup Requirements

**App ID:** `com.example.cosarc_shell`  
**Supabase Project:** `https://lgblxxixgldizfidscpz.supabase.co`  
**Sign-In Method:** Native Android via `google_sign_in` package → `signInWithIdToken` to Supabase

---

## Current Implementation Status

The Dart code in `auth_service.dart` is **complete and correct**:

```dart
// Correct flow — no code changes needed here:
// 1. google_sign_in gets idToken + accessToken from Google
// 2. supabase.auth.signInWithIdToken() exchanges them for a Supabase session
```

**ALL blockers are infrastructure/configuration — zero code changes required in Dart.**

---

## What Is Missing (in order of dependency)

### 1. `android/app/google-services.json` — MISSING

Without it, the Google Sign-In SDK cannot initialise and throws:
```
PlatformException(sign_in_failed, ApiException: 10)
// DEVELOPER_ERROR — SHA-1 mismatch or missing google-services.json
```

### 2. `com.google.gms.google-services` Gradle Plugin — NOT APPLIED

Neither `android/build.gradle` (root) nor `android/app/build.gradle` apply the plugin.
Without it, `google-services.json` is never processed by the build.

### 3. SHA-1 Fingerprint — NOT REGISTERED

Google Cloud Console requires the SHA-1 of the signing keystore to be whitelisted.
Both debug and release SHA-1s must be registered.

### 4. Supabase Google Provider — NOT ENABLED

The Supabase dashboard Google provider is not enabled with a Client ID and Client Secret.

---

## Step-by-Step Setup (Developer Actions)

### Step 1 — Create Firebase Project and download google-services.json

1. Go to https://console.firebase.google.com
2. Create a project (or select existing)
3. Add an Android app:
   - Android package name: `com.example.cosarc_shell`
   - App nickname: `cosarc`
4. On the SHA-1 step, add your debug SHA-1 (see Step 2) and paste it
5. Download `google-services.json`
6. Place it at `android/app/google-services.json`

### Step 2 — Get SHA-1 Fingerprints

**Debug keystore (development):**
```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```
Copy the `SHA1:` line and register it in Firebase Console -> Project Settings -> Your Android App -> SHA certificate fingerprints.

**Release keystore (production):**
```bash
# Generate release keystore (if not done yet)
keytool -genkey -v -keystore ~/cosarc-release.jks \
  -alias cosarc -keyalg RSA -keysize 2048 -validity 10000

# Get its SHA-1
keytool -list -v -keystore ~/cosarc-release.jks -alias cosarc
```
Register both SHA-1 fingerprints in Firebase.

### Step 3 — Apply the Google Services Gradle Plugin

**`android/build.gradle` (root)** — add inside `buildscript { dependencies { ... } }`:
```groovy
classpath 'com.google.gms:google-services:4.4.2'
```

**`android/app/build.gradle`** — add to `plugins {}` block:
```groovy
id "com.google.gms.google-services"
```

> Do NOT add the plugin until `google-services.json` is in place.

### Step 4 — Enable Google Provider in Supabase

1. Go to https://supabase.com/dashboard/project/lgblxxixgldizfidscpz/auth/providers
2. Enable **Google**
3. Client ID: Use the **Web application** OAuth client ID from Google Cloud Console
   (Firebase auto-creates this — find it under Project Settings or Cloud Console Credentials)
4. Client Secret: The corresponding secret
5. Save

### Step 5 — AndroidManifest.xml (No Changes Needed)

The app uses `google_sign_in` with `signInWithIdToken` — native Android flow that does NOT require a custom URI scheme or intent filter. No AndroidManifest changes needed.

### Step 6 — Verify

```bash
flutter run --debug
```
Tap "Continue with Google". You should see the account picker, then navigation to Onboarding or Dashboard.

If you still get `DEVELOPER_ERROR (code 10)`:
- Confirm SHA-1 in Firebase matches the running build's keystore exactly
- Confirm `applicationId` in `build.gradle` matches the Firebase Android app exactly
- Do a full rebuild (not hot reload) after placing `google-services.json`

---

## Summary Checklist

| Item | Status | Owner |
|---|---|---|
| Dart code in `auth_service.dart` | Done | Already correct |
| `android/app/google-services.json` | Missing | Developer (Firebase Console) |
| GMS plugin in `android/build.gradle` (root) | Missing | Developer |
| GMS plugin in `android/app/build.gradle` | Missing | Developer |
| Debug SHA-1 registered in Firebase | Missing | Developer |
| Release SHA-1 registered in Firebase | Missing | Developer |
| Supabase Google provider enabled | Missing | Developer |
| Web OAuth Client ID + Secret in Supabase | Missing | Developer |
| AndroidManifest changes | Not needed | N/A |
