import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class QueueBoardScreen extends StatefulWidget {
  const QueueBoardScreen({super.key});
  @override
  State<QueueBoardScreen> createState() => _QueueBoardScreenState();
}

class _QueueBoardScreenState extends State<QueueBoardScreen> {
  int _elapsed = 0;
  late Timer _timer;

  final _queue = [
    _QueueItem(token: 'T001', name: 'Riya Sharma', type: 'Video', status: 'in-progress', waitMins: 0),
    _QueueItem(token: 'T002', name: 'Karan Patel', type: 'Audio', status: 'waiting', waitMins: 12),
    _QueueItem(token: 'T003', name: 'Sunita Rao', type: 'Chat', status: 'waiting', waitMins: 24),
    _QueueItem(token: 'T004', name: 'Amit Verma', type: 'In-Person', status: 'waiting', waitMins: 36),
    _QueueItem(token: 'T005', name: 'Priya Nair', type: 'Video', status: 'waiting', waitMins: 48),
    _QueueItem(token: 'T006', name: 'Rahul Das', type: 'Audio', status: 'no-show', waitMins: 60),
    _QueueItem(token: 'T007', name: 'Deepa Menon', type: 'In-Person', status: 'done', waitMins: 0),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _currentDuration {
    final mins = _elapsed ~/ 60;
    final secs = _elapsed % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _queue.where((q) => q.status == 'waiting').length;
    final done = _queue.where((q) => q.status == 'done').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Queue Board',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.slate600),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.patientPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatChip(label: 'Waiting', value: '$waiting', color: const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _StatChip(label: 'Done Today', value: '$done', color: const Color(0xFF059669)),
                const SizedBox(width: 8),
                _StatChip(label: 'Avg Wait', value: '18 min', color: AppColors.patientPrimary),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Live • $_currentDuration',
                      style: const TextStyle(
                          color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          // Queue list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _queue.length,
              itemBuilder: (ctx, i) => _QueueCard(
                item: _queue[i],
                onCall: () => _callNext(context, _queue[i]),
                onNoShow: () => setState(() => _queue[i] = _queue[i].copyWith(status: 'no-show')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddToQueue(context),
        backgroundColor: AppColors.patientPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add to Queue'),
      ),
    );
  }

  void _callNext(BuildContext context, _QueueItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${item.name} (${item.token})'),
        backgroundColor: AppColors.patientPrimary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAddToQueue(BuildContext context) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Walk-in to Queue',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Patient Name / Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to queue')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Add to Queue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final _QueueItem item;
  final VoidCallback onCall;
  final VoidCallback onNoShow;
  const _QueueCard({required this.item, required this.onCall, required this.onNoShow});

  Color get _statusColor {
    switch (item.status) {
      case 'in-progress': return AppColors.patientPrimary;
      case 'waiting': return const Color(0xFFD97706);
      case 'done': return const Color(0xFF059669);
      case 'no-show': return const Color(0xFFDC2626);
      default: return AppColors.slate400;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case 'in-progress': return 'In Progress';
      case 'waiting': return 'Waiting';
      case 'done': return 'Done';
      case 'no-show': return 'No Show';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == 'done' || item.status == 'no-show';
    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: DlCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(item.token.substring(1),
                    style: TextStyle(
                        color: _statusColor, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.slate800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(item.type,
                          style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                      if (item.waitMins > 0) ...[
                        const Text(' • ', style: TextStyle(color: AppColors.slate300)),
                        Text('~${item.waitMins} min wait',
                            style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_statusLabel,
                  style: TextStyle(
                      color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            if (item.status == 'waiting') ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'call') onCall();
                  if (v == 'noshow') onNoShow();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'call', child: Text('Call Patient')),
                  PopupMenuItem(value: 'noshow', child: Text('Mark No-Show')),
                ],
                child: const Icon(Icons.more_vert_rounded, color: AppColors.slate400, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QueueItem {
  final String token, name, type, status;
  final int waitMins;
  const _QueueItem({
    required this.token,
    required this.name,
    required this.type,
    required this.status,
    required this.waitMins,
  });

  _QueueItem copyWith({String? status}) => _QueueItem(
        token: token,
        name: name,
        type: type,
        status: status ?? this.status,
        waitMins: waitMins,
      );
}
