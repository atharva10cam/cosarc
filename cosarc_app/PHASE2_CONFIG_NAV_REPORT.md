# COSARC Phase 2 Config & Navigation Fixes — Delivery Report

**Branch:** `antigravity-premium`  
**Date:** 2026-06-18  
**Agent:** Config-Navigation-Fixer (subagent, Phase 2)

---

## Summary of Changes

| File | Lines Before | Lines After | Δ |
|------|-------------|-------------|---|
| `lib/core/config/app_config.dart` | 66 | 72 | +6 (security comment, key placement fix) |
| `lib/main.dart` | 114 | 126 | +12 (splash guard flag + method) |
| `lib/screens/app_start/app_start_screen.dart` | 222 | 227 | +5 (import + markSplashDone call) |
| `android/app/build.gradle` | 94 | 111 | +17 (key.properties block + release signing fix) |

---

## FIX 1 — lib/core/config/app_config.dart (Critical Config Bug)

### Root Cause
`String.fromEnvironment(name, defaultValue: fallback)` uses the first argument as the
environment variable name to look up at compile time. The original code had the JWT
placed as the FIRST argument (the lookup name):

```dart
// BROKEN
static const String supabaseAnonKey = String.fromEnvironment(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',  // ← env var name, never matches
  defaultValue: '',                              // ← always ''
);
```

This meant supabaseAnonKey was ALWAYS '', so AppConfig.configurationError was always
non-null, causing _ConfigurationErrorScreen to show on every launch.

### Fix Applied
- supabaseAnonKey: env var name -> 'SUPABASE_ANON_KEY', JWT moved to defaultValue
- usdaApiKey: env var name -> 'USDA_API_KEY', actual key moved to defaultValue
- All other keys (NUTRITIONIX_*, EDAMAM_*, SPOONACULAR_*) were already correct — unchanged
- Added security warning comment at top of file (keys embedded in binary)

WARNING: supabaseAnonKey and usdaApiKey are now embedded in the compiled binary as
defaultValue. If this repo is or becomes public, rotate both keys immediately and supply
them exclusively via --dart-define in CI/CD before shipping to production.

---

## FIX 2 — Navigation Race Condition (main.dart + app_start_screen.dart)

### Root Cause
Two independent code paths could fire navigation simultaneously:
1. AppStartScreen._goNext() — fired by Future.delayed after the splash video/timer
2. _CosarcAppState._setupAuthListener() — subscribed to supabase.auth.onAuthStateChange

If Supabase fires an auth event DURING the splash (e.g., a restored session), both paths
could call pushReplacement / pushAndRemoveUntil within milliseconds of each other. The
existing _navigated guard in AppStartScreen only prevented double-calls to _goNext()
itself — it did nothing to stop the auth listener from independently navigating.

### Fix Applied

main.dart — added to _CosarcAppState:
```dart
static bool _splashDone = false;
static void markSplashDone() => _splashDone = true;
```

main.dart — first line inside the auth stream listener:
```dart
if (!_splashDone) return;  // skip navigation while splash is still visible
```

app_start_screen.dart — added import and call at start of _goNext():
```dart
import '../../main.dart' show CosarcApp;

CosarcApp.markSplashDone();  // called before any navigation branch
```

### Why this approach
- Minimum change (12 lines in main.dart, 5 lines in app_start_screen.dart)
- No NavigatorObserver or route introspection needed
- Flag flips before pushReplacement, so auth listener is unblocked at exactly the right
  moment regardless of which navigation branch _goNext() takes
- Auth events after splash work normally — once _splashDone = true, the listener
  behaves exactly as before, handling session restore and OAuth callbacks correctly

---

## FIX 3 — android/app/build.gradle Release Signing

### Root Cause
The release signingConfig was hardcoded to the debug keystore. A Play Store upload
signed with the debug key would be rejected.

### Fix Applied

Added key.properties loading block (after localProperties block):
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Updated release signingConfig with safe Groovy Elvis-operator fallback:
```gradle
release {
    keyAlias keystoreProperties['keyAlias'] ?: 'androiddebugkey'
    keyPassword keystoreProperties['keyPassword'] ?: 'android'
    storeFile keystoreProperties['storeFile']
        ? file(keystoreProperties['storeFile'])
        : file("${System.getProperty('user.home')}/.android/debug.keystore")
    storePassword keystoreProperties['storePassword'] ?: 'android'
}
```

Added // TODO(release) comment at top of build.gradle for visibility.

---

## Developer Actions Required

### For local dev — nothing required
key.properties does not exist => Gradle falls back to debug keystore automatically.

### For Play Store release

Step 1: Generate a production keystore (do once, store safely):
```bash
keytool -genkey -v \
  -keystore ~/cosarc-release.keystore \
  -alias cosarc \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

Step 2: Create android/key.properties (DO NOT commit this file):
```
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=cosarc
storeFile=/absolute/path/to/cosarc-release.keystore
```

Step 3: Add to android/.gitignore (or root .gitignore):
```
android/key.properties
*.keystore
```

Step 4: Register SHA-1 with Supabase Google OAuth:
```bash
# Get release SHA-1:
keytool -list -v -keystore ~/cosarc-release.keystore -alias cosarc

# Get debug SHA-1 (if not already registered):
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```
Then add both fingerprints in:
- Supabase Dashboard -> Authentication -> Providers -> Google -> Android SHA-1
- Google Cloud Console -> OAuth 2.0 credentials -> Android client

### For CI/CD (GitHub Actions)
```yaml
- name: Create key.properties
  run: echo "${{ secrets.KEYSTORE_PROPERTIES }}" > android/key.properties

- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > /path/to/cosarc-release.keystore
```

---

## Verification Steps

### FIX 1
```bash
flutter run --debug
# Expected: splash -> LoginScreen (NOT ConfigurationErrorScreen)
# No "SUPABASE_ANON_KEY is not configured" in console
```

### FIX 2
```bash
flutter run --debug
# Sign in with an existing Supabase session account
# Expected: navigates exactly ONCE to dashboard or onboarding
# No "pushAndRemoveUntil called after widget is disposed" in console
# No black flash or double-push visible on screen
```

### FIX 3
```bash
flutter build apk --release
# Expected: build succeeds (debug keystore fallback used locally)
# No Gradle error about missing keystoreProperties
```

### Static analysis
```bash
dart analyze lib/core/config/app_config.dart lib/main.dart \
  lib/screens/app_start/app_start_screen.dart
```

---

## Issues Encountered

1. dart analyze could not run automatically — command timed out waiting for user approval.
   File correctness was verified by re-reading each file after edits. Manual analysis run
   is recommended.

2. Circular import note: app_start_screen.dart now imports main.dart via `show CosarcApp`.
   Dart handles this correctly since main.dart imports app_start_screen.dart for routing only
   (no class-level cycle). If the analyzer flags this, move markSplashDone to a separate
   lib/core/splash_guard.dart singleton and import that from both files instead.
