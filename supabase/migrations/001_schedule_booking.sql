-- ============================================================
-- UniBluePrint - Schedule Booking Database Migration
-- Migration: 001_schedule_booking.sql
-- Description: Creates all tables required for the N8N
--              Schedule Booking workflow
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE: users
-- Stores student profile information
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    university      TEXT,
    course          TEXT,
    year_of_study   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast email lookups (used in user-exists check)
CREATE UNIQUE INDEX IF NOT EXISTS users_email_idx ON public.users (email);

-- Auto-update updated_at on row change
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- TABLE: schedules
-- Stores raw input data and AI-generated schedule output
-- ============================================================
CREATE TABLE IF NOT EXISTS public.schedules (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- Raw input data (JSONB for flexible querying)
    schedule_data       JSONB,   -- lectures, hobbies, sports, social/college events, commute
    routines            JSONB,   -- wake/bed times, morning/evening routines, personal care
    work_info           JSONB,   -- part-time work, job hunting, interviews
    goals               JSONB,   -- main goals, strengths, weaknesses, objectives
    preferences         JSONB,   -- study style, break duration, free days, energy levels

    -- AI-generated output
    generated_schedule  JSONB,   -- weeklySchedule object from Claude
    recommendations     JSONB,   -- summary, insights, strategy, improvements, warnings
    metrics             JSONB,   -- totalHours, studyHours, freeTime, sleepHours, etc.

    -- Workflow status
    status              TEXT NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'processing', 'generated', 'delivered', 'failed')),

    -- Token usage tracking
    prompt_tokens       INTEGER DEFAULT 0,
    completion_tokens   INTEGER DEFAULT 0,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS schedules_user_id_idx ON public.schedules (user_id);
CREATE INDEX IF NOT EXISTS schedules_status_idx  ON public.schedules (status);
CREATE INDEX IF NOT EXISTS schedules_created_at_idx ON public.schedules (created_at DESC);

CREATE TRIGGER schedules_updated_at
    BEFORE UPDATE ON public.schedules
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- TABLE: services_purchased
-- Tracks which services each student has purchased and
-- whether they have been delivered
-- ============================================================
CREATE TABLE IF NOT EXISTS public.services_purchased (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    service_type    TEXT NOT NULL,       -- e.g. 'Schedule', 'CV Review', 'Mentorship'
    status          TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'processing', 'delivered', 'failed', 'refunded')),
    purchased_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_at    TIMESTAMPTZ,
    notes           TEXT,
    metadata        JSONB                -- flexible data per service type
);

CREATE INDEX IF NOT EXISTS services_user_id_idx       ON public.services_purchased (user_id);
CREATE INDEX IF NOT EXISTS services_type_status_idx   ON public.services_purchased (service_type, status);

-- ============================================================
-- TABLE: workflow_logs
-- Append-only audit log for every workflow execution step
-- ============================================================
CREATE TABLE IF NOT EXISTS public.workflow_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type      TEXT NOT NULL,       -- 'start', 'step', 'error', 'complete'
    error_type      TEXT,               -- 'validation', 'api', 'email', 'db'
    error_message   TEXT,
    student_email   TEXT,
    schedule_id     UUID REFERENCES public.schedules(id) ON DELETE SET NULL,
    metadata        JSONB,              -- any extra context
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS logs_event_type_idx    ON public.workflow_logs (event_type);
CREATE INDEX IF NOT EXISTS logs_created_at_idx    ON public.workflow_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS logs_student_email_idx ON public.workflow_logs (student_email);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Enable RLS on all tables. The N8N service role bypasses RLS.
-- Students (if authenticated via Supabase Auth) can only read
-- their own data.
-- ============================================================
ALTER TABLE public.users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services_purchased  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workflow_logs       ENABLE ROW LEVEL SECURITY;

-- Service role (used by N8N) bypasses RLS automatically.
-- Policy for anon/authenticated users to read their own data:

CREATE POLICY "Users can read own profile"
    ON public.users FOR SELECT
    USING (auth.uid()::text = id::text);

CREATE POLICY "Users can read own schedules"
    ON public.schedules FOR SELECT
    USING (user_id IN (
        SELECT id FROM public.users WHERE auth.uid()::text = id::text
    ));

CREATE POLICY "Users can read own services"
    ON public.services_purchased FOR SELECT
    USING (user_id IN (
        SELECT id FROM public.users WHERE auth.uid()::text = id::text
    ));

-- Admins can read all workflow logs (no public access)
-- Managed entirely via service role in N8N

-- ============================================================
-- SEED: Insert sample services for testing
-- ============================================================
-- Uncomment to insert a test service entry after creating a user:
-- INSERT INTO public.services_purchased (user_id, service_type, status)
-- SELECT id, 'Schedule', 'pending'
-- FROM public.users
-- WHERE email = 'test@example.com';

-- ============================================================
-- USEFUL QUERIES
-- ============================================================

-- View all pending schedules:
-- SELECT u.name, u.email, s.status, s.created_at
-- FROM schedules s JOIN users u ON s.user_id = u.id
-- WHERE s.status IN ('pending', 'processing')
-- ORDER BY s.created_at;

-- View delivery stats:
-- SELECT status, COUNT(*) as count
-- FROM schedules
-- GROUP BY status
-- ORDER BY count DESC;

-- View recent errors:
-- SELECT student_email, error_type, error_message, created_at
-- FROM workflow_logs
-- WHERE event_type = 'error'
-- ORDER BY created_at DESC
-- LIMIT 50;
