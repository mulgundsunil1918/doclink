-- Migration 005: Extended prescription data + per-doctor template settings
-- Backward compatible: JSONB columns default to '{}' so existing rows are unaffected.

ALTER TABLE prescriptions
  ADD COLUMN IF NOT EXISTS extended_data      JSONB DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS verification_code  TEXT;

ALTER TABLE doctors
  ADD COLUMN IF NOT EXISTS prescription_settings JSONB DEFAULT '{}';
