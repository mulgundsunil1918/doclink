import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/prescription_template.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/prescription_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientRecordsScreen extends ConsumerStatefulWidget {
  const PatientRecordsScreen({super.key});
  @override
  ConsumerState<PatientRecordsScreen> createState() =>
      _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends ConsumerState<PatientRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Health Records',
            style: TextStyle(
                color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded,
                color: AppColors.patientPrimary),
            onPressed: () => _showUploadSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.patientPrimary,
          unselectedLabelColor: AppColors.slate400,
          indicatorColor: AppColors.patientPrimary,
          tabs: const [
            Tab(text: 'Visits'),
            Tab(text: 'Reports'),
            Tab(text: 'Prescriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VisitsTab(
              filter: _filter,
              onFilterChange: (f) => setState(() => _filter = f),
              ref: ref),
          const _ReportsTab(),
          _PrescriptionsTab(ref: ref),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Report',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 20),
            _UploadOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              color: AppColors.patientPrimary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report uploaded successfully'),
                      backgroundColor: AppColors.patientPrimary),
                );
              },
            ),
            const SizedBox(height: 12),
            _UploadOption(
              icon: Icons.folder_open_rounded,
              label: 'Choose from Files',
              color: AppColors.patientSecondary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report uploaded successfully'),
                      backgroundColor: AppColors.patientPrimary),
                );
              },
            ),
            const SizedBox(height: 12),
            _UploadOption(
              icon: Icons.share_rounded,
              label: 'Shared with me',
              color: AppColors.slate600,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitsTab extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilterChange;
  final WidgetRef ref;
  const _VisitsTab({
    required this.filter,
    required this.onFilterChange,
    required this.ref,
  });

  static const _filters = ['All', 'Video', 'Audio', 'In-Person'];

  @override
  Widget build(BuildContext context) {
    final aptsAsync = ref.watch(patientAppointmentsProvider);
    return aptsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('Failed to load visits',
              style: TextStyle(color: AppColors.slate400))),
      data: (apts) {
        final past = apts
            .where((a) =>
                a.status == 'completed' || a.status == 'cancelled')
            .where((a) =>
                filter == 'All' ||
                a.type.toLowerCase() ==
                    filter.toLowerCase().replaceAll('-', '_'))
            .toList();

        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: filter == f,
                              onSelected: (_) => onFilterChange(f),
                              selectedColor: AppColors.patientPrimary
                                  .withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: filter == f
                                    ? AppColors.patientPrimary
                                    : AppColors.slate500,
                                fontWeight: filter == f
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: filter == f
                                    ? AppColors.patientPrimary
                                    : AppColors.slate200,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: past.isEmpty
                  ? const Center(
                      child: Text('No past visits',
                          style: TextStyle(
                              color: AppColors.slate400, fontSize: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: past.length,
                      itemBuilder: (ctx, i) =>
                          _VisitCard(visit: past[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  final AppAppointment visit;
  const _VisitCard({required this.visit});

  Color get _typeColor {
    switch (visit.type) {
      case 'video':
        return AppColors.patientPrimary;
      case 'audio':
        return AppColors.patientSecondary;
      case 'chat':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.slate500;
    }
  }

  IconData get _typeIcon {
    switch (visit.type) {
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.phone_rounded;
      case 'chat':
        return Icons.chat_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppColors.patientPrimary.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.patientPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.doctorName != null
                          ? 'Dr. ${visit.doctorName}'
                          : 'Doctor',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800,
                          fontSize: 14),
                    ),
                    Text(
                      '${visit.doctorSpecialty ?? visit.type.replaceAll('_', '-')} · ${visit.formattedTime}',
                      style: const TextStyle(
                          color: AppColors.slate500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, size: 12, color: _typeColor),
                    const SizedBox(width: 4),
                    Text(
                        visit.type
                            .replaceAll('_', '-')
                            .toUpperCase()
                            .substring(0, 1) +
                            visit.type
                                .replaceAll('_', '-')
                                .substring(1),
                        style: TextStyle(
                            color: _typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(visit.formattedDate,
                  style: const TextStyle(
                      color: AppColors.slate500, fontSize: 12)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_rounded, size: 14),
                label: const Text('View Rx',
                    style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.patientPrimary,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  static const _reports = [
    (
      name: 'CBC Blood Test',
      date: '12 Mar 2025',
      type: 'Lab',
      size: '2.4 MB'
    ),
    (
      name: 'Chest X-Ray',
      date: '5 Feb 2025',
      type: 'Imaging',
      size: '8.1 MB'
    ),
    (
      name: 'Lipid Profile',
      date: '20 Jan 2025',
      type: 'Lab',
      size: '1.2 MB'
    ),
    (
      name: 'ECG Report',
      date: '3 Jan 2025',
      type: 'Cardiology',
      size: '0.8 MB'
    ),
    (
      name: 'Thyroid Panel',
      date: '15 Dec 2024',
      type: 'Lab',
      size: '1.5 MB'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _reports.length,
      itemBuilder: (ctx, i) {
        final r = _reports[i];
        return DlCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.patientPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.patientPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${r.date} · ${r.type} · ${r.size}',
                        style: const TextStyle(
                            color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded,
                    color: AppColors.patientPrimary),
                iconSize: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrescriptionsTab extends StatelessWidget {
  final WidgetRef ref;
  const _PrescriptionsTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final rxAsync = ref.watch(patientPrescriptionsProvider);
    return rxAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('Failed to load prescriptions',
              style: TextStyle(color: AppColors.slate400))),
      data: (prescriptions) {
        if (prescriptions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services_rounded,
                    size: 48, color: AppColors.slate300),
                SizedBox(height: 12),
                Text('No prescriptions yet',
                    style: TextStyle(
                        color: AppColors.slate400, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: prescriptions.length,
          itemBuilder: (ctx, i) {
            final rx = prescriptions[i];
            return DlCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services_rounded,
                          color: AppColors.patientPrimary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rx.doctorName != null
                              ? 'Dr. ${rx.doctorName}'
                              : 'Doctor',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800),
                        ),
                      ),
                      Text(rx.formattedDate,
                          style: const TextStyle(
                              color: AppColors.slate400, fontSize: 12)),
                    ],
                  ),
                  if (rx.diagnosis.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(rx.diagnosis,
                        style: const TextStyle(
                            color: AppColors.slate500, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  ...rx.medicines.take(3).map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 6, color: AppColors.slate300),
                            const SizedBox(width: 8),
                            Text(m.name,
                                style: const TextStyle(
                                    color: AppColors.slate700,
                                    fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(m.dosage ?? '',
                                style: const TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 12)),
                          ],
                        ),
                      )),
                  if (rx.medicines.length > 3)
                    Text('+${rx.medicines.length - 3} more',
                        style: const TextStyle(
                            color: AppColors.slate400, fontSize: 12)),
                  if (rx.medicines.isNotEmpty) ...[
                    const Divider(height: 16),
                    _ReminderRow(rx: rx, context: context),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final profile = ref
                              .read(currentProfileProvider)
                              .valueOrNull;
                          try {
                            final svc = PrescriptionPdfService();
                            final bytes = await svc.generate(
                              rx,
                              null,
                              PrescriptionSettings.defaults,
                              patientName: profile?.name ?? '',
                            );
                            await svc.share(
                                bytes,
                                'Rx-${rx.id.substring(0, 8)}.pdf');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text('Error: $e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.share_rounded, size: 14),
                        label: const Text('Share',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.slate500),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final profile = ref
                              .read(currentProfileProvider)
                              .valueOrNull;
                          try {
                            final svc = PrescriptionPdfService();
                            final bytes = await svc.generate(
                              rx,
                              null,
                              PrescriptionSettings.defaults,
                              patientName: profile?.name ?? '',
                            );
                            await svc.share(
                                bytes,
                                'Rx-${rx.id.substring(0, 8)}.pdf');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text('Error: $e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 14),
                        label: const Text('Download PDF',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.patientPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _UploadOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final AppPrescription rx;
  final BuildContext context;
  const _ReminderRow({required this.rx, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        const Icon(Icons.alarm_rounded, size: 14, color: AppColors.patientPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${rx.medicines.length} medicine${rx.medicines.length > 1 ? "s" : ""}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate600),
          ),
        ),
        TextButton(
          onPressed: () => _showReminders(ctx),
          style: TextButton.styleFrom(
              foregroundColor: AppColors.patientPrimary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text('Set Reminder', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  void _showReminders(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medicine Reminders',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Your reminder schedule based on this prescription:',
                style: TextStyle(fontSize: 12, color: AppColors.slate500)),
            const SizedBox(height: 16),
            ...rx.medicines.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.patientPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: AppColors.patientPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          [
                            if (m.dosage != null) m.dosage!,
                            if (m.frequency != null) m.frequency!,
                            if (m.duration != null) m.duration!,
                          ].join(' · '),
                          style: const TextStyle(
                              color: AppColors.slate500, fontSize: 11),
                        ),
                        Text(
                          _reminderTimes(m.frequency),
                          style: const TextStyle(
                              color: AppColors.patientPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Reminders noted — take medicines at the shown times'),
                    backgroundColor: AppColors.patientPrimary,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.alarm_on_rounded, size: 18),
                label: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reminderTimes(String? frequency) {
    if (frequency == null) return 'As directed';
    final f = frequency.toLowerCase();
    if (f.contains('once daily') || f.contains('od')) return '⏰ 8:00 AM';
    if (f.contains('twice') || f.contains('bd')) return '⏰ 8:00 AM  ·  8:00 PM';
    if (f.contains('thrice') || f.contains('tds') || f.contains('three')) {
      return '⏰ 8:00 AM  ·  2:00 PM  ·  8:00 PM';
    }
    if (f.contains('four') || f.contains('qid')) {
      return '⏰ 8AM  ·  12PM  ·  4PM  ·  8PM';
    }
    if (f.contains('night') || f.contains('bedtime') || f.contains('hs')) {
      return '⏰ 10:00 PM';
    }
    if (f.contains('sos') || f.contains('as needed')) return 'When needed';
    return 'As directed';
  }
}
