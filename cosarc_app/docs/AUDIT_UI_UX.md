# Cosarc — UI/UX Report

**Date:** June 15, 2026

---

## 1. Pre-Redesign Issues

| Issue | Screens Affected |
|-------|------------------|
| Inconsistent typography (Montserrat vs Inter) | Auth vs Dashboard |
| Duplicated color constants | All |
| Mixed button styles (white/black vs pink) | Login vs Onboarding |
| No max-width on web login | Login |
| Low contrast frosted cards on video backgrounds | Cosmos |
| Steps card read-only with no input | Cosmos |
| Mock data presented as live (My Gym, Nutriwave) | Dashboard tabs |
| Web manifest uses default Flutter blue | PWA |
| No semantic labels on some icon buttons | Various |
| Missing empty states on some lists | Nutrition |

---

## 2. Design System Implemented

### Typography
- **Primary:** Inter (SF Pro–style hierarchy)
- Weights: 400 body, 600 titles, 700 display
- Letter-spacing tuned for headlines (-0.3 to -1.2)

### Colors
| Token | Value | Usage |
|-------|-------|-------|
| primary | `#E91E63` | CTAs, selected nav |
| accent | `#00E676` | Nutrition success |
| background | `#000000` | Root surfaces |
| surface | `#121212` | Cards, inputs |
| textSecondary | 70% white | Body copy |

### Spacing
4pt base system: 4, 8, 12, 16, 20, 24, 32, 40, 48

### Components
- `CosarcButton` — primary/secondary/ghost + loading
- `CosarcCard` — frosted glass surface
- `CosarcEmptyState` — consistent empty views
- `CosarcLoader` — branded spinner
- `CosarcDialog` — alert dialogs

---

## 3. Screens Updated

| Screen | Changes |
|--------|---------|
| Global theme | `CosarcTheme.dark()` in `main.dart` |
| Login | Premium layout, CosarcButton, max-width |
| Dashboard nav | Refined animations, design tokens |
| App start | Config error screen |
| Success | Fixed navigation, premium check icon |
| Food search | Nutrition contract sync |

---

## 4. Accessibility Gaps (Remaining)

- [ ] Add `Semantics` labels to bottom nav items
- [ ] Verify 4.5:1 contrast on tertiary text over video
- [ ] Support `MediaQuery.textScaler` cap testing
- [ ] VoiceOver order on Cosmos contract cards
- [ ] Focus order on web keyboard navigation

---

## 5. Responsiveness

| Breakpoint | Status |
|------------|--------|
| Mobile (<600) | Primary target — good |
| Tablet (600–1024) | Login constrained; dashboard needs grid |
| Desktop (>1024) | Login max-width 420px; dashboard full-bleed |
| Web | OAuth flow supported; PWA manifest needs brand colors |

---

## 6. Animation Guidelines Applied

- Duration: 180–200ms for micro-interactions
- Curve: `easeOutCubic` for nav selection
- No bounce/elastic gimmicks
- Dynamic Island streak retains spring (brand signature)
