import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/dl_card.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});
  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  int _position = 2;
  int _secondsLeft = 740;
  late Timer _timer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(_pulseCtrl);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _waitTime {
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Waiting Room',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => _confirmCancel(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Doctor card
            DlCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.1),
                    child: const Text('AM',
                        style: TextStyle(
                            color: AppColors.patientPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Arjun Mehta',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate800,
                                fontSize: 15)),
                        Text('General Physician',
                            style: TextStyle(color: AppColors.slate500, fontSize: 13)),
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
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('In Session', style: TextStyle(color: Color(0xFF059669), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Pulse circle
            ScaleTransition(
              scale: _pulse,
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
                        Text(
                          '#$_position',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                        ),
                        const Text('in queue',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Estimated wait: $_waitTime',
              style: const TextStyle(
                  color: AppColors.slate700, fontSize: 18, fontWeight: FontWeight.w600),
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
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  _TimelineStep(label: 'Appointment Confirmed', done: true),
                  _TimelineStep(label: 'Payment Received', done: true),
                  _TimelineStep(label: 'Entered Queue', done: true),
                  _TimelineStep(label: 'Your Turn', done: false, active: true),
                  _TimelineStep(label: 'Consultation', done: false, last: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // While you wait
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('While you wait…',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate800)),
                  const SizedBox(height: 12),
                  _WaitOption(
                    icon: Icons.description_rounded,
                    label: 'Share your recent reports',
                    onTap: () {},
                  ),
                  _WaitOption(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message the receptionist',
                    onTap: () {},
                  ),
                  _WaitOption(
                    icon: Icons.list_alt_rounded,
                    label: 'Review your symptoms list',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Join When Ready'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text('Cancellation charges may apply. Do you want to continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No, Stay')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.maybePop(context);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Cancel Appointment'),
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
                color: done ? const Color(0xFF059669) : active ? AppColors.patientPrimary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
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
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WaitOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.patientPrimary, size: 20),
      title: Text(label, style: const TextStyle(color: AppColors.slate700, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: 18),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
