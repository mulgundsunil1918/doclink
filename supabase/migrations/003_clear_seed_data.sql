-- Clear all seed / test data from the database.
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
--
-- SAFE: This does NOT delete auth users or the logged-in doctor's profile/doctor row.
-- It only removes appointments, test patient profiles, prescriptions, and messages.

-- 1. Delete everything that references appointments first (FK order)
DELETE FROM messages;
DELETE FROM prescriptions;
DELETE FROM notifications;

-- 2. Delete all appointments
DELETE FROM appointments;

-- 3. Delete family_members for test patients
DELETE FROM family_members
WHERE patient_id IN (
  SELECT id FROM patients
  WHERE id IN (
    SELECT id FROM profiles WHERE role = 'patient'
  )
);

-- 4. Delete all patient records (rows in patients table)
DELETE FROM patients;

-- 5. Delete profiles that are patients (leaves doctor + receptionist profiles intact)
DELETE FROM profiles WHERE role = 'patient';

-- 6. Reset doctor earnings/stats back to zero (optional — comment out if you want to keep them)
UPDATE doctors SET
  earnings_today  = 0,
  earnings_month  = 0,
  total_patients  = 0,
  rating          = 0;

-- Done. The app will now show an empty queue and zero stats.
-- Real data will appear as actual patients sign up and book appointments.
