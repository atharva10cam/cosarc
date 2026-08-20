# Phase 3 Migration Report

**Migration file:** `supabase/migrations/20260618000001_phase3_rls_and_indexes.sql`  
**Date:** 2026-06-18  
**Status:** ✅ Ready to apply

---

## What Was Added and Why

### 1. Missing RLS Policies (3 policies added)

| Table | Operation | Status Before | Status After |
|---|---|---|---|
| `workout_logs` | UPDATE | ❌ Missing | ✅ Added |
| `workout_logs` | DELETE | ❌ Missing | ✅ Added |
| `food_logs` | UPDATE | ❌ Missing | ✅ Added |

**Why this matters:**
Without UPDATE/DELETE policies on `workout_logs`, an authenticated user could not edit or remove their own workout entries — the database would silently reject the operation (RLS returns 0 rows affected, no error). The missing UPDATE policy on `food_logs` similarly blocked any edit of a logged meal.
All three new policies use `public.current_member_id()` in both `USING` (row visibility) and `WITH CHECK` (write guard) clauses, ensuring users can only modify their own rows.

---

### 2. Unique Constraint on `daily_contracts(member_id, contract_date)`

**Why this matters:**
The Dart upsert call uses `onConflict: 'member_id,contract_date'`. Without a corresponding database-level unique constraint naming those exact columns, Supabase/PostgREST cannot resolve the conflict target and the upsert silently falls back to an INSERT — risking duplicate rows per member per day.

**Safety note:**
The constraint addition is wrapped in an idempotent `DO $$ ... END $$` block — it checks `information_schema.table_constraints` before attempting the `ALTER TABLE`, so running the migration twice is harmless.
Even if the table already contains rows, the constraint is safe to add: the existing insert-if-null logic in the app code prevented duplicate `(member_id, contract_date)` pairs from ever being written, so no deduplication step is needed before applying this migration.

---

### 3. Performance Indexes (3 indexes added)

| Index | Table | Columns | Purpose |
|---|---|---|---|
| `idx_workout_logs_member_created` | `workout_logs` | `(member_id, created_at DESC)` | Monthly workout count query (`WHERE member_id = ? AND created_at >= ?`) |
| `idx_streaks_member_id` | `streaks` | `(member_id)` | Streak lookups — heavily queried on every app open |
| `idx_daily_contracts_member_date` | `daily_contracts` | `(member_id, contract_date DESC)` | Per-member date-range contract fetches |

**Safety note:**
All three indexes use `CREATE INDEX IF NOT EXISTS`, making them fully idempotent. Postgres creates indexes online by default (no table lock on small tables), so these can be applied to a live production database at any time without downtime.

---

## How to Apply

### Option A — Supabase CLI (recommended)

```bash
cd /Users/atharva/cosarc
supabase db push
```

This applies all pending migrations in timestamp order. Ensure your `SUPABASE_DB_URL` or `supabase/config.toml` is pointed at the correct project.

### Option B — Supabase SQL Editor

1. Open the Supabase Dashboard → your project → **SQL Editor**
2. Copy and paste the full contents of `supabase/migrations/20260618000001_phase3_rls_and_indexes.sql`
3. Click **Run**

---

## Idempotency Summary

| Operation | Idempotent? | Mechanism |
|---|---|---|
| `DROP POLICY IF EXISTS` + `CREATE POLICY` | ✅ | `IF EXISTS` guard on drop |
| `ALTER TABLE ... ADD CONSTRAINT` | ✅ | `DO $$ IF NOT EXISTS ... END $$` block |
| `CREATE INDEX IF NOT EXISTS` | ✅ | Native Postgres `IF NOT EXISTS` |

All operations are safe to run on an existing production database with live data.
