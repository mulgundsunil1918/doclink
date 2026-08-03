import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});
  @override
  ConsumerState<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends ConsumerState<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final aptsAsync = ref.watch(patientAppointmentsProvider);
    return aptsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: DlLoader()),
      ),
      error: (_, __) => _buildScaffold(context, []),
      data: (apts) => _buildScaffold(context, apts),
    );
  }

  Widget _buildScaffold(BuildContext context, List<AppAppointment> apts) {
    final upcoming = apts
        .where((a) => a.status == 'confirmed' || a.status == 'pending')
        .toList();
    final ongoing = apts.where((a) => a.status == 'ongoing').toList();
    final past = apts
        .where((a) => a.status == 'completed' || a.status == 'cancelled')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Appointments',
            style: TextStyle(
                color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.patientPrimary),
            onPressed: () => ref.invalidate(patientAppointmentsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.patientPrimary,
          unselectedLabelColor: AppColors.slate400,
          indicatorColor: AppColors.patientPrimary,
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Ongoing (${ongoing.length})'),
            Tab(text: 'Past (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentList(appointments: upcoming, canJoin: true, ref: ref),
          _AppointmentList(
              appointments: ongoing, canJoin: true, isOngoing: true, ref: ref),
          _AppointmentList(appointments: past, ref: ref),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patient/book'),
        backgroundColor: AppColors.patientPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book New'),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppAppointment> appointments;
  final bool canJoin;
  final bool isOngoing;
  final WidgetRef ref;
  const _AppointmentList({
    required this.appointments,
    required this.ref,
    this.canJoin = false,
    this.isOngoing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 48, color: AppColors.slate300),
            const SizedBox(height: 12),
            const Text('No appointments',
                style: TextStyle(color: AppColors.slate400, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: appointments.length,
      itemBuilder: (ctx, i) => _AppointmentCard(
        apt: appointments[i],
        canJoin: canJoin,
        isOngoing: isOngoing,
        ref: ref,
      ),
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  final AppAppointment apt;
  final bool canJoin;
  final bool isOngoing;
  final WidgetRef ref;
  const _AppointmentCard({
    required this.apt,
    required this.ref,
    this.canJoin = false,
    this.isOngoing = false,
  });

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  bool _cancelling = false;

  Color get _typeColor {
    switch (widget.apt.type) {
      case 'video':
        return AppColors.patientPrimary;
      case 'audio':
        return AppColors.patientSecondary;
      case 'chat':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.slate500;
    }
  }

  IconData get _typeIcon {
    switch (widget.apt.type) {
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

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await updateAppointmentStatus(widget.apt.id, 'cancelled');
      widget.ref.invalidate(patientAppointmentsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel appointment')),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _join(BuildContext context) {
    if (widget.apt.type == 'chat') {
      context.push('/patient/chat', extra: widget.apt.id);
    } else {
      context.push('/patient/video-call');
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apt;
    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.doctorName != null
                          ? 'Dr. ${apt.doctorName}'
                          : 'Doctor',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800,
                          fontSize: 14),
                    ),
                    Text(
                      '${apt.doctorSpecialty ?? apt.type.replaceAll('_', ' ')} · #${apt.tokenNo ?? '—'}',
                      style: const TextStyle(
                          color: AppColors.slate500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isOngoing
                      ? const Color(0xFF059669).withValues(alpha: 0.1)
                      : _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isOngoing
                      ? 'In Progress'
                      : (apt.formattedTime.isNotEmpty
                          ? apt.formattedTime
                          : apt.status),
                  style: TextStyle(
                    color: widget.isOngoing
                        ? const Color(0xFF059669)
                        : _typeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (apt.chiefComplaint != null && apt.chiefComplaint!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.patientSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information_rounded,
                      size: 14, color: AppColors.slate400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(apt.chiefComplaint!,
                        style: const TextStyle(
                            color: AppColors.slate600, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
          if (apt.formattedDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 12, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(apt.formattedDate,
                    style: const TextStyle(
                        color: AppColors.slate500, fontSize: 11)),
              ],
            ),
          ],
          if (widget.canJoin) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelling ? null : _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate500,
                      side: const BorderSide(color: AppColors.slate200),
                      minimumSize: const Size(0, 36),
                    ),
                    child: _cancelling
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child:
                                DlLoader())
                        : const Text('Cancel',
                            style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _join(context),
                    icon: Icon(_typeIcon, size: 14),
                    label: Text(
                      widget.isOngoing
                          ? 'Rejoin'
                          : 'Join ${apt.type[0].toUpperCase()}${apt.type.substring(1).replaceAll('_', '-')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
