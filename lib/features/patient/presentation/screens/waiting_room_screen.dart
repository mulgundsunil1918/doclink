import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/dl_card.dart';

class WaitingRoomScreen extends ConsumerStatefulWidget {
  final String? appointmentId;
  const WaitingRoomScreen({super.key, this.appointmentId});

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(_pulseCtrl);

    // Refresh queue position every 30s
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (widget.appointmentId != null) {
        ref.invalidate(queuePositionProvider(widget.appointmentId!));
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _joinConsultation(AppAppointment apt) {
    switch (apt.type) {
      case 'video':
      case 'audio':
        context.push('/patient/video-call');
        break;
      case 'chat':
        context.push('/patient/chat', extra: apt.id);
        break;
      default:
        // in_person — nothing to join remotely
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please proceed to the clinic when called'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
            'Cancellation charges may apply. Do you want to continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No, Stay')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      if (widget.appointmentId != null) {
        try {
          await updateAppointmentStatus(widget.appointmentId!, 'cancelled');
        } catch (_) {}
      }
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.appointmentId;

    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Waiting Room',
            style:
                TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _confirmCancel,
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
      body: id == null
          ? _NoAppointmentState(onBack: () => context.pop())
          : _WaitingBody(
              appointmentId: id,
              pulse: _pulse,
              onJoin: _joinConsultation,
            ),
    );
  }
}

class _NoAppointmentState extends StatelessWidget {
  final VoidCallback onBack;
  const _NoAppointmentState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy_rounded,
              size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text('No appointment found',
              style: TextStyle(
                  color: AppColors.slate600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Please book an appointment first.',
              style: TextStyle(color: AppColors.slate400, fontSize: 13)),
          const SizedBox(height: 24),
          TextButton(onPressed: onBack, child: const Text('Go Back')),
        ],
      ),
    );
  }
}

class _WaitingBody extends ConsumerWidget {
  final String appointmentId;
  final Animation<double> pulse;
  final void Function(AppAppointment) onJoin;
  const _WaitingBody({
    required this.appointmentId,
    required this.pulse,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptAsync = ref.watch(appointmentByIdProvider(appointmentId));
    final posAsync = ref.watch(queuePositionProvider(appointmentId));

    final position = posAsync.valueOrNull ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Doctor card
          aptAsync.when(
            loading: () => const DlCard(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: DlLoader(),
              )),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (apt) {
              if (apt == null) return const SizedBox.shrink();
              final initials = (apt.doctorName ?? 'DR')
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .take(2)
                  .map((p) => p[0].toUpperCase())
                  .join();
              return DlCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppColors.patientPrimary.withValues(alpha: 0.1),
                      child: Text(initials,
                          style: const TextStyle(
                              color: AppColors.patientPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(apt.doctorName ?? 'Doctor',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800,
                                  fontSize: 15)),
                          Text(apt.doctorSpecialty ?? 'Physician',
                              style: const TextStyle(
                                  color: AppColors.slate500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(height: 4),
                        const Text('Available',
                            style: TextStyle(
                                color: Color(0xFF059669), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Pulse circle with queue position
          ScaleTransition(
            scale: pulse,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.patientPrimary.withValues(alpha: 0.15),
                    AppColors.patientPrimary.withValues(alpha: 0.03),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.patientPrimary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      posAsync.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: DlLoader())
                          : Text(
                              '#$position',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800),
                            ),
                      const Text('in queue',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            position == 0
                ? 'You\'re next!'
                : '$position patient${position == 1 ? '' : 's'} ahead of you',
            style: const TextStyle(
                color: AppColors.slate700,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ll be notified when the doctor is ready',
            style: TextStyle(color: AppColors.slate500, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Status timeline
          DlCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Queue Status',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800)),
                const SizedBox(height: 16),
                _TimelineStep(label: 'Appointment Confirmed', done: true),
                _TimelineStep(label: 'Entered Queue', done: true),
                _TimelineStep(
                    label: 'Your Turn',
                    done: position == 0,
                    active: position > 0),
                _TimelineStep(
                    label: 'Consultation', done: false, last: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          aptAsync.maybeWhen(
            data: (apt) => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: apt != null ? () => onJoin(apt) : null,
                icon: Icon(apt?.type == 'chat'
                    ? Icons.chat_rounded
                    : Icons.videocam_rounded),
                label: Text(apt?.type == 'in_person'
                    ? 'Proceed to Clinic'
                    : 'Join Consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool last;
  const _TimelineStep({
    required this.label,
    this.done = false,
    this.active = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF059669)
        : active
            ? AppColors.patientPrimary
            : AppColors.slate300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF059669)
                    : active
                        ? AppColors.patientPrimary
                        : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
            if (!last)
              Container(
                width: 2,
                height: 24,
                color: done ? const Color(0xFF059669) : AppColors.slate200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: done
                  ? AppColors.slate700
                  : active
                      ? AppColors.patientPrimary
                      : AppColors.slate400,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
