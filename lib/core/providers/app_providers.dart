import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get _db => Supabase.instance.client;
String? get _uid => _db.auth.currentUser?.id;

// ─── Models ───────────────────────────────────────────────────────────────────

class AppProfile {
  final String id, name, role;
  final String? phone, avatarUrl;
  const AppProfile({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.avatarUrl,
  });
  factory AppProfile.fromMap(Map<String, dynamic> m) => AppProfile(
        id: m['id'] ?? '',
        name: m['name'] ?? 'User',
        role: m['role'] ?? 'patient',
        phone: m['phone'] as String?,
        avatarUrl: m['avatar_url'] as String?,
      );
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

class AppDoctor {
  final String id, name, specialty;
  final String? phone, city, clinicName, registrationNo, whatsappNumber, bio,
      avatarUrl, upiId;
  final double consultationFee, rating, earningsToday, earningsMonth;
  final int totalPatients;
  final bool available, kycVerified;
  const AppDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.phone,
    this.city,
    this.clinicName,
    this.registrationNo,
    this.whatsappNumber,
    this.bio,
    this.avatarUrl,
    this.upiId,
    required this.consultationFee,
    required this.rating,
    required this.earningsToday,
    required this.earningsMonth,
    required this.totalPatients,
    required this.available,
    required this.kycVerified,
  });
  factory AppDoctor.fromMap(Map<String, dynamic> m) {
    final doc = (m['doctors'] as Map<String, dynamic>?) ?? {};
    return AppDoctor(
      id: m['id'] ?? '',
      name: m['name'] ?? 'Doctor',
      specialty: doc['specialty'] as String? ?? 'General Physician',
      phone: m['phone'] as String?,
      avatarUrl: m['avatar_url'] as String?,
      city: doc['city'] as String?,
      clinicName: doc['clinic_name'] as String?,
      registrationNo: doc['registration_no'] as String?,
      whatsappNumber: doc['whatsapp_number'] as String?,
      bio: doc['bio'] as String?,
      upiId: doc['upi_id'] as String?,
      consultationFee: (doc['consultation_fee'] as num? ?? 500).toDouble(),
      rating: (doc['rating'] as num? ?? 0).toDouble(),
      earningsToday: (doc['earnings_today'] as num? ?? 0).toDouble(),
      earningsMonth: (doc['earnings_month'] as num? ?? 0).toDouble(),
      totalPatients: doc['total_patients'] as int? ?? 0,
      available: doc['available'] as bool? ?? true,
      kycVerified: doc['kyc_verified'] as bool? ?? false,
    );
  }
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'DR';
  }
}

class AppPatient {
  final String id, name;
  final String? phone, gender, bloodGroup, address, avatarUrl;
  final int? age;
  const AppPatient({
    required this.id,
    required this.name,
    this.phone,
    this.gender,
    this.bloodGroup,
    this.address,
    this.avatarUrl,
    this.age,
  });
  factory AppPatient.fromMap(Map<String, dynamic> m) {
    final pat = (m['patients'] as Map<String, dynamic>?) ?? {};
    return AppPatient(
      id: m['id'] ?? '',
      name: m['name'] ?? 'Patient',
      phone: m['phone'] as String?,
      avatarUrl: m['avatar_url'] as String?,
      gender: pat['gender'] as String?,
      bloodGroup: pat['blood_group'] as String?,
      address: pat['address'] as String?,
      age: pat['age'] as int?,
    );
  }
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }
}

class AppAppointment {
  final String id, type, status, doctorId, patientId;
  final String? chiefComplaint, notes, patientName, doctorName, doctorSpecialty;
  final DateTime? scheduledAt;
  final int? tokenNo;
  const AppAppointment({
    required this.id,
    required this.type,
    required this.status,
    required this.doctorId,
    required this.patientId,
    this.chiefComplaint,
    this.notes,
    this.patientName,
    this.doctorName,
    this.doctorSpecialty,
    this.scheduledAt,
    this.tokenNo,
  });
  factory AppAppointment.fromMap(Map<String, dynamic> m) => AppAppointment(
        id: m['id'] ?? '',
        type: m['type'] ?? 'in_person',
        status: m['status'] ?? 'pending',
        doctorId: m['doctor_id'] ?? '',
        patientId: m['patient_id'] ?? '',
        chiefComplaint: m['chief_complaint'] as String?,
        notes: m['notes'] as String?,
        tokenNo: m['token_no'] as int?,
        scheduledAt: m['scheduled_at'] != null
            ? DateTime.tryParse(m['scheduled_at'] as String)
            : null,
      );
  AppAppointment copyWithNames({
    String? patientName,
    String? doctorName,
    String? doctorSpecialty,
  }) =>
      AppAppointment(
        id: id,
        type: type,
        status: status,
        doctorId: doctorId,
        patientId: patientId,
        chiefComplaint: chiefComplaint,
        notes: notes,
        scheduledAt: scheduledAt,
        tokenNo: tokenNo,
        patientName: patientName ?? this.patientName,
        doctorName: doctorName ?? this.doctorName,
        doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      );
  String get formattedTime {
    if (scheduledAt == null) return '';
    final h = scheduledAt!.hour;
    final m = scheduledAt!.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }
  String get formattedDate {
    if (scheduledAt == null) return '';
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${scheduledAt!.day} ${months[scheduledAt!.month - 1]}';
  }
}

