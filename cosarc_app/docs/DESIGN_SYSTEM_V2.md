# Cosarc Design System V2

Premium dark-first design language for the Cosarc mobile app. Derived from the ERP dashboard palette (champagne gold on deep charcoal) and refined for Apple-grade mobile experiences.

## Color Philosophy

| Token | Value | Usage |
|-------|-------|-------|
| `CosarcColors.primary` | `#D7BB73` | CTAs, active states, streak accent |
| `CosarcColors.background` | `#060607` | Root surface |
| `CosarcColors.surfaceElevated` | `#121214` | Cards, sheets |
| `CosarcColors.textPrimary` | `#F8F5EC` | Headlines, data |
| `CosarcColors.textSecondary` | 70% primary text | Body copy |
| `CosarcColors.accent` | `#42D888` | Success, completion |
| `CosarcColors.protein/carbs/fat` | Blue/Orange/Purple | Macro visualization |

## Typography

- **Font:** Inter via Google Fonts
- **Display:** 34–42px, w700, negative letter-spacing — editorial headlines
- **Title:** 20px, w600 — section headers
- **Overline:** 11px, w700, 1.6 letter-spacing — labels (WORKSPACE, DAILY CONTRACT)
- **Metric:** 36px, w800 — live data points

Use `CosarcTypography.display()`, `.headline()`, `.title()`, `.body()`, `.caption()`, `.overline()`, `.metric()`, `.brandMark()`.

## Spacing

4pt base scale via `CosarcSpacing`: `xxs(4)` → `huge(48)`. Screen horizontal padding: **24px**. Card padding: **20px**. Button height: **52px**.

## Radius

| Token | Value |
|-------|-------|
| `radiusSm` | 12 |
| `radiusMd` | 16 |
| `radiusLg` | 20 |
| `radiusXl` | 24 |
| `radiusPill` | 999 |

## Glass System

`CosarcGlass` — frosted surface with `BackdropFilter`, configurable blur/opacity/border. Use for cards, inputs, nav bar, bottom sheets.

`CosarcScaffold` — ambient radial gradients (gold + rose) over deep background.

## Motion

`CosarcMotion` — spring physics (`islandSpring`, `softSpring`), durations (180–680ms), easing curves. Onboarding uses `AnimatedSwitcher` fade+slide transitions.

## Components

| Component | Purpose |
|-----------|---------|
| `CosarcButton` | Primary / secondary / ghost actions |
| `CosarcCard` | Legacy frosted card (prefer `CosarcGlass`) |
| `CosarcInput` | Glass-wrapped text fields |
| `CosarcNavBar` | Floating pill bottom navigation |
| `CosarcLoader` | Branded loading state |
| `CosarcEmptyState` | Empty/error placeholders |
| `CosarcDialog` | Modal dialogs |
| `OnboardingStep` | Full-screen onboarding layout |
| `OnboardingOption` | Selectable onboarding choices |
| `DynamicIslandStreak` | Expandable streak widget |

## Navigation

`DashboardRoot` uses floating `CosarcNavBar` with `extendBody: true` over transparent tab screens.

## Screens Transformed (V2)

1. App Start (splash overlay)
2. App Start — config error
3. Login
4. Signup
5. OAuth WebView (inherits theme)
6. Onboarding wrapper + all 7 steps
7. Setup animation + complete
8. Dashboard root / navigation
9. Cosmos (Command Center)
10. My Gym
11. Nutriwave
12. Cosarc AI
13. Profile
14. Workout Log (Unity preserved)
15. Enhanced Nutrition + Food Search (tokens)

## Backend Boundaries

No changes to: Supabase, auth logic, Hive models, Unity bridge, daily contract service, nutrition calculations.
