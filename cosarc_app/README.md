# Cosarc

**Cinematic Fitness & Discipline** — Flutter app with Supabase backend, daily contracts, Unity workouts (Android), and nutrition tracking.

## Features

- Email & Google authentication
- 7-step onboarding profile setup
- Daily contract hub (workout, fuel, water, steps)
- Unity 3D muscle selector workout logging
- Multi-source nutrition search with local Indian food database
- Streak tracking with Dynamic Island–style UI
- My Gym, Nutriwave, and Cosarc AI tabs (partial backend integration)

## Quick Start

### 1. Prerequisites

- Flutter SDK >= 3.3.4
- Supabase project: [lgblxxixgldizfidscpz](https://lgblxxixgldizfidscpz.supabase.co)

### 2. Configure environment

Get your **anon key** from [Supabase Dashboard → API Settings](https://supabase.com/dashboard/project/lgblxxixgldizfidscpz/settings/api).

```bash
export SUPABASE_ANON_KEY=your_anon_key
chmod +x scripts/run_dev.sh
./scripts/run_dev.sh
```

See `.env.example` for all supported variables.

### 3. Apply database migrations

```bash
npm install -g supabase
supabase link --project-ref lgblxxixgldizfidscpz
supabase db push
```

## Project Structure

```
lib/
├── core/       # Config, Supabase, theme
├── models/     # Hive models
├── services/   # Auth, nutrition, contracts
├── screens/    # UI screens
└── widgets/    # Shared components
supabase/migrations/  # Postgres schema + RLS
docs/                 # Audit reports & deployment guides
```

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture Audit](docs/AUDIT_ARCHITECTURE.md) | System design & tech debt |
| [Security Report](docs/AUDIT_SECURITY.md) | Vulnerabilities & RLS |
| [Performance Report](docs/AUDIT_PERFORMANCE.md) | Bottlenecks & optimizations |
| [Scalability Report](docs/AUDIT_SCALABILITY.md) | Growth path |
| [UI/UX Report](docs/AUDIT_UI_UX.md) | Design system |
| [Backend Report](docs/AUDIT_BACKEND.md) | Supabase services |
| [Deployment Checklist](docs/DEPLOYMENT.md) | Production launch |
| [Final Delivery](docs/FINAL_DELIVERY.md) | Complete summary |

## Build for Production

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://lgblxxixgldizfidscpz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for full checklist.

## Platform Notes

- **Android:** Full feature set including Unity 3D workouts
- **iOS:** Auth and UI supported; Unity not integrated
- **Web:** Google OAuth via redirect; no Unity

## License

Private — all rights reserved.
