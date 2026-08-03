import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'my_patients_screen.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  final void Function(int) onNavigate;
  const DoctorDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    final aptsAsync = ref.watch(doctorAppointmentsProvider);
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return doctorAsync.when(
      loading: () => const Scaffold(
        body: Center(child: DlLoader()),
      ),
      error: (_, __) => _buildBody(context, ref, null, [], greeting),
      data: (doc) => aptsAsync.when(
        loading: () => _buildBody(context, ref, doc, [], greeting),
        error: (_, __) => _buildBody(context, ref, doc, [], greeting),
        data: (apts) => _buildBody(context, ref, doc, apts, greeting),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppDoctor? doc,
    List<AppAppointment> apts,
    String greeting,
  ) {
    final confirmed = apts.where((a) => a.status == 'confirmed').length;
    final done = apts.where((a) => a.status == 'completed').length;
    final pending = apts.where((a) => a.status == 'pending').length;
    final ongoing = apts.where((a) => a.status == 'ongoing').length;

    final docName = doc?.name ?? 'Doctor';
    final lastName = docName.split(' ').last;
    final initials = doc?.initials ?? 'DR';
    final specialty = doc?.specialty ?? 'General Physician';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
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
                                  child: Text('$greeting 👋',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 11)),
                                ),
                                const SizedBox(height: 6),
                                Text('Dr. $lastName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                    )),
                                const SizedBox(height: 2),
                                Row(children: [
                                  const Icon(Icons.local_hospital_rounded,
                                      color: Colors.white54, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    doc?.city != null
                                        ? '$specialty  ·  ${doc!.city}'
                                        : specialty,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ]),
                              ],
                            ),
                          ),
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
                              child: Center(
                                child: Text(initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white70, size: 22),
                            onPressed: () => _showNotifications(context, ref),
                          ),
                        ],
                      ),
                    ),
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
                            value: doc != null
                                ? '₹${(doc.earningsToday / 1000).toStringAsFixed(1)}k'
                                : '₹0',
                            label: 'Earnings',
                            sub: 'today',
                            icon: Icons.currency_rupee_rounded,
                            iconColor: AppColors.accent,
                            valueColor: AppColors.accent,
                          ),
                          _MetricDivider(),
                          _MetricTile(
                            value: doc != null
                                ? doc.rating.toStringAsFixed(1)
                                : '—',
                            label: 'Rating',
                            sub: '${doc?.totalPatients ?? 0} patients',
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel('Quick Actions'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
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
                        onTap: () => context.push('/doctor/rx')),
                    _ActionBtn(
                        icon: Icons.people_alt_rounded,
                        label: 'My Patients',
                        color: const Color(0xFF059669),
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyPatientsScreen()),
                            )),
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
                if (apts.isEmpty)
                  _EmptyState(
                    icon: Icons.event_available_rounded,
                    message: 'No appointments today',
                    sub: 'Your queue will appear here',
                  )
                else
                  ...apts.map((a) => _QueueCard(apt: a, ref: ref)),
                const SizedBox(height: 24),
                _EarningsCard(doc: doc),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    final notifs = ref.read(notificationsProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (notifs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No new notifications',
                  style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...notifs.take(5).map((n) => ListTile(
                  leading: const Icon(Icons.notifications_rounded,
                      color: AppColors.primary),
                  title: Text(n.title),
                  subtitle: n.body != null ? Text(n.body!) : null,
                )),
        ],
      ),
    );
  }
}

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
            Row(children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
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
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white.withValues(alpha: 0.15),
      );
}

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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700));
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
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final AppAppointment apt;
  final WidgetRef ref;
  const _QueueCard({required this.apt, required this.ref});

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
  IconData get _typeIcon => _typeIcons[apt.type] ?? Icons.medical_services_rounded;
  Color get _statusColor => _statusColors[apt.status] ?? AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    final isActive = apt.status == 'ongoing' || apt.status == 'confirmed';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _typeColor, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x081E293B), blurRadius: 12, offset: Offset(0, 3))
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
                child: Text('#${apt.tokenNo ?? '?'}',
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
                  Row(children: [
                    Text(apt.patientName ?? 'Patient',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(width: 6),
                    Icon(_typeIcon, size: 12, color: _typeColor),
                  ]),
                  const SizedBox(height: 3),
                  Text(apt.chiefComplaint ?? apt.type,
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
                  child: Text(apt.formattedTime,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                if (isActive) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await updateAppointmentStatus(apt.id, 'ongoing');
                          if (context.mounted) {
                            if (apt.type == 'chat') {
                              context.push('/doctor/chat', extra: apt.id);
                            } else {
                              context.push('/doctor/video-call');
                            }
                          }
                          ref.invalidate(doctorAppointmentsProvider);
                        },
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
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/doctor/rx', extra: {
                          'patientName': apt.patientName,
                          'patientId': apt.patientId,
                          'appointmentId': apt.id,
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentDark
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Rx',
                              style: TextStyle(
                                  color: AppColors.accentDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
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
  final AppDoctor? doc;
  const _EarningsCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final monthly = doc?.earningsMonth ?? 0;
    final patientsToday = doc?.totalPatients ?? 0;
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
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '₹${(monthly / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1),
                ),
                const SizedBox(height: 4),
                Text('$patientsToday total patients',
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.go('/doctor'),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message, sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