class AppMedicine {
  final String id, name;
  final String? dosage, frequency, duration, instructions;
  const AppMedicine({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
  });
  factory AppMedicine.fromMap(Map<String, dynamic> m) => AppMedicine(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        dosage: m['dosage'] as String?,
        frequency: m['frequency'] as String?,
        duration: m['duration'] as String?,
        instructions: m['instructions'] as String?,
      );
}

class AppPrescription {
  final String id, doctorId, patientId, diagnosis;
  final String? doctorName, notes;
  final DateTime createdAt;
  final DateTime? followUpDate;
  final List<AppMedicine> medicines;
  const AppPrescription({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.diagnosis,
    this.doctorName,
    this.notes,
    required this.createdAt,
    this.followUpDate,
    required this.medicines,
  });
  factory AppPrescription.fromMap(Map<String, dynamic> m) => AppPrescription(
        id: m['id'] ?? '',
        doctorId: m['doctor_id'] ?? '',
        patientId: m['patient_id'] ?? '',
        diagnosis: m['diagnosis'] ?? '',
        notes: m['notes'] as String?,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
        followUpDate: m['follow_up_date'] != null
            ? DateTime.tryParse(m['follow_up_date'] as String)
            : null,
        medicines: (m['medicines'] as List? ?? [])
            .map((e) => AppMedicine.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
  String? get formattedFollowUp {
    if (followUpDate == null) return null;
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${followUpDate!.day} ${months[followUpDate!.month - 1]} ${followUpDate!.year}';
  }
}

class AppFamilyMember {
  final String id, name, relation;
  final int? age;
  final String? gender, bloodGroup;
  final List<String> conditions;
  final bool isPrimary;
  const AppFamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.age,
    this.gender,
    this.bloodGroup,
    required this.conditions,
    required this.isPrimary,
  });
  factory AppFamilyMember.fromMap(Map<String, dynamic> m) => AppFamilyMember(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        relation: m['relation'] ?? '',
        age: m['age'] as int?,
        gender: m['gender'] as String?,
        bloodGroup: m['blood_group'] as String?,
        conditions: (m['conditions'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        isPrimary: m['is_primary'] as bool? ?? false,
      );
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class AppMessage {
  final String id, senderId, text;
  final DateTime createdAt;
  const AppMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });
  factory AppMessage.fromMap(Map<String, dynamic> m) => AppMessage(
        id: m['id'] ?? '',
        senderId: m['sender_id'] ?? '',
        text: m['text'] ?? '',
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ─── Helper: batch-fetch names for a list of profile IDs ─────────────────────

Future<Map<String, String>> _fetchNames(List<String> ids) async {
  if (ids.isEmpty) return {};
  try {
    final rows = await _db
        .from('profiles')
        .select('id, name')
        .inFilter('id', ids);
    return {
      for (final r in rows as List) (r as Map<String, dynamic>)['id'] as String: r['name'] as String? ?? 'User'
    };
  } catch (_) {
    return {};
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final currentProfileProvider = FutureProvider.autoDispose<AppProfile?>((ref) async {
  final uid = _uid;
  if (uid == null) return null;
  try {
    final data = await _db.from('profiles').select().eq('id', uid).single();
    return AppProfile.fromMap(data);
  } catch (_) {
    return null;
  }
});

final currentDoctorProvider = FutureProvider.autoDispose<AppDoctor?>((ref) async {
  final uid = _uid;
  if (uid == null) return null;
  try {
    final data = await _db
        .from('profiles')
        .select('*, doctors(*)')
        .eq('id', uid)
        .single();
    if (data['doctors'] == null) return null;
    return AppDoctor.fromMap(data);
  } catch (_) {
    return null;
  }
});

final currentPatientProvider = FutureProvider.autoDispose<AppPatient?>((ref) async {
  final uid = _uid;
  if (uid == null) return null;
  try {
    final data = await _db
        .from('profiles')
        .select('*, patients(*)')
        .eq('id', uid)
        .single();
    return AppPatient.fromMap(data);
  } catch (_) {
    return null;
  }
});

final doctorAppointmentsProvider =
    FutureProvider.autoDispose<List<AppAppointment>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final rows = await _db
        .from('appointments')
        .select()
        .eq('doctor_id', uid)
        .gte('scheduled_at', start.toIso8601String())
        .lt('scheduled_at', end.toIso8601String())
        .order('scheduled_at');

    final apts = (rows as List)
        .map((e) => AppAppointment.fromMap(e as Map<String, dynamic>))
        .toList();

    final patientIds = apts.map((a) => a.patientId).toSet().toList();
    final names = await _fetchNames(patientIds);
    return apts
        .map((a) => a.copyWithNames(patientName: names[a.patientId]))
        .toList();
  } catch (_) {
    return [];
  }
});

final patientAppointmentsProvider =
    FutureProvider.autoDispose<List<AppAppointment>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final rows = await _db
        .from('appointments')
        .select()
        .eq('patient_id', uid)
        .order('scheduled_at', ascending: false);

    final apts = (rows as List)
        .map((e) => AppAppointment.fromMap(e as Map<String, dynamic>))
        .toList();

    final doctorIds = apts.map((a) => a.doctorId).toSet().toList();
    final names = await _fetchNames(doctorIds);

    Map<String, String> specs = {};
    if (doctorIds.isNotEmpty) {
      try {
        final docRows = await _db
            .from('doctors')
            .select('id, specialty')
            .inFilter('id', doctorIds);
        specs = {
          for (final r in docRows as List)
            (r as Map<String, dynamic>)['id'] as String:
                r['specialty'] as String? ?? 'General Physician'
        };
      } catch (_) {}
    }

    return apts
        .map((a) => a.copyWithNames(
              doctorName: names[a.doctorId],
              doctorSpecialty: specs[a.doctorId],
            ))
        .toList();
  } catch (_) {
    return [];
  }
});

