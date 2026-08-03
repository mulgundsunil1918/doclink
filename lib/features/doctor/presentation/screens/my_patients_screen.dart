import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/dl_card.dart';
import 'prescription_writer_screen.dart';

// Provider: unique patients from this doctor's prescriptions
final myPatientsProvider =
    FutureProvider.autoDispose<List<AppPatientSummary>>((ref) async {
  final db = Supabase.instance.client;
  final uid = db.auth.currentUser?.id;
  if (uid == null) return [];
  try {
    final rows = await db
        .from('prescriptions')
        .select('id, patient_id, diagnosis, created_at, follow_up_date')
        .eq('doctor_id', uid)
        .order('created_at', ascending: false);

    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final r in rows as List) {
      final pid = r['patient_id'] as String? ?? '';
      if (pid.isNotEmpty && seen.add(pid)) unique.add(r as Map<String, dynamic>);
    }

    // Batch-fetch patient names
    final ids = unique.map((r) => r['patient_id'] as String).toList();
    if (ids.isEmpty) return [];

    final profiles = await db
        .from('profiles')
        .select('id, name, phone, avatar_url')
        .inFilter('id', ids);

    final nameMap = {
      for (final p in profiles as List)
        (p as Map<String, dynamic>)['id'] as String: p,
    };

    return unique.map((r) {
      final pid = r['patient_id'] as String;
      final profile = nameMap[pid] ?? {};
      return AppPatientSummary(
        id: pid,
        name: (profile['name'] as String?) ?? 'Patient',
        phone: profile['phone'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
        lastDiagnosis: r['diagnosis'] as String? ?? '',
        lastVisit:
            DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        followUpDate: r['follow_up_date'] != null
            ? DateTime.tryParse(r['follow_up_date'] as String)
            : null,
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

class AppPatientSummary {
  final String id, name, lastDiagnosis;
  final String? phone, avatarUrl;
  final DateTime lastVisit;
  final DateTime? followUpDate;
  const AppPatientSummary({
    required this.id,
    required this.name,
    required this.lastDiagnosis,
    this.phone,
    this.avatarUrl,
    required this.lastVisit,
    this.followUpDate,
  });
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'P';
}

class MyPatientsScreen extends ConsumerWidget {
  const MyPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(myPatientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('My Patients',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: patientsAsync.when(
        loading: () => const Center(child: DlLoader()),
        error: (_, __) =>
            const Center(child: Text('Could not load patients')),
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 56, color: AppColors.slate300),
                  SizedBox(height: 12),
                  Text('No patients yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate400)),
                  SizedBox(height: 6),
                  Text(
                      'Patients appear here after you write a prescription.',
                      style:
                          TextStyle(color: AppColors.slate400, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (_, i) => _PatientCard(patient: patients[i]),
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final AppPatientSummary patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = patient.lastVisit;
    final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';

    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                AppColors.doctorPrimary.withValues(alpha: 0.12),
            child: Text(
              patient.initials,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.doctorPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.slate900)),
                const SizedBox(height: 2),
                if (patient.lastDiagnosis.isNotEmpty)
                  Text(patient.lastDiagnosis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.slate500, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: AppColors.slate400),
                    const SizedBox(width: 4),
                    Text('Last visit: $dateStr',
                        style: const TextStyle(
                            color: AppColors.slate400, fontSize: 11)),
                    if (patient.followUpDate != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: AppColors.doctorAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Follow-up: ${patient.followUpDate!.day} ${months[patient.followUpDate!.month - 1]}',
                        style: const TextStyle(
                            color: AppColors.doctorAccent, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrescriptionWriterScreen(
                  patientId: patient.id,
                  patientName: patient.name,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.doctorPrimary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: const Text('Write Rx'),
          ),
        ],
      ),
    );
  }
}
