/*
  # Initial Database Schema

  1. New Tables
    - `systems`: Stores tracking system configurations
      - `id` (uuid, primary key)
      - `name` (text)
      - `auth_code` (text, unique)
      - `admin_password` (text)
      - `admin_name` (text, nullable)
      - `security_question` (text, nullable)
      - `security_answer` (text, nullable)
      - `created_at` (timestamptz)

    - `devotees`: Stores devotee information
      - `id` (uuid, primary key)
      - `name` (text)
      - `is_resident` (boolean)
      - `created_at` (timestamptz)
      - `system_id` (uuid, references systems)

    - `daily_records`: Stores daily activity records
      - `id` (uuid, primary key)
      - `date` (date)
      - `devotee_id` (uuid, references devotees)
      - `mangla` (numeric)
      - `japa` (numeric)
      - `lecture` (numeric)
      - `temple_visit` (boolean)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated access
*/

-- Create systems table
CREATE TABLE public.systems (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  auth_code text UNIQUE NOT NULL,
  admin_password text NOT NULL DEFAULT '9090',
  admin_name text,
  security_question text,
  security_answer text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS for systems
ALTER TABLE public.systems ENABLE ROW LEVEL SECURITY;

-- Create systems policies
CREATE POLICY "Enable system insert" ON public.systems
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable system read" ON public.systems
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable system update" ON public.systems
  FOR UPDATE TO authenticated USING (true);

-- Create devotees table
CREATE TABLE public.devotees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  is_resident boolean DEFAULT false NOT NULL,
  created_at timestamptz DEFAULT now(),
  system_id uuid REFERENCES public.systems(id) ON DELETE CASCADE
);

-- Enable RLS for devotees
ALTER TABLE public.devotees ENABLE ROW LEVEL SECURITY;

-- Create devotees policies
CREATE POLICY "Enable devotee delete" ON public.devotees
  FOR DELETE TO authenticated USING (true);

CREATE POLICY "Enable devotee insert" ON public.devotees
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable devotee read" ON public.devotees
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable devotee update" ON public.devotees
  FOR UPDATE TO authenticated USING (true);

-- Create daily_records table
CREATE TABLE public.daily_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL,
  devotee_id uuid REFERENCES public.devotees(id) ON DELETE CASCADE,
  mangla numeric DEFAULT 0 CHECK (mangla = ANY (ARRAY[0, 0.5, 1]::numeric[])),
  japa numeric DEFAULT 0 CHECK (japa = ANY (ARRAY[0, 0.5, 1]::numeric[])),
  lecture numeric DEFAULT 0 CHECK (lecture = ANY (ARRAY[0, 0.5, 1]::numeric[])),
  temple_visit boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  UNIQUE(devotee_id, date)
);

-- Enable RLS for daily_records
ALTER TABLE public.daily_records ENABLE ROW LEVEL SECURITY;

-- Create daily_records policies
CREATE POLICY "Enable daily_record delete" ON public.daily_records
  FOR DELETE TO authenticated USING (true);

CREATE POLICY "Enable daily_record insert" ON public.daily_records
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable daily_record read" ON public.daily_records
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable daily_record update" ON public.daily_records
  FOR UPDATE TO authenticated USING (true);

-- Create indices for better performance
CREATE INDEX idx_devotees_system_id ON public.devotees(system_id);
CREATE INDEX idx_daily_records_devotee_id ON public.daily_records(devotee_id);
CREATE INDEX idx_daily_records_date ON public.daily_records(date);