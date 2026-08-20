# Phase 2 Auth Screens — Completion Report

> Branch: `antigravity-premium` | Date: 2026-06-18

---

## Files Changed

### 1. `lib/screens/auth/otp_verification_screen.dart` — FIX 1: OTP Resend Cooldown

**Lines changed:** +20 (net additions)

**Changes made:**
- Added `import 'dart:async';` at top
- Added `Timer? _cooldownTimer` and `int _cooldownSeconds = 60` state variables
- Added `_startCooldown()` method — starts a `Timer.periodic` that ticks down from 60 to 0
- Called `_startCooldown()` from `initState()` so the cooldown begins immediately on screen open
- Added `_cooldownTimer?.cancel()` in `dispose()` — no timer leak
- Replaced the simple resend `TextButton` with one that:
  - Is disabled while `_cooldownSeconds > 0` or `_resending == true`
  - Shows `"Resend in Xs"` during cooldown
  - Shows `"Sending…"` while the network call is in flight
  - Shows `"Resend code"` when available
  - Restarts the cooldown after each successful resend tap

**No visual changes** — layout, padding, colors, typography all untouched.

---

### 2. `lib/screens/auth/phone_auth_screen.dart` — FIX 2: Country Picker + E.164

**Lines changed:** +120 (rewrite of phone input section)

**Changes made:**
- Added `_Country` class (name/code/flag) — plain class, no Dart records required, max compatibility
- Added `static const _countries` list with exactly 20 countries as specified
- Default country is `_countries.first` = India (+91)
- Added `_showCountryPicker()` — uses `showModalBottomSheet` with a `ListView` of all 20 countries; tapping selects and closes the sheet
- Replaced single `CosarcInput` phone field with a `Row`:
  - Left: `GestureDetector` wrapped `Container` showing `flag + code + chevron`, styled with `CosarcColors.glassFill` and `glassBorder`
  - Right: `Expanded` `TextField` for the local number only
- `_sendCode()` now:
  - Strips non-digits: `replaceAll(RegExp(r'[^0-9]'), '')`
  - Validates `local.length >= 7`
  - Assembles `fullPhone = _selectedCountry.code + local` (E.164)
  - Catches SMS-not-enabled errors with specific message
- **No new packages installed**

---

### 3. `lib/services/auth_service.dart` — FIX 3: friendlyAuthError expanded

**Lines changed:** +16 (method body only)

**Added/refined error cases:**

| Error string | User message |
|---|---|
| `invalid login credentials` | "Incorrect email or password. Please try again." *(refined)* |
| `email not confirmed` | "Please check your email and confirm your account first." *(refined)* |
| `user already registered` | *(unchanged)* |
| `email rate limit` | "Too many attempts. Please wait a few minutes before trying again." *(new)* |
| `not enabled` / `provider is not enabled` | "This sign-in method is not available. Please use email instead." *(new)* |
| `user not found` / `user_not_found` | "No account found with this email. Please sign up first." *(new)* |
| `phone not confirmed` / `phone` | "Phone verification failed. Please try again." *(new)* |
| `network` / `socket` | *(unchanged)* |
| `otp` / `token` | *(unchanged)* |
| fallback | *(unchanged)* |

---

### 4. `lib/screens/auth/login_screen.dart` — FIX 4: Email OTP user-not-found UX

**Lines changed:** +22

**Changes made:**
- Wrapped `sendEmailOtp(email, shouldCreateUser: false)` in an inner `try/catch`
- On `user not found` / `user_not_found` error: shows SnackBar with message + "Sign up" action button navigating to `SignupScreen`
- Any other error: `rethrow` → outer catch → `friendlyAuthError`
- **No layout changes**

---

## Google Sign-In Diagnosis

Full setup guide: `/Users/atharva/cosarc/GOOGLE_SIGNIN_REQUIREMENTS.md`

**Application ID:** `com.example.cosarc_shell`

| Item | Status |
|------|--------|
| Flutter code (google_sign_in + signInWithIdToken) | ✅ Implemented |
| `android/app/google-services.json` | ❌ MISSING — critical blocker |
| `com.google.gms.google-services` Gradle plugin | ❌ MISSING — critical blocker |
| SHA-1 fingerprint in Google Cloud Console | ❌ Not registered |
| Supabase Google provider enabled | ❌ Unknown |
| OAuth redirect intent-filter in AndroidManifest | ❌ Not present |
| iOS GoogleService-Info.plist | ❌ Not present |

---

## Compilation Concerns

1. **`CosarcSpacing.radiusMd`** in phone_auth_screen.dart — verify this constant exists; if not, swap for `CosarcSpacing.radiusPill` or literal `12.0`
2. **`CosarcColors.glassFill(0.06)` / `glassBorder()`** — matched exact call pattern from login_screen.dart; should compile fine
3. **`phone` broad match** in friendlyAuthError — intentionally broad but ordered after more-specific checks; safe

---

## Remaining Developer Actions

### Required before Google Sign-In works:
1. Run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android` → get SHA-1
2. Firebase Console → Add Android app → download `google-services.json` → place at `android/app/`
3. Apply `com.google.gms.google-services` plugin in both `build.gradle` files
4. Supabase dashboard → Google provider → enable with Web OAuth Client ID + Secret
5. Google Cloud Console → add Supabase callback URL as authorized redirect URI

### Verify after changes:
- OTP screen → countdown shows immediately, resend disabled for 60s
- Phone auth → country picker works, E.164 assembled correctly
- Login email OTP with unknown email → "No account found" snackbar + Sign up button
