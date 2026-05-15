import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DoctorDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final doc = MockData.doctor;
    final apts = MockData.appointments;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    final confirmed = apts.where((a) => a.status == 'confirmed').length;
    final done      = apts.where((a) => a.status == 'completed').length;
    final pending   = apts.where((a) => a.status == 'pending').length;

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
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dr. ${doc.name.split(' ').last}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  '${doc.specialty} · ${doc.city}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => onNavigate(2),
                                child: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white24,
                                  child: Text('AM',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15)),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primaryDeep, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
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
                      // Quick stat pills
                      Row(
                        children: [
                          _StatPill(
                            label: 'Today',
                            value: '${apts.length}',
                            sublabel: 'appointments',
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            label: 'Earnings',
                            value: '₹${(doc.earningsToday / 1000).toStringAsFixed(1)}k',
                            sublabel: 'today',
                            accent: true,
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            label: 'Rating',
                            value: '${doc.rating}★',
                            sublabel: '${doc.totalPatients} pts',
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

                // Status row
                Row(
                  children: [
                    _MiniStat(label: 'Confirmed', value: '$confirmed', color: AppColors.primary),
                    const SizedBox(width: 10),
                    _MiniStat(label: 'Completed', value: '$done', color: AppColors.accent),
                    const SizedBox(width: 10),
                    _MiniStat(label: 'Pending', value: '$pending', color: AppColors.warning),
                    const SizedBox(width: 10),
                    _MiniStat(label: 'This month', value: '₹${(doc.earningsMonth / 1000).toStringAsFixed(0)}k', color: AppColors.primaryDark),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick actions
                _SectionTitle(title: 'Quick Actions', action: null, onAction: null),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickAction(icon: Icons.video_call_rounded, label: 'Start Video', color: AppColors.primary, onTap: () => context.go('/doctor/video-call')),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.edit_note_rounded, label: 'Write Rx', color: AppColors.accentDark, onTap: () => onNavigate(0)),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.calendar_today_rounded, label: 'Manage Slots', color: AppColors.warning, onTap: () => onNavigate(1)),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.psychology_rounded, label: 'AI Notes', color: const Color(0xFF7C3AED), onTap: () => onNavigate(4)),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.qr_code_2_rounded, label: 'Share QR', color: AppColors.primaryDark, onTap: () => onNavigate(2)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Appointments
                _SectionTitle(
                  title: "Today's Queue",
                  action: 'See all',
                  onAction: () => onNavigate(1),
                ),
                const SizedBox(height: 12),
                ...apts.map((a) => _AppointmentCard(apt: a)),

                const SizedBox(height: 24),
                // Earnings preview
                _EarningsPreview(doc: doc),
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
  const _StatPill({required this.label, required this.value, required this.sublabel, this.accent = false});

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
            Text(value, style: TextStyle(
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

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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
            child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final MockAppointment apt;
  const _AppointmentCard({required this.apt});

  static const _typeColors = {
    'video'    : AppColors.primary,
    'audio'    : Color(0xFF0891B2),
    'chat'     : Color(0xFF7C3AED),
    'in_person': Color(0xFFD97706),
  };
  static const _typeIcons = {
    'video'    : Icons.videocam_rounded,
    'audio'    : Icons.phone_rounded,
    'chat'     : Icons.chat_rounded,
    'in_person': Icons.local_hospital_rounded,
  };

  Color get _color => _typeColors[apt.type] ?? AppColors.textMuted;
  IconData get _icon => _typeIcons[apt.type] ?? Icons.medical_services_rounded;

  Color get _statusColor {
    switch (apt.status) {
      case 'confirmed': return AppColors.primary;
      case 'ongoing'  : return AppColors.accent;
      case 'completed': return AppColors.textMuted;
      default         : return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = apt.status == 'ongoing' || apt.status == 'confirmed';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Token badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('#${apt.tokenNo}',
                  style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icon, size: 10, color: _statusColor),
                    const SizedBox(width: 3),
                    Text(apt.time,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (isLive)
                GestureDetector(
                  onTap: () => context.push('/doctor/video-call'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: apt.status == 'ongoing' ? AppColors.accent : AppColors.primary,
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
          ),
        ],
      ),
    );
  }
}

class _EarningsPreview extends StatelessWidget {
  final MockDoctor doc;
  const _EarningsPreview({required this.doc});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: const [Color(0xFF059669), Color(0xFF10B981)],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Month',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '₹${(doc.earningsMonth / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.patientsToday} consultations today',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('↑ 18% vs last month',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {},
                child: const Text('View breakdown →',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
