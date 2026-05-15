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
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$greeting 👋',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.person_rounded,
                                        color: Colors.white54, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${patient.age} yrs  ·  ${patient.gender}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onNavigate(4),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 1.5),
                              ),
                              child: const Center(
                                child: Text('RS',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white70, size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // ── 3 compact metric tiles ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        children: [
                          _MetricTile(
                            value: '${upcoming.length}',
                            label: 'Upcoming',
                            sub: 'appointments',
                            icon: Icons.event_rounded,
                            iconColor: Colors.white,
                          ),
                          _MetricDivider(),
                          _MetricTile(
                            value: '${prescriptions.length}',
                            label: 'Prescriptions',
                            sub: 'on record',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.accent,
                            valueColor: AppColors.accent,
                          ),
                          _MetricDivider(),
                          _MetricTile(
                            value: '${MockData.familyMembers.length}',
                            label: 'Family',
                            sub: 'members',
                            icon: Icons.people_rounded,
                            iconColor: Colors.amber,
                            valueColor: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // ── Status chips strip ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _StatusChip(
                      value: '${upcoming.length}',
                      label: 'Upcoming',
                      color: AppColors.primary,
                      icon: Icons.calendar_today_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '${ongoing.length}',
                      label: 'Ongoing',
                      color: AppColors.accent,
                      icon: Icons.play_circle_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '${prescriptions.length}',
                      label: 'Records',
                      color: const Color(0xFF7C3AED),
                      icon: Icons.folder_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '${MockData.familyMembers.length}',
                      label: 'Family',
                      color: const Color(0xFFD97706),
                      icon: Icons.people_rounded),
                ],
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Active consultation banner
                if (ongoing.isNotEmpty) ...[
                  _OngoingBanner(apt: ongoing.first),
                  const SizedBox(height: 16),
                ],

                // Quick actions
                _SectionLabel('Quick Actions'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionBtn(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan & Book',
                        color: AppColors.primary,
                        onTap: () => context.push('/patient/book')),
                    _ActionBtn(
                        icon: Icons.calendar_month_rounded,
                        label: 'Appointments',
                        color: AppColors.accentDark,
                        onTap: () => onNavigate(1)),
                    _ActionBtn(
                        icon: Icons.folder_rounded,
                        label: 'Records',
                        color: const Color(0xFF7C3AED),
                        onTap: () => onNavigate(2)),
                    _ActionBtn(
                        icon: Icons.people_rounded,
                        label: 'Family',
                        color: const Color(0xFFD97706),
                        onTap: () => onNavigate(3)),
                    _ActionBtn(
                        icon: Icons.chat_rounded,
                        label: 'Chat',
                        color: AppColors.patientSecondary,
                        onTap: () => context.push('/patient/chat')),
                  ],
                ),

                const SizedBox(height: 24),

                // Upcoming appointments
                Row(
                  children: [
                    _SectionLabel('Upcoming Appointments'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => onNavigate(1),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('See all',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (upcoming.isEmpty)
                  _EmptyCard(
                    icon: Icons.event_available_rounded,
                    message: 'No upcoming appointments',
                    sub: 'Scan a doctor\'s QR code to book instantly',
                  )
                else
                  ...upcoming.take(2).map((a) => _UpcomingCard(apt: a)),

                const SizedBox(height: 24),

                // Recent prescription
                Row(
                  children: [
                    _SectionLabel('Recent Prescription'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => onNavigate(2),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View all',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (prescriptions.isEmpty)
                  _EmptyCard(
                    icon: Icons.receipt_long_rounded,
                    message: 'No prescriptions yet',
                    sub: 'Your prescriptions will appear here',
                  )
                else
                  _PrescriptionCard(rx: prescriptions.first),

                const SizedBox(height: 24),

                // Family section
                Row(
                  children: [
                    _SectionLabel('Family Profiles'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => onNavigate(3),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Manage',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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

// ── Header widgets ─────────────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final String value, label, sub;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  const _MetricTile({
    required this.value,
    required this.label,
    required this.sub,
    required this.icon,
    required this.iconColor,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 13),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            Text(sub,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

// ── Status strip widgets ───────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatusChip(
      {required this.value,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Body widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
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

class _UpcomingCard extends StatelessWidget {
  final MockAppointment apt;
  const _UpcomingCard({required this.apt});

  static const _typeColors = {
    'video': Color(0xFF2563EB),
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
  static const _statusColors = {
    'confirmed': Color(0xFF2563EB),
    'pending': Color(0xFFF59E0B),
    'ongoing': Color(0xFF059669),
  };

  Color get _typeColor => _typeColors[apt.type] ?? AppColors.textMuted;
  IconData get _typeIcon => _typeIcons[apt.type] ?? Icons.medical_services_rounded;
  Color get _statusColor => _statusColors[apt.status] ?? AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _typeColor, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081E293B),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('#${apt.tokenNo}',
                    style: TextStyle(
                        color: _typeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Dr. Arjun Mehta',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(width: 6),
                      Icon(_typeIcon, size: 12, color: _typeColor),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(apt.chiefComplaint,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(apt.time,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final MockPrescription rx;
  const _PrescriptionCard({required this.rx});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: Color(0xFF059669), width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081E293B),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: Color(0xFF059669), size: 18),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
