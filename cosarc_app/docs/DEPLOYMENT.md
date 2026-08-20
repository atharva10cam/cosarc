# Cosarc Deployment Checklist

## Prerequisites

- Flutter SDK >= 3.3.4
- Xcode 15+ (iOS)
- Android Studio + NDK (Android + Unity)
- Supabase CLI
- Node.js 18+ (Supabase CLI)

---

## 1. Environment Setup

Copy `.env.example` values into your CI/CD secrets or local run script.

```bash
# Required
SUPABASE_URL=https://lgblxxixgldizfidscpz.supabase.co
SUPABASE_ANON_KEY=<from Supabase Dashboard → Settings → API>

# Optional
USDA_API_KEY=<from https://fdc.nal.usda.gov/api-key-signup.html>
NUTRITIONIX_APP_ID=
NUTRITIONIX_APP_KEY=
```

### Local development

```bash
chmod +x scripts/run_dev.sh
./scripts/run_dev.sh
```

Or manually:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://lgblxxixgldizfidscpz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

---

## 2. Supabase Production

- [ ] Run migrations: `supabase db push`
- [ ] Verify RLS enabled on all tables
- [ ] Enable Google OAuth provider
- [ ] Configure redirect URLs (web + mobile deep links)
- [ ] Rotate anon key if previously committed to git
- [ ] Enable email confirmation (production)
- [ ] Set up daily backups (Pro plan)
- [ ] Configure custom SMTP for auth emails

---

## 3. Flutter — Android

- [ ] Replace debug keystore with production keystore in `android/app/build.gradle`
- [ ] Update `applicationId` from `com.example.cosarc_shell` to production ID
- [ ] Verify Unity `unityLibrary` builds on CI
- [ ] Test on arm64-v8a device
- [ ] Enable ProGuard rules for release
- [ ] Upload to Play Console internal track

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

---

## 4. Flutter — iOS

- [ ] Update bundle ID from `com.example.cosarcShell`
- [ ] Add `GoogleService-Info.plist` for Google Sign-In
- [ ] Configure URL schemes in `Info.plist`
- [ ] Note: Unity workout screen is Android-only
- [ ] Archive and upload to TestFlight

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

---

## 5. Flutter — Web

- [ ] Update `web/manifest.json` theme colors
- [ ] Configure Supabase redirect URL for production domain
- [ ] Build and deploy to hosting (Firebase, Vercel, etc.)

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

---

## 6. CI/CD Recommendations

### GitHub Actions (example stages)
1. `flutter analyze`
2. `flutter test`
3. `supabase db lint` (on migration changes)
4. Build APK/IPA/Web with secrets from GitHub Secrets
5. Deploy web artifact
6. Submit to stores (manual gate)

### Secrets to store in CI
- `SUPABASE_ANON_KEY`
- `USDA_API_KEY`
- Android keystore (base64) + passwords
- iOS certificates (Match/Fastlane)

---

## 7. Monitoring Recommendations

| Tool | Purpose |
|------|---------|
| Sentry | Flutter crash + error tracking |
| Supabase Dashboard | Auth, DB, API usage |
| Firebase Analytics | User engagement (optional) |
| Datadog / Grafana | Infrastructure (at scale) |

### Sentry setup (recommended)
```yaml
# pubspec.yaml
sentry_flutter: ^8.0.0
```

Initialize in `main.dart` before `runApp`.

---

## 8. Error Tracking

- Enable Supabase log drains to external service
- Track failed auth attempts in Supabase Auth logs
- Monitor `calculate_streak` RPC errors
- Alert on RLS policy violations (Postgres logs)

---

## 9. Pre-Launch Verification

- [ ] New user signup → onboarding → dashboard
- [ ] Google OAuth (web + Android)
- [ ] Log workout → streak updates
- [ ] Log food → contract nutrition flag set
- [ ] Water increment persists
- [ ] Logout → login again
- [ ] Offline: food logging still works (Hive)
- [ ] Release build size acceptable (<150MB Android with Unity)
