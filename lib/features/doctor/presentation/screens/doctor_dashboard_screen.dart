import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DoctorDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final doc = MockData.doctor;
    final apts = MockData.appointments;
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    final confirmed = apts.where((a) => a.status == 'confirmed').length;
    final done = apts.where((a) => a.status == 'completed').length;
    final pending = apts.where((a) => a.status == 'pending').length;
    final ongoing = apts.where((a) => a.status == 'ongoing').length;

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
                                Row(
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
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Dr. ${doc.name.split(' ').last}',
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
                                    const Icon(Icons.local_hospital_rounded,
                                        color: Colors.white54, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${doc.specialty}  ·  ${doc.city}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => onNavigate(2),
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
                                    child: Text('AM',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15)),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 1,
                                top: 1,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
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
                            value: '${apts.length}',
                            label: 'Appointments',
                            sub: 'today',
                            icon: Icons.today_rounded,
                            iconColor: Colors.white,
                          ),
                          _MetricDivider(),
                          _MetricTile(
                            value:
                                '₹${(doc.earningsToday / 1000).toStringAsFixed(1)}k',
                            label: 'Earnings',
                            sub: 'today',
                            icon: Icons.currency_rupee_rounded,
                            iconColor: AppColors.accent,
                            valueColor: AppColors.accent,
                          ),
                          _MetricDivider(),
                          _MetricTile(
                            value: '${doc.rating}',
                            label: 'Rating',
                            sub: '${doc.totalPatients} patients',
                            icon: Icons.star_rounded,
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
                      value: '$confirmed',
                      label: 'Confirmed',
                      color: AppColors.primary,
                      icon: Icons.check_circle_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '$ongoing',
                      label: 'Ongoing',
                      color: AppColors.accent,
                      icon: Icons.play_circle_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '$pending',
                      label: 'Pending',
                      color: AppColors.warning,
                      icon: Icons.schedule_rounded),
                  const SizedBox(width: 8),
                  _StatusChip(
                      value: '$done',
                      label: 'Done',
                      color: AppColors.textMuted,
                      icon: Icons.task_alt_rounded),
                ],
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Quick actions
                _SectionLabel('Quick Actions'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionBtn(
                        icon: Icons.video_call_rounded,
                        label: 'Video',
                        color: AppColors.primary,
                        onTap: () => context.go('/doctor/video-call')),
                    _ActionBtn(
                        icon: Icons.edit_note_rounded,
                        label: 'Write Rx',
                        color: AppColors.accentDark,
                        onTap: () => onNavigate(0)),
                    _ActionBtn(
                        icon: Icons.calendar_today_rounded,
                        label: 'Slots',
                        color: AppColors.warning,
                        onTap: () => onNavigate(1)),
                    _ActionBtn(
                        icon: Icons.psychology_rounded,
                        label: 'AI Notes',
                        color: const Color(0xFF7C3AED),
                        onTap: () => onNavigate(4)),
                    _ActionBtn(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Share QR',
                        color: AppColors.primaryDark,
                        onTap: () => onNavigate(2)),
                  ],
                ),

                const SizedBox(height: 24),

                // Today's Queue
                Row(
                  children: [
                    _SectionLabel("Today's Queue"),
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
                ...apts.map((a) => _QueueCard(apt: a)),

                const SizedBox(height: 24),

                // Earnings card
                _EarningsCard(doc: doc),
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

class _QueueCard extends StatelessWidget {
  final MockAppointment apt;
  const _QueueCard({required this.apt});

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
    'ongoing': Color(0xFF059669),
    'completed': Color(0xFF94A3B8),
    'pending': Color(0xFFF59E0B),
  };

  Color get _typeColor => _typeColors[apt.type] ?? AppColors.textMuted;
  IconData get _typeIcon =>
      _typeIcons[apt.type] ?? Icons.medical_services_rounded;
  Color get _statusColor =>
      _statusColors[apt.status] ?? AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    final isActive = apt.status == 'ongoing' || apt.status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _typeColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x081E293B),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            // Token badge
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

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(apt.patientName,
                          style: const TextStyle(
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

            // Right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                if (isActive) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => context.push('/doctor/video-call'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: apt.status == 'ongoing'
                            ? AppColors.accent
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        apt.status == 'ongoing' ? 'Rejoin' : 'Start',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final MockDoctor doc;
  const _EarningsCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF059669), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Month',
                    style:
                        TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '₹${(doc.earningsMonth / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doc.patientsToday} consultations today',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('18% vs last mo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View breakdown',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
