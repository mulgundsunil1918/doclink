-- Doctor availability: stores per-day slot configuration
CREATE TABLE IF NOT EXISTS doctor_availability (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id      UUID NOT NULL,
  date           DATE NOT NULL,
  is_open        BOOLEAN DEFAULT TRUE,
  slots          JSONB DEFAULT '[]',
  updated_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(doctor_id, date)
);
CREATE INDEX IF NOT EXISTS idx_da_doctor_date ON doctor_availability(doctor_id, date);
ALTER TABLE doctor_availability ENABLE ROW LEVEL SECURITY;
CREATE POLICY "doctor_own" ON doctor_availability FOR ALL TO authenticated
  USING (doctor_id = auth.uid()) WITH CHECK (doctor_id = auth.uid());
CREATE POLICY "all_read" ON doctor_availability FOR SELECT TO authenticated USING (true);
