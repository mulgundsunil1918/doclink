import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});
  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen>
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
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.patientPrimary),
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
          _VisitsTab(filter: _filter, onFilterChange: (f) => setState(() => _filter = f)),
          const _ReportsTab(),
          const _PrescriptionsTab(),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 20),
            _UploadOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              color: AppColors.patientPrimary,
              onTap: () {
                Navigator.pop(context);
                _showUploadSuccess(context);
              },
            ),
            const SizedBox(height: 12),
            _UploadOption(
              icon: Icons.folder_open_rounded,
              label: 'Choose from Files',
              color: AppColors.patientSecondary,
              onTap: () {
                Navigator.pop(context);
                _showUploadSuccess(context);
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

  void _showUploadSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report uploaded successfully'),
        backgroundColor: AppColors.patientPrimary,
      ),
    );
  }
}

class _VisitsTab extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilterChange;
  const _VisitsTab({required this.filter, required this.onFilterChange});

  static const _filters = ['All', 'Video', 'Audio', 'In-Person'];

  @override
  Widget build(BuildContext context) {
    final visits = MockData.appointments;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          selectedColor: AppColors.patientPrimary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: filter == f ? AppColors.patientPrimary : AppColors.slate500,
                            fontWeight: filter == f ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: filter == f ? AppColors.patientPrimary : AppColors.slate200,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: visits.length,
            itemBuilder: (ctx, i) => _VisitCard(visit: visits[i]),
          ),
        ),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  final MockAppointment visit;
  const _VisitCard({required this.visit});

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
                backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, color: AppColors.patientPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. Arjun Mehta',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    Text('General Physician • ${visit.time}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              _TypeChip(type: visit.type),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(visit.time,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_rounded, size: 14),
                label: const Text('View Rx', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.patientPrimary,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                label: const Text('Notes', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate500,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  Color get _color {
    switch (type.toLowerCase()) {
      case 'video': return AppColors.patientPrimary;
      case 'audio': return AppColors.patientSecondary;
      case 'chat': return const Color(0xFF8B5CF6);
      default: return AppColors.slate500;
    }
  }

  IconData get _icon {
    switch (type.toLowerCase()) {
      case 'video': return Icons.videocam_rounded;
      case 'audio': return Icons.phone_rounded;
      case 'chat': return Icons.chat_rounded;
      default: return Icons.local_hospital_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(type, style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  static const _reports = [
    (name: 'CBC Blood Test', date: '12 Mar 2025', type: 'Lab', size: '2.4 MB'),
    (name: 'Chest X-Ray', date: '5 Feb 2025', type: 'Imaging', size: '8.1 MB'),
    (name: 'Lipid Profile', date: '20 Jan 2025', type: 'Lab', size: '1.2 MB'),
    (name: 'ECG Report', date: '3 Jan 2025', type: 'Cardiology', size: '0.8 MB'),
    (name: 'Thyroid Panel', date: '15 Dec 2024', type: 'Lab', size: '1.5 MB'),
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
                            fontWeight: FontWeight.w600, color: AppColors.slate800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${r.date} • ${r.type} • ${r.size}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, color: AppColors.patientPrimary),
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
  const _PrescriptionsTab();

  @override
  Widget build(BuildContext context) {
    final prescriptions = MockData.prescriptions;
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
                    child: Text('Dr. Arjun Mehta',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: AppColors.slate800)),
                  ),
                  Text(rx.date,
                      style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              ...rx.medicines.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.slate300),
                        const SizedBox(width: 8),
                        Text(m.name,
                            style: const TextStyle(color: AppColors.slate700, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text(m.dosage,
                            style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
                      ],
                    ),
                  )),
              if (rx.medicines.length > 3)
                Text('+${rx.medicines.length - 3} more',
                    style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, size: 14),
                    label: const Text('Share', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.slate500),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Download PDF', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.patientPrimary),
                  ),
                ],
              ),
            ],
          ),
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
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
