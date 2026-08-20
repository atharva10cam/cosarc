# Cosarc — Security Report (Phase 1 & 3)

**Date:** June 15, 2026  
**Supabase Project:** https://lgblxxixgldizfidscpz.supabase.co

---

## 1. Vulnerabilities Found (Pre-Hardening)

| Finding | Severity | Location |
|---------|----------|----------|
| Hardcoded Supabase anon JWT in source | **High** | `lib/core/supabase_config.dart` (old) |
| Exposed USDA API key in repo | **Medium** | `lib/services/indian_food_database.dart` (old) |
| Debug keystore used for release builds | **High** | `android/app/build.gradle` |
| No RLS policies in repo (unknown prod state) | **High** | Supabase |
| Verbose auth logging with emails | **Low** | `auth_service.dart`, `main.dart` |
| Placeholder third-party API keys | **Info** | `enhanced_nutrition_service.dart` |
| OAuth WebView handler unused | **Low** | `oauth_webview_screen.dart` |
| No input sanitization on workout notes | **Low** | `workout_log_screen.dart` |
| Hive stores food logs unencrypted locally | **Low** | Acceptable for non-PII macros |

---

## 2. Remediation Applied

### Secrets Management
- Moved Supabase URL + anon key to `--dart-define` via `AppConfig`
- Removed committed JWT from source control
- USDA key now via `USDA_API_KEY` dart-define (defaults to `DEMO_KEY`)
- Added `.env.example` and `scripts/run_dev.sh` for local setup

### Supabase RLS
- Full RLS on all tables: users can only access own rows via `auth.uid()`
- `calculate_streak` validates caller owns `p_member_id`
- Storage bucket `avatars` with per-user folder policies
- Auto-create member trigger on `auth.users` insert (defense in depth)

### Auth Hardening
- PKCE-ready Supabase client initialization
- Replaced `print()` with `debugPrint()` for auth flows
- Configuration error screen prevents silent failures

### Still Required (Manual)

| Action | Owner |
|--------|-------|
| Rotate exposed Supabase anon key if repo was public | DevOps |
| Set production release keystore (Android) | DevOps |
| Configure Google OAuth in Supabase dashboard | Backend |
| Add `GoogleService-Info.plist` + URL schemes (iOS) | Mobile |
| Never commit service_role key | All |
| Enable Supabase email confirmation for production | Backend |
| Configure rate limiting on Edge Functions (future) | Backend |

---

## 3. RLS Policy Summary

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| members | own | own | own | — |
| streaks | own | own | own | — |
| daily_contracts | own | own | own | — |
| workout_logs | own | own | — | — |
| food_logs | own | own | — | own |
| storage.avatars | own folder | own folder | own folder | own folder |

---

## 4. Security Checklist (Production)

- [ ] `SUPABASE_ANON_KEY` injected via CI secrets only
- [ ] Service role key stored in Supabase Edge Functions secrets only
- [ ] RLS enabled and verified on all public tables
- [ ] Google OAuth redirect URLs whitelisted in Supabase
- [ ] Android release signed with production keystore
- [ ] iOS provisioning + App Store Connect configured
- [ ] Enable Supabase audit logs (Pro plan)
- [ ] Enable leaked password protection in Auth settings

---

## 5. Post-Hardening Risk Rating

| Area | Before | After |
|------|--------|-------|
| Secret exposure | High | Low (with dart-define) |
| Data isolation | Unknown | Low (RLS migrations provided) |
| Auth flow | Medium | Low |
| Local storage | Low | Low |
| Release signing | High | High (manual fix needed) |
