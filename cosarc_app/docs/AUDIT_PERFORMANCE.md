# Cosarc — Performance Report (Phase 1 & 5)

**Date:** June 15, 2026

---

## 1. Bottlenecks Identified

| Issue | Impact | Location |
|-------|--------|----------|
| Unity IL2CPP library (~2000+ files) | Large APK, slow cold start | `android/unityLibrary/` |
| Intro + cosmos videos loaded at runtime | Memory + startup delay | `AppStartScreen`, `CosmosScreen` |
| Multi-API nutrition search (6 parallel calls) | Network latency | `NutritionServiceV2.searchFood` |
| Repeated Supabase member ID lookups | Redundant queries | Multiple screens |
| `IndexedStack` keeps all 4 tabs alive | Memory retention | `DashboardRoot` |
| No image caching strategy | Re-decode assets | Galaxy backgrounds |
| Hive box opened synchronously at startup | Blocks main isolate (8s timeout) | `main.dart` |

---

## 2. Optimizations Applied

| Change | Benefit |
|--------|---------|
| Indian food DB searched first (local, instant) | Faster nutrition search |
| 500ms debounce on food search | Fewer API calls |
| Startup timeouts on Hive/Supabase (8–12s) | Prevents infinite hang |
| `debugPrint` instead of sync `print` | Slightly less I/O overhead |
| Centralized theme (single `ThemeData` build) | Reduced widget rebuild cost |

---

## 3. Recommended (Not Yet Implemented)

| Recommendation | Priority |
|----------------|----------|
| Lazy-load Unity screen only when opened | High |
| Cache `memberId` in memory after auth | Medium |
| Use `AutomaticKeepAliveClientMixin` selectively vs full IndexedStack | Medium |
| Paginate nutrition API results | Medium |
| Preload only one video OR use static hero image on low-end devices | Medium |
| Add `cached_network_image` if remote images added | Low |
| Server-side food search Edge Function (single round-trip) | Low |

---

## 4. Dead Code / Duplicates to Remove (Future)

- `lib_backup/` — reference snapshot, not compiled
- `lib/screens/dashboard/dashboard_screen.dart` — unused
- `lib/test_connection.dart` — dev only
- `lib/services/nutrition_tracker.dart` — legacy UI embedded in service
- Duplicate color constants — migrating to `cosarc_colors.dart`

---

## 5. Metrics Targets (Production)

| Metric | Target |
|--------|--------|
| Cold start (no Unity) | < 3s |
| Time to interactive after splash | < 5s |
| Nutrition search (local hit) | < 200ms |
| Nutrition search (API) | < 2s |
| Dashboard tab switch | < 16ms (60fps) |
