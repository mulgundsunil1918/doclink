import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class PatientHomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const PatientHomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final patient = MockData.patient;
    final apts = MockData.appointments;
    final prescriptions = MockData.prescriptions;
    final upcoming = apts.where((a) => a.status == 'confirmed' || a.status == 'pending').toList();
    final ongoing = apts.where((a) => a.status == 'ongoing').toList();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting 👋',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  '${patient.age} yrs · ${patient.gender}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onNavigate(4),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Text('RS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatPill(
                            label: 'Upcoming',
                            value: '${upcoming.length}',
                            sublabel: 'appointments',
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            label: 'Prescriptions',
                            value: '${prescriptions.length}',
                            sublabel: 'on record',
                            accent: true,
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            label: 'Family',
                            value: '${MockData.familyMembers.length}',
                            sublabel: 'members',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Active consultation banner
                if (ongoing.isNotEmpty) ...[
                  _OngoingBanner(apt: ongoing.first),
                  const SizedBox(height: 16),
                ],

                // Quick actions
                _SectionTitle(title: 'Quick Actions', action: null, onAction: null),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickAction(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan & Book',
                          color: AppColors.primary,
                          onTap: () => context.push('/patient/book')),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: 'Appointments',
                          color: AppColors.accentDark,
                          onTap: () => onNavigate(1)),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.folder_rounded,
                          label: 'Records',
                          color: const Color(0xFF7C3AED),
                          onTap: () => onNavigate(2)),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.people_rounded,
                          label: 'Family',
                          color: const Color(0xFFD97706),
                          onTap: () => onNavigate(3)),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.chat_rounded,
                          label: 'Chat',
                          color: AppColors.patientSecondary,
                          onTap: () => context.push('/patient/chat')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming appointments
                _SectionTitle(
                  title: 'Upcoming Appointments',
                  action: 'See all',
                  onAction: () => onNavigate(1),
                ),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  _EmptyCard(
                    icon: Icons.event_available_rounded,
                    message: 'No upcoming appointments',
                    sub: 'Scan a doctor\'s QR code to book instantly',
                  )
                else
                  ...upcoming.take(2).map((a) => _UpcomingCard(apt: a, onNavigate: onNavigate)),

                const SizedBox(height: 24),

                // Recent prescription
                _SectionTitle(
                  title: 'Recent Prescription',
                  action: 'View all',
                  onAction: () => onNavigate(2),
                ),
                const SizedBox(height: 12),
                if (prescriptions.isEmpty)
                  _EmptyCard(
                    icon: Icons.receipt_long_rounded,
                    message: 'No prescriptions yet',
                    sub: 'Your prescriptions will appear here',
                  )
                else
                  _PrescriptionPreviewCard(rx: prescriptions.first),

                const SizedBox(height: 24),

                // Family section
                _SectionTitle(
                  title: 'Family Profiles',
                  action: 'Manage',
                  onAction: () => onNavigate(3),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MockData.familyMembers
                        .map((m) => _FamilyChip(member: m))
                        .toList(),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label, value, sublabel;
  final bool accent;
  const _StatPill(
      {required this.label,
      required this.value,
      required this.sublabel,
      this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accent ? AppColors.accentLight.withValues(alpha: 0.3) : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                  color: accent ? AppColors.accent : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            Text(sublabel, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _OngoingBanner extends StatelessWidget {
  final MockAppointment apt;
  const _OngoingBanner({required this.apt});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: const [Color(0xFF059669), Color(0xFF10B981)],
      child: Row(
        children: [
          const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consultation in progress',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(apt.patientName.isEmpty ? 'Dr. Arjun Mehta' : 'Dr. Arjun Mehta',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/patient/video-call'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Rejoin',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionTitle({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(action!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final MockAppointment apt;
  final void Function(int) onNavigate;
  const _UpcomingCard({required this.apt, required this.onNavigate});

  static const _typeColors = {
    'video': AppColors.primary,
    'audio': Color(0xFF0891B2),
    'chat': Color(0xFF7C3AED),
    'in_person': Color(0xFFD97706),
  };
  static const _typeIcons = {
    'video': Icons.videocam_rounded,
    'audio': Icons.phone_rounded,
    'chat': Icons.chat_rounded,
    'in_person': Icons.local_hospital_rounded,
  };

  Color get _color => _typeColors[apt.type] ?? AppColors.textMuted;
  IconData get _icon => _typeIcons[apt.type] ?? Icons.medical_services_rounded;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dr. Arjun Mehta',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('Token #${apt.tokenNo} · ${apt.chiefComplaint}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(apt.time,
                    style: TextStyle(
                        color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  if (apt.type == 'video') {
                    context.push('/patient/video-call');
                  } else if (apt.type == 'chat') {
                    context.push('/patient/chat');
                  } else {
                    context.push('/patient/waiting-room');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Join',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionPreviewCard extends StatelessWidget {
  final MockPrescription rx;
  const _PrescriptionPreviewCard({required this.rx});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rx.doctorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(rx.date,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(rx.diagnosis,
                    style: const TextStyle(
                        color: AppColors.accentDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rx.medicines.take(3).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 5, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(m.name,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    Text(m.frequency,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              )),
          if (rx.medicines.length > 3)
            Text('+${rx.medicines.length - 3} more medicines',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          if (rx.followUpDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text('Follow-up: ${rx.followUpDate}',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message, sub;
  const _EmptyCard(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class _FamilyChip extends StatelessWidget {
  final Map<String, Object> member;
  const _FamilyChip({required this.member});

  @override
  Widget build(BuildContext context) {
    final isActive = member['active'] as bool;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isActive
                ? AppColors.primary
                : AppColors.textMuted.withValues(alpha: 0.2),
            child: Text(
              (member['name'] as String)[0],
              style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (member['name'] as String).split(' ').first,
            style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          Text(
            member['relation'] as String,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