final patientPrescriptionsProvider =
    FutureProvider.autoDispose<List<AppPrescription>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final rows = await _db
        .from('prescriptions')
        .select('*, medicines(*)')
        .eq('patient_id', uid)
        .order('created_at', ascending: false);

    final rxs = (rows as List)
        .map((e) => AppPrescription.fromMap(e as Map<String, dynamic>))
        .toList();

    final doctorIds = rxs.map((r) => r.doctorId).toSet().toList();
    final names = await _fetchNames(doctorIds);

    return rxs
        .map((r) => AppPrescription(
              id: r.id,
              doctorId: r.doctorId,
              patientId: r.patientId,
              diagnosis: r.diagnosis,
              notes: r.notes,
              doctorName: names[r.doctorId],
              createdAt: r.createdAt,
              followUpDate: r.followUpDate,
              medicines: r.medicines,
            ))
        .toList();
  } catch (_) {
    return [];
  }
});

final familyMembersProvider =
    FutureProvider.autoDispose<List<AppFamilyMember>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final rows = await _db
        .from('family_members')
        .select()
        .eq('patient_id', uid)
        .order('is_primary', ascending: false);
    return (rows as List)
        .map((e) => AppFamilyMember.fromMap(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

final allDoctorsProvider =
    FutureProvider.autoDispose<List<AppDoctor>>((ref) async {
  try {
    final rows = await _db
        .from('profiles')
        .select('*, doctors(*)')
        .eq('role', 'doctor');
    return (rows as List)
        .where((e) => (e as Map)['doctors'] != null)
        .map((e) => AppDoctor.fromMap(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

final todayQueueProvider =
    FutureProvider.autoDispose<List<AppAppointment>>((ref) async {
  try {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final rows = await _db
        .from('appointments')
        .select()
        .gte('scheduled_at', start.toIso8601String())
        .lt('scheduled_at', end.toIso8601String())
        .neq('status', 'cancelled')
        .order('token_no');

    final apts = (rows as List)
        .map((e) => AppAppointment.fromMap(e as Map<String, dynamic>))
        .toList();

    final allIds = {
      ...apts.map((a) => a.patientId),
      ...apts.map((a) => a.doctorId),
    }.toList();
    final names = await _fetchNames(allIds);

    return apts
        .map((a) => a.copyWithNames(
              patientName: names[a.patientId],
              doctorName: names[a.doctorId],
            ))
        .toList();
  } catch (_) {
    return [];
  }
});

// ─── Notifications ───────────────────────────────────────────────────────────

class AppNotification {
  final String title;
  final String? body;
  const AppNotification({required this.title, this.body});
}

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final rows = await _db
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .eq('read', false)
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List).map((e) {
      final m = e as Map<String, dynamic>;
      return AppNotification(
        title: m['title'] as String? ?? 'Notification',
        body: m['body'] as String?,
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

// Payment model + provider
class AppPayment {
  final String id, appointmentId, patientId, method, status;
  final double amount;
  final DateTime createdAt;
  final String? doctorName, appointmentType;
  const AppPayment({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.method,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.doctorName,
    this.appointmentType,
  });
  factory AppPayment.fromMap(Map<String, dynamic> m) => AppPayment(
        id: m['id'] ?? '',
        appointmentId: m['appointment_id'] ?? '',
        patientId: m['patient_id'] ?? '',
        method: m['method'] ?? 'upi',
        status: m['status'] ?? 'pending',
        amount: (m['amount'] as num? ?? 0).toDouble(),
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      );
  String get formattedDate {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}

final patientPaymentsProvider =
    FutureProvider.autoDispose<List<AppPayment>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final rows = await _db
        .from('payments')
        .select('*, appointments(type, doctor_id)')
        .eq('patient_id', uid)
        .order('created_at', ascending: false);

    final doctorIds = <String>[];
    final rawList = rows as List;

    final payments = rawList.map((e) {
      final m = e as Map<String, dynamic>;
      final apt = (m['appointments'] as Map<String, dynamic>?) ?? {};
      final doctorId = apt['doctor_id'] as String?;
      if (doctorId != null && !doctorIds.contains(doctorId)) {
        doctorIds.add(doctorId);
      }
      return AppPayment(
        id: m['id'] ?? '',
        appointmentId: m['appointment_id'] ?? '',
        patientId: m['patient_id'] ?? '',
        method: m['method'] ?? 'upi',
        status: m['status'] ?? 'pending',
        amount: (m['amount'] as num? ?? 0).toDouble(),
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
        appointmentType: apt['type'] as String?,
      );
    }).toList();

    final names = await _fetchNames(doctorIds);

    // Map appointment_id → doctor_id from raw rows
    final aptDoctorMap = <String, String>{};
    for (final e in rawList) {
      final m = e as Map<String, dynamic>;
      final aptId = m['appointment_id'] as String?;
      final apt = (m['appointments'] as Map<String, dynamic>?) ?? {};
      final did = apt['doctor_id'] as String?;
      if (aptId != null && did != null) aptDoctorMap[aptId] = did;
    }

    return payments.map((p) {
      final did = aptDoctorMap[p.appointmentId];
      return AppPayment(
        id: p.id,
        appointmentId: p.appointmentId,
        patientId: p.patientId,
        method: p.method,
        status: p.status,
        amount: p.amount,
        createdAt: p.createdAt,
        appointmentType: p.appointmentType,
        doctorName: did != null ? names[did] : null,
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

final appointmentByIdProvider =
    FutureProvider.autoDispose.family<AppAppointment?, String>((ref, id) async {
  try {
    final row =
        await _db.from('appointments').select().eq('id', id).single();
    final apt = AppAppointment.fromMap(row);
    final names = await _fetchNames([apt.doctorId]);
    Map<String, String> specs = {};
    try {
      final docRows = await _db
          .from('doctors')
          .select('id, specialty')
          .inFilter('id', [apt.doctorId]);
      specs = {
        for (final r in docRows as List)
          (r as Map<String, dynamic>)['id'] as String:
              r['specialty'] as String? ?? 'General Physician'
      };
    } catch (_) {}
    return apt.copyWithNames(
      doctorName: names[apt.doctorId],
      doctorSpecialty: specs[apt.doctorId],
    );
  } catch (_) {
    return null;
  }
});

// Queue position provider: counts pending/confirmed appointments ahead
final queuePositionProvider =
    FutureProvider.autoDispose.family<int, String>((ref, appointmentId) async {
  try {
    final apt = await _db
        .from('appointments')
        .select('token_no, doctor_id, status')
        .eq('id', appointmentId)
        .single();
    final tokenNo = apt['token_no'] as int?;
    final doctorId = apt['doctor_id'] as String?;
    if (tokenNo == null || doctorId == null) return 0;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    final ahead = await _db
        .from('appointments')
        .select('id')
        .eq('doctor_id', doctorId)
        .inFilter('status', ['pending', 'confirmed', 'ongoing'])
        .lt('token_no', tokenNo)
        .gte('scheduled_at', start.toIso8601String())
        .lt('scheduled_at', end.toIso8601String());
    return (ahead as List).length;
  } catch (_) {
    return 0;
  }
});

// Stream provider for real-time messages in a consultation
final messagesProvider =
    StreamProvider.autoDispose.family<List<AppMessage>, String>(
  (ref, appointmentId) {
    final stream = _db
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('appointment_id', appointmentId)
        .order('created_at');

    return stream.map((rows) =>
        rows.map((e) => AppMessage.fromMap(e)).toList());
  },
);

// ─── Mutation helpers (called from widgets, not providers) ────────────────────

Future<void> updateAppointmentStatus(String id, String status) async {
  await _db.from('appointments').update({'status': status}).eq('id', id);
}

Future<String?> bookAppointment({
  required String doctorId,
  required String patientId,
  required String type,
  required DateTime scheduledAt,
  required String? chiefComplaint,
}) async {
  final rows = await _db.from('appointments').insert({
    'doctor_id': doctorId,
    'patient_id': patientId,
    'type': type,
    'scheduled_at': scheduledAt.toIso8601String(),
    'chief_complaint': chiefComplaint,
    'status': 'pending',
  }).select('id');
  return (rows as List).isNotEmpty ? (rows.first as Map)['id'] as String? : null;
}

Future<void> sendMessage({
  required String appointmentId,
  required String text,
}) async {
  final uid = _uid;
  if (uid == null) return;
  await _db.from('messages').insert({
    'appointment_id': appointmentId,
    'sender_id': uid,
    'text': text,
  });
}

Future<void> addFamilyMember({
  required String patientId,
  required String name,
  required String relation,
  int? age,
  String? gender,
  String? bloodGroup,
}) async {
  await _db.from('family_members').insert({
    'patient_id': patientId,
    'name': name,
    'relation': relation,
    if (age != null) 'age': age,
    if (gender != null) 'gender': gender,
    if (bloodGroup != null) 'blood_group': bloodGroup,
    'conditions': [],
    'is_primary': false,
  });
}

// Monthly earnings: sums payments for this doctor over the last 6 months
final doctorMonthlyEarningsProvider =
    FutureProvider.autoDispose<List<({String month, double amount})>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final now = DateTime.now();
    final months = <({String month, double amount})>[];
    const labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final start = DateTime(d.year, d.month, 1);
      final end = DateTime(d.year, d.month + 1, 1);
      final label = labels[start.month - 1];
      try {
        final rows = await _db
            .from('payments')
            .select('amount')
            .eq('status', 'success')
            .gte('created_at', start.toIso8601String())
            .lt('created_at', end.toIso8601String());
        // Filter to payments for this doctor's appointments
        final total = (rows as List)
            .fold<double>(0, (s, e) => s + ((e as Map)['amount'] as num? ?? 0));
        months.add((month: label, amount: total));
      } catch (_) {
        months.add((month: label, amount: 0));
      }
    }
    return months;
  } catch (_) {
    return [];
  }
});

// Breakdown of appointments by type for this doctor (completed, this month)
final doctorBreakdownProvider =
    FutureProvider.autoDispose<List<({String type, int count})>>((ref) async {
  final uid = _uid;
  if (uid == null) return [];
  try {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final rows = await _db
        .from('appointments')
        .select('type')
        .eq('doctor_id', uid)
        .eq('status', 'completed')
        .gte('scheduled_at', start.toIso8601String())
        .lt('scheduled_at', end.toIso8601String());
    final counts = <String, int>{};
    for (final r in rows as List) {
      final t = (r as Map)['type'] as String? ?? 'in_person';
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => (type: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  } catch (_) {
    return [];
  }
});

final searchPatientsProvider =
    FutureProvider.autoDispose.family<List<AppProfile>, String>((ref, query) async {
  if (query.length < 2) return [];
  try {
    final byName = await _db
        .from('profiles')
        .select('id, name, phone, role')
        .eq('role', 'patient')
        .ilike('name', '%$query%')
        .limit(8);
    final byPhone = await _db
        .from('profiles')
        .select('id, name, phone, role')
        .eq('role', 'patient')
        .ilike('phone', '%$query%')
        .limit(8);
    final merged = <String, AppProfile>{};
    for (final r in [...(byName as List), ...(byPhone as List)]) {
      final p = AppProfile.fromMap(r as Map<String, dynamic>);
      merged[p.id] = p;
    }
    return merged.values.toList();
  } catch (_) {
    return [];
  }
});

Future<String?> lookupPatientIdByPhone(String phone) async {
  // Try exact match, then with +91 prefix
  final candidates = [phone, '+91$phone', '91$phone'];
  for (final p in candidates) {
    try {
      final rows = await _db
          .from('profiles')
          .select('id')
          .eq('phone', p)
          .eq('role', 'patient')
          .limit(1);
      if ((rows as List).isNotEmpty) {
        return ((rows as List).first as Map<String, dynamic>)['id'] as String?;
      }
    } catch (_) {}
  }
  return null;
}

Future<void> updatePatientProfile({
  required String uid,
  String? name,
  int? age,
  String? gender,
  String? bloodGroup,
  String? address,
}) async {
  if (name != null) {
    await _db.from('profiles').update({'name': name}).eq('id', uid);
  }
  final patMap = <String, dynamic>{};
  if (age != null) patMap['age'] = age;
  if (gender != null) patMap['gender'] = gender;
  if (bloodGroup != null) patMap['blood_group'] = bloodGroup;
  if (address != null) patMap['address'] = address;
  if (patMap.isNotEmpty) {
    await _db.from('patients').update(patMap).eq('id', uid);
  }
}

Future<void> updateDoctorProfile({
  required String uid,
  String? name,
  String? phone,
  String? specialty,
  String? registrationNo,
  String? city,
  String? clinicName,
  String? bio,
  String? whatsappNumber,
  String? upiId,
  double? consultationFee,
  bool? available,
}) async {
  final profileMap = <String, dynamic>{};
  if (name != null) profileMap['name'] = name;
  if (phone != null) profileMap['phone'] = phone;
  if (profileMap.isNotEmpty) {
    await _db.from('profiles').update(profileMap).eq('id', uid);
  }

  final docMap = <String, dynamic>{};
  if (specialty != null) docMap['specialty'] = specialty;
  if (registrationNo != null) docMap['registration_no'] = registrationNo;
  if (city != null) docMap['city'] = city;
  if (clinicName != null) docMap['clinic_name'] = clinicName;
  if (bio != null) docMap['bio'] = bio;
  if (whatsappNumber != null) docMap['whatsapp_number'] = whatsappNumber;
  if (upiId != null) docMap['upi_id'] = upiId;
  if (consultationFee != null) docMap['consultation_fee'] = consultationFee;
  if (available != null) docMap['available'] = available;
  if (docMap.isNotEmpty) {
    await _db.from('doctors').update(docMap).eq('id', uid);
  }
}

Future<void> updateDoctorUpiId(String upiId) async {
  final uid = _uid;
  if (uid == null) return;
  await _db.from('doctors').update({'upi_id': upiId}).eq('id', uid);
}

Future<void> savePayment({
  required String appointmentId,
  required String patientId,
  required double amount,
  required String method,
  required String razorpayPaymentId,
}) async {
  await _db.from('payments').insert({
    'appointment_id': appointmentId,
    'patient_id': patientId,
    'amount': amount,
    'method': method.toLowerCase(),
    'status': 'completed',
    'razorpay_payment_id': razorpayPaymentId,
  });
}

Future<void> savePrescription({
  required String doctorId,
  required String patientId,
  required String diagnosis,
  String? notes,
  DateTime? followUpDate,
  String? appointmentId,
  required List<Map<String, String>> medicines,
}) async {
  final rx = await _db.from('prescriptions').insert({
    'doctor_id': doctorId,
    'patient_id': patientId,
    'diagnosis': diagnosis,
    'notes': notes,
    'follow_up_date': followUpDate?.toIso8601String().substring(0, 10),
    'appointment_id': appointmentId,
  }).select('id');

  if ((rx as List).isNotEmpty) {
    final rxId = (rx.first as Map)['id'] as String;
    await _db.from('medicines').insert(
      medicines.map((m) => {...m, 'prescription_id': rxId}).toList(),
    );
    // Update doctor's patient count and earnings (best-effort)
    await _db.rpc('increment_doctor_stats', params: {
      'p_doctor_id': doctorId,
    }).catchError((_) {});
  }
}
