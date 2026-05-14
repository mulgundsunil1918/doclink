import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class MockDoctor {
  final String id, name, specialty, regNumber, phone, city;
  final double rating;
  final int experience, patientsToday, totalPatients;
  final double earningsToday, earningsMonth;
  final List<MockAppointment> appointments;
  const MockDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.regNumber,
    required this.phone,
    required this.city,
    required this.rating,
    required this.experience,
    required this.patientsToday,
    required this.totalPatients,
    required this.earningsToday,
    required this.earningsMonth,
    required this.appointments,
  });
}

class MockAppointment {
  final String id, patientName, type, status, time, chiefComplaint;
  final int tokenNo;
  const MockAppointment({
    required this.id,
    required this.patientName,
    required this.type,
    required this.status,
    required this.time,
    required this.chiefComplaint,
    required this.tokenNo,
  });
}

class MockPrescription {
  final String id, doctorName, date, diagnosis;
  final List<MockMedicine> medicines;
  final String? followUpDate;
  const MockPrescription({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.medicines,
    this.followUpDate,
  });
}

class MockMedicine {
  final String name, dosage, frequency, duration;
  const MockMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });
}

class MockEarningEntry {
  final String month;
  final double amount;
  const MockEarningEntry(this.month, this.amount);
}

class MockPatient {
  final String id, name, phone, age, gender;
  final List<MockPrescription> prescriptions;
  const MockPatient({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.prescriptions,
  });
}

