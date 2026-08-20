#!/usr/bin/env bash
# Local development runner for Cosarc
# Usage: ./scripts/run_dev.sh [device_id]

set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-https://lgblxxixgldizfidscpz.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  echo "Error: SUPABASE_ANON_KEY is not set."
  echo "Export it or add to this script:"
  echo "  export SUPABASE_ANON_KEY=your_key"
  echo ""
  echo "Get your key from:"
  echo "  https://supabase.com/dashboard/project/lgblxxixgldizfidscpz/settings/api"
  exit 1
fi

DART_DEFINES=(
  "--dart-define=SUPABASE_URL=${SUPABASE_URL}"
  "--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}"
)

if [[ -n "${USDA_API_KEY:-}" ]]; then
  DART_DEFINES+=("--dart-define=USDA_API_KEY=${USDA_API_KEY}")
fi

if [[ -n "${1:-}" ]]; then
  flutter run -d "$1" "${DART_DEFINES[@]}"
else
  flutter run "${DART_DEFINES[@]}"
fi
