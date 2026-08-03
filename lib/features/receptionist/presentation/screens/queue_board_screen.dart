import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class QueueBoardScreen extends ConsumerStatefulWidget {
  const QueueBoardScreen({super.key});
  @override
  ConsumerState<QueueBoardScreen> createState() => _QueueBoardScreenState();
}

class _QueueBoardScreenState extends ConsumerState<QueueBoardScreen> {
  int _elapsed = 0;
  late Timer _timer;

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
    final queueAsync = ref.watch(todayQueueProvider);
    return queueAsync.when(
      loading: () => const Scaffold(body: Center(child: DlLoader())),
      error: (_, __) => _buildScreen(context, []),
      data: (queue) => _buildScreen(context, queue),
    );
  }

  Widget _buildScreen(BuildContext context, List<AppAppointment> queue) {
    final waiting = queue.where((q) => q.status == 'pending' || q.status == 'confirmed').length;
    final done = queue.where((q) => q.status == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Queue Board',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.patientPrimary),
            onPressed: () => ref.invalidate(todayQueueProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatChip(label: 'Waiting', value: '$waiting', color: const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _StatChip(label: 'Done Today', value: '$done', color: const Color(0xFF059669)),
                const SizedBox(width: 8),
                _StatChip(label: 'Total', value: '${queue.length}', color: AppColors.patientPrimary),
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
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available_rounded, size: 56, color: AppColors.slate300),
                        const SizedBox(height: 12),
                        const Text('No appointments today',
                            style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(todayQueueProvider),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: queue.length,
                    itemBuilder: (ctx, i) => _QueueCard(
                      item: queue[i],
                      onStatusUpdate: (newStatus) async {
                        await updateAppointmentStatus(queue[i].id, newStatus);
                        ref.invalidate(todayQueueProvider);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddToQueue(context),
        backgroundColor: AppColors.patientPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Walk-in'),
      ),
    );
  }

  void _showAddToQueue(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    AppDoctor? selectedDoctor;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Walk-in',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Patient Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 12),
              // Doctor selector
              Consumer(builder: (ctx, ref, _) {
                final docsAsync = ref.watch(allDoctorsProvider);
                return docsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (docs) => docs.isEmpty
                      ? const SizedBox()
                      : DropdownButtonFormField<AppDoctor>(
                          value: selectedDoctor,
                          decoration: const InputDecoration(
                            labelText: 'Assign to Doctor',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medical_services_rounded),
                          ),
                          items: docs
                              .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('Dr. ${d.name}')))
                              .toList(),
                          onChanged: (d) =>
                              setSheet(() => selectedDoctor = d),
                        ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          setSheet(() => saving = true);
                          try {
                            final uid = ref
                                .read(currentProfileProvider)
                                .valueOrNull
                                ?.id;
                            final doctorId =
                                selectedDoctor?.id ?? uid ?? '';
                            await createWalkInAppointment(
                              doctorId: doctorId,
                              createdByUid: uid ?? '',
                              patientName: name,
                              phone: phoneCtrl.text.trim(),
                            );
                            ref.invalidate(todayQueueProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('$name added to queue'),
                                backgroundColor: AppColors.patientPrimary,
                              ));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          } finally {
                            setSheet(() => saving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patientPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: DlLoader())
                      : const Text('Add to Queue'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final AppAppointment item;
  final Future<void> Function(String status) onStatusUpdate;
  const _QueueCard({required this.item, required this.onStatusUpdate});

  Color get _statusColor {
    switch (item.status) {
      case 'ongoing': return AppColors.patientPrimary;
      case 'pending': case 'confirmed': return const Color(0xFFD97706);
      case 'completed': return const Color(0xFF059669);
      default: return AppColors.slate400;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case 'ongoing': return 'In Progress';
      case 'pending': return 'Waiting';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Done';
      case 'cancelled': return 'Cancelled';
      default: return item.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == 'completed' || item.status == 'cancelled';
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
                child: Text(
                  item.tokenNo != null ? '#${item.tokenNo}' : '?',
                  style: TextStyle(color: _statusColor, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.patientName ?? 'Patient',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(item.type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
                      if (item.formattedTime.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(color: AppColors.slate300)),
                        Text(item.formattedTime,
                            style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
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
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            if (!isDone) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (v) => onStatusUpdate(v),
                itemBuilder: (_) => [
                  if (item.status != 'ongoing')
                    const PopupMenuItem(value: 'ongoing', child: Text('Mark In Progress')),
                  const PopupMenuItem(value: 'completed', child: Text('Mark Done')),
                  const PopupMenuItem(value: 'cancelled', child: Text('Mark No-Show')),
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
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
