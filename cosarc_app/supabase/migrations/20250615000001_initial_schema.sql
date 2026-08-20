-- Cosarc production schema
-- Project: https://lgblxxixgldizfidscpz.supabase.co

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- MEMBERS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  name TEXT,
  gender TEXT,
  age INTEGER CHECK (age IS NULL OR (age >= 13 AND age <= 120)),
  height NUMERIC CHECK (height IS NULL OR height > 0),
  weight NUMERIC CHECK (weight IS NULL OR weight > 0),
  workout_preference TEXT,
  activity_level TEXT,
  training_frequency INTEGER CHECK (training_frequency IS NULL OR (training_frequency >= 1 AND training_frequency <= 7)),
  fitness_goal TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT members_auth_user_id_unique UNIQUE (auth_user_id)
);

CREATE INDEX IF NOT EXISTS idx_members_auth_user_id ON public.members(auth_user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- STREAKS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.streaks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
  last_workout_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT streaks_member_id_unique UNIQUE (member_id)
);

CREATE INDEX IF NOT EXISTS idx_streaks_member_id ON public.streaks(member_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- DAILY CONTRACTS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.daily_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  contract_date DATE NOT NULL,
  workout_completed BOOLEAN NOT NULL DEFAULT false,
  nutrition_logged BOOLEAN NOT NULL DEFAULT false,
  water_intake_ml INTEGER NOT NULL DEFAULT 0 CHECK (water_intake_ml >= 0),
  steps_count INTEGER NOT NULL DEFAULT 0 CHECK (steps_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT daily_contracts_member_date_unique UNIQUE (member_id, contract_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_contracts_member_date
  ON public.daily_contracts(member_id, contract_date DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- WORKOUT LOGS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.workout_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  workout_date DATE NOT NULL,
  target_muscles TEXT[] NOT NULL DEFAULT '{}',
  exercises TEXT,
  duration_minutes INTEGER CHECK (duration_minutes IS NULL OR duration_minutes > 0),
  intensity INTEGER CHECK (intensity IS NULL OR (intensity >= 1 AND intensity <= 100)),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_workout_logs_member_date
  ON public.workout_logs(member_id, workout_date DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- FOOD LOGS (server-side backup / sync)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.food_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  log_date DATE NOT NULL DEFAULT CURRENT_DATE,
  name TEXT NOT NULL,
  calories NUMERIC NOT NULL DEFAULT 0,
  protein NUMERIC NOT NULL DEFAULT 0,
  carbs NUMERIC NOT NULL DEFAULT 0,
  fat NUMERIC NOT NULL DEFAULT 0,
  quantity NUMERIC NOT NULL DEFAULT 1,
  meal_type TEXT NOT NULL,
  unit TEXT NOT NULL DEFAULT 'servings',
  logged_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_food_logs_member_date
  ON public.food_logs(member_id, log_date DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- UPDATED_AT TRIGGER
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_members_updated_at ON public.members;
CREATE TRIGGER trg_members_updated_at
  BEFORE UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_streaks_updated_at ON public.streaks;
CREATE TRIGGER trg_streaks_updated_at
  BEFORE UPDATE ON public.streaks
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_daily_contracts_updated_at ON public.daily_contracts;
CREATE TRIGGER trg_daily_contracts_updated_at
  BEFORE UPDATE ON public.daily_contracts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ─────────────────────────────────────────────────────────────────────────────
-- STREAK CALCULATION
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.calculate_streak(p_member_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_date DATE;
  v_current INTEGER;
  v_longest INTEGER;
  v_today DATE := CURRENT_DATE;
BEGIN
  IF p_member_id IS NULL THEN
    RETURN;
  END IF;

  IF auth.uid() IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = p_member_id AND m.auth_user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Unauthorized streak calculation';
    END IF;
  END IF;

  SELECT last_workout_date, current_streak, longest_streak
  INTO v_last_date, v_current, v_longest
  FROM public.streaks
  WHERE member_id = p_member_id
  FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO public.streaks (member_id, current_streak, longest_streak, last_workout_date)
    VALUES (p_member_id, 1, 1, v_today);
    RETURN;
  END IF;

  IF v_last_date = v_today THEN
    RETURN;
  ELSIF v_last_date = v_today - 1 THEN
    v_current := COALESCE(v_current, 0) + 1;
  ELSE
    v_current := 1;
  END IF;

  v_longest := GREATEST(COALESCE(v_longest, 0), v_current);

  UPDATE public.streaks
  SET current_streak = v_current,
      longest_streak = v_longest,
      last_workout_date = v_today,
      updated_at = now()
  WHERE member_id = p_member_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.calculate_streak(UUID) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- AUTO-CREATE MEMBER ON SIGNUP (optional server-side safety net)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_member_id UUID;
BEGIN
  INSERT INTO public.members (auth_user_id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1), 'User')
  )
  ON CONFLICT (auth_user_id) DO NOTHING
  RETURNING id INTO v_member_id;

  IF v_member_id IS NOT NULL THEN
    INSERT INTO public.streaks (member_id)
    VALUES (v_member_id)
    ON CONFLICT (member_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