class MockChatMessage {
  final String text, sender;
  final DateTime time;
  const MockChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class MockData {
  MockData._();

  static final doctor = MockDoctor(
    id: 'doc_001',
    name: 'Dr. Arjun Mehta',
    specialty: 'General Physician',
    regNumber: 'MH-2019-12345',
    phone: '9876543210',
    city: 'Mumbai',
    rating: 4.8,
    experience: 7,
    patientsToday: 12,
    totalPatients: 3420,
    earningsToday: 4800,
    earningsMonth: 87500,
    appointments: appointments,
  );

  static const appointments = [
    MockAppointment(
      id: 'apt_001',
      patientName: 'Riya Sharma',
      type: 'video',
      status: 'confirmed',
      time: '09:00 AM',
      chiefComplaint: 'Fever & headache since 2 days',
      tokenNo: 1,
    ),
    MockAppointment(
      id: 'apt_002',
      patientName: 'Karan Patel',
      type: 'audio',
      status: 'confirmed',
      time: '09:20 AM',
      chiefComplaint: 'Chronic back pain follow-up',
      tokenNo: 2,
    ),
    MockAppointment(
      id: 'apt_003',
      patientName: 'Sunita Rao',
      type: 'chat',
      status: 'ongoing',
      time: '09:40 AM',
      chiefComplaint: 'Skin rash on arms',
      tokenNo: 3,
    ),
    MockAppointment(
      id: 'apt_004',
      patientName: 'Amit Joshi',
      type: 'video',
      status: 'pending',
      time: '10:00 AM',
      chiefComplaint: 'Diabetes review + HbA1c report',
      tokenNo: 4,
    ),
    MockAppointment(
      id: 'apt_005',
      patientName: 'Pooja Nair',
      type: 'in_person',
      status: 'pending',
      time: '10:20 AM',
      chiefComplaint: 'Routine BP check',
      tokenNo: 5,
    ),
    MockAppointment(
      id: 'apt_006',
      patientName: 'Vikram Singh',
      type: 'video',
      status: 'completed',
      time: '08:00 AM',
      chiefComplaint: 'Cold & cough',
      tokenNo: 6,
    ),
  ];

  static const prescriptions = [
    MockPrescription(
      id: 'rx_001',
      doctorName: 'Dr. Arjun Mehta',
      date: '12 May 2026',
      diagnosis: 'Viral Fever with Pharyngitis',
      followUpDate: '19 May 2026',
      medicines: [
        MockMedicine(
          name: 'Paracetamol 650mg',
          dosage: '1 tablet',
          frequency: 'Twice daily after meals',
          duration: '5 days',
        ),
        MockMedicine(
          name: 'Cetirizine 10mg',
          dosage: '1 tablet',
          frequency: 'Once at night',
          duration: '5 days',
        ),
        MockMedicine(
          name: 'Vitamin C 500mg',
          dosage: '1 tablet',
          frequency: 'Once daily',
          duration: '7 days',
        ),
      ],
    ),
    MockPrescription(
      id: 'rx_002',
      doctorName: 'Dr. Priya Kapoor',
      date: '28 Apr 2026',
      diagnosis: 'Essential Hypertension',
      followUpDate: '28 May 2026',
      medicines: [
        MockMedicine(
          name: 'Amlodipine 5mg',
          dosage: '1 tablet',
          frequency: 'Once daily morning',
          duration: '30 days',
        ),
        MockMedicine(
          name: 'Telmisartan 40mg',
          dosage: '1 tablet',
          frequency: 'Once daily',
          duration: '30 days',
        ),
      ],
    ),
    MockPrescription(
      id: 'rx_003',
      doctorName: 'Dr. Arjun Mehta',
      date: '05 Mar 2026',
      diagnosis: 'Acute Gastroenteritis',
      medicines: [
        MockMedicine(
          name: 'ORS Sachets',
          dosage: '1 sachet in 200ml water',
          frequency: 'After every loose motion',
          duration: '3 days',
        ),
        MockMedicine(
          name: 'Ondansetron 4mg',
          dosage: '1 tablet',
          frequency: 'Thrice daily',
          duration: '3 days',
        ),
      ],
    ),
  ];

  static const patient = MockPatient(
    id: 'pat_001',
    name: 'Riya Sharma',
    phone: '9123456789',
    age: '28',
    gender: 'Female',
    prescriptions: prescriptions,
  );

  static const familyMembers = [
    {'name': 'Riya Sharma', 'relation': 'Self', 'age': '28', 'gender': 'Female', 'active': true},
    {'name': 'Rakesh Sharma', 'relation': 'Father', 'age': '58', 'gender': 'Male', 'active': false},
    {'name': 'Sunanda Sharma', 'relation': 'Mother', 'age': '54', 'gender': 'Female', 'active': false},
    {'name': 'Aryan Sharma', 'relation': 'Brother', 'age': '22', 'gender': 'Male', 'active': false},
  ];

  static const medicines = [
    'Paracetamol 500mg', 'Paracetamol 650mg',
    'Amoxicillin 500mg', 'Azithromycin 500mg',
    'Cetirizine 10mg', 'Levocetirizine 5mg',
    'Omeprazole 20mg', 'Pantoprazole 40mg',
    'Metformin 500mg', 'Metformin 1000mg',
    'Amlodipine 5mg', 'Amlodipine 10mg',
    'Atorvastatin 10mg', 'Atorvastatin 20mg',
    'Vitamin D3 60000 IU', 'Vitamin C 500mg',
    'Cefixime 200mg', 'Doxycycline 100mg',
    'Ibuprofen 400mg', 'Diclofenac 50mg',
    'Montelukast 10mg', 'Salbutamol Inhaler',
    'Ondansetron 4mg', 'Domperidone 10mg',
  ];

  static const earningsMonthly = [
    MockEarningEntry('Oct', 62000),
    MockEarningEntry('Nov', 71000),
    MockEarningEntry('Dec', 68000),
    MockEarningEntry('Jan', 79000),
    MockEarningEntry('Feb', 84000),
    MockEarningEntry('Mar', 87500),
  ];

  static const earningsBreakdown = [
    {'type': 'Video Consultation', 'count': 48, 'amount': 48000, 'color': 0xFF1D4ED8},
    {'type': 'Audio Consultation', 'count': 32, 'amount': 24000, 'color': 0xFF7C3AED},
    {'type': 'Chat Consultation', 'count': 21, 'amount': 10500, 'color': 0xFF10B981},
    {'type': 'In-Person', 'count': 10, 'amount': 5000, 'color': 0xFFF59E0B},
  ];

  static final chatMessages = [
    MockChatMessage(text: 'Hello Doctor, I have been having a mild fever since last night.', sender: 'patient', time: DateTime.now().subtract(const Duration(minutes: 8))),
    MockChatMessage(text: 'What is your current temperature reading?', sender: 'doctor', time: DateTime.now().subtract(const Duration(minutes: 7))),
    MockChatMessage(text: '100.4°F. I also have a headache and body ache.', sender: 'patient', time: DateTime.now().subtract(const Duration(minutes: 6))),
    MockChatMessage(text: 'Any cold, cough, or sore throat?', sender: 'doctor', time: DateTime.now().subtract(const Duration(minutes: 5))),
    MockChatMessage(text: 'Yes, mild sore throat. No cough yet.', sender: 'patient', time: DateTime.now().subtract(const Duration(minutes: 4))),
    MockChatMessage(text: 'Sounds like viral fever. I will prescribe paracetamol and rest. Avoid cold water. Stay hydrated. I\'ll write a prescription now.', sender: 'doctor', time: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  static const weekSlots = {
    'Mon': ['09:00', '09:15', '09:30', '09:45', '10:00', '10:15', '17:00', '17:15', '17:30'],
    'Tue': ['09:00', '09:15', '09:30', '10:00', '10:15', '17:00', '17:30'],
    'Wed': ['09:00', '09:30', '10:00', '10:30', '17:00', '17:15'],
    'Thu': ['09:00', '09:15', '09:30', '09:45', '17:00', '17:15', '17:30', '17:45'],
    'Fri': ['09:00', '09:30', '10:00', '17:00', '17:30'],
    'Sat': ['10:00', '10:30', '11:00', '11:30'],
    'Sun': [],
  };

  static const bookedSlots = {
    'Mon': ['09:00', '09:15', '09:30'],
    'Tue': ['09:00'],
    'Wed': ['09:00'],
    'Thu': ['09:00', '09:15'],
    'Fri': [],
    'Sat': ['10:00'],
    'Sun': [],
  };

  static const aiResponses = [
    'Based on the symptoms described, this appears consistent with viral upper respiratory tract infection. Recommend symptomatic treatment with paracetamol, adequate hydration, and rest.',
    'The HbA1c of 7.8% indicates sub-optimal glycemic control. Consider reviewing current medication dosage or adding a second-line agent. Regular monitoring every 3 months advised.',
    'For drug interaction query: Warfarin + Aspirin — HIGH RISK combination. Both have anticoagulant effects. Monitor INR closely if co-prescription is unavoidable.',
    'Standard dosage for Amoxicillin in adult community-acquired pneumonia: 500mg–1g three times daily for 5–7 days. Adjust for renal impairment.',
    'SOAP Note generated:\nS: Patient reports 3-day history of fever (100.4°F), headache, sore throat, and myalgia.\nO: Pharynx mildly erythematous. No lymphadenopathy.\nA: Viral pharyngitis / URTI.\nP: Paracetamol 650mg BD, Cetirizine 10mg OD, ORS. Follow up in 5 days if no improvement.',
  ];
}

// ─── Demo Mode State ──────────────────────────────────────────────────────────

enum DemoRole { doctor, patient, receptionist }

class DemoModeNotifier extends ValueNotifier<DemoRole> {
  DemoModeNotifier() : super(DemoRole.doctor);
  void setRole(DemoRole r) => value = r;
}

final demoMode = DemoModeNotifier();
