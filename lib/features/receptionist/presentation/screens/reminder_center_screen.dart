import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

// Track which appointment IDs had reminders sent this session
final _sentReminderIdsProvider = StateProvider<Set<String>>((ref) => {});

class ReminderCenterScreen extends ConsumerStatefulWidget {
  const ReminderCenterScreen({super.key});

  @override
  ConsumerState<ReminderCenterScreen> createState() =>
      _ReminderCenterScreenState();
}

class _ReminderCenterScreenState extends ConsumerState<ReminderCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _sendReminder(AppAppointment apt) async {
    try {
      final db = Supabase.instance.client;
      final msg = 'Reminder: You have a ${_typeLabel(apt.type)} appointment'
          '${apt.formattedDate.isNotEmpty ? ' on ${apt.formattedDate}' : ' today'}'
          '${apt.formattedTime.isNotEmpty ? ' at ${apt.formattedTime}' : ''}. '
          'Please be ready on time.';

      await db.from('notifications').insert({
        'user_id': apt.patientId,
        'title': 'Appointment Reminder',
        'body': msg,
        'type': 'appointment_reminder',
      });

      ref.read(_sentReminderIdsProvider.notifier).update((s) => {...s, apt.id});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder sent to ${apt.patientName ?? 'patient'}'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendBroadcast(String message, BuildContext ctx) async {
    final apts = ref.read(todayQueueProvider).valueOrNull ?? [];
    if (apts.isEmpty) return;
    Navigator.pop(ctx);
    try {
      final db = Supabase.instance.client;
      final inserts = apts
          .map((a) => {
                'user_id': a.patientId,
                'title': 'Clinic Announcement',
                'body': message,
                'type': 'broadcast',
              })
          .toList();
      await db.from('notifications').insert(inserts);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broadcast sent to ${apts.length} patients'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast failed: $e'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(todayQueueProvider);
    final sentIds = ref.watch(_sentReminderIdsProvider);

    return queueAsync.when(
      loading: () => const Scaffold(
          body: Center(child: DlLoader())),
      error: (_, __) => const Scaffold(
          body: Center(child: Text('Failed to load appointments'))),
      data: (allApts) {
        // Filter: only pending/confirmed are relevant for reminders
        final remindable = allApts
            .where((a) => a.status == 'pending' || a.status == 'confirmed')
            .toList();

        final pending =
            remindable.where((a) => !sentIds.contains(a.id)).toList();
        final sent = remindable.where((a) => sentIds.contains(a.id)).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('Reminder Center',
                style: TextStyle(
                    color: AppColors.slate800, fontWeight: FontWeight.w700)),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.patientPrimary,
              unselectedLabelColor: AppColors.slate400,
              indicatorColor: AppColors.patientPrimary,
              tabs: [
                Tab(text: 'All (${remindable.length})'),
                Tab(text: 'Pending (${pending.length})'),
                Tab(text: 'Sent (${sent.length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _MiniStat(
                      label: 'Sent',
                      value: '${sent.length}',
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    _MiniStat(
                      label: 'Pending',
                      value: '${pending.length}',
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    _MiniStat(
                      label: 'Total',
                      value: '${remindable.length}',
                      color: AppColors.slate600,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showBroadcastSheet(context),
                      icon: const Icon(
                          Icons.broadcast_on_personal_rounded,
                          size: 16),
                      label: const Text('Broadcast',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.patientPrimary,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReminderList(
                        appointments: remindable,
                        sentIds: sentIds,
                        onSend: _sendReminder),
                    _ReminderList(
                        appointments: pending,
                        sentIds: sentIds,
                        onSend: _sendReminder),
                    _ReminderList(
                        appointments: sent,
                        sentIds: sentIds,
                        onSend: _sendReminder),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showBroadcastSheet(context),
            backgroundColor: AppColors.patientPrimary,
            icon: const Icon(Icons.add_alert_rounded),
            label: const Text('Broadcast'),
          ),
        );
      },
    );
  }

  void _showBroadcastSheet(BuildContext context) {
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Broadcast Message',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 8),
            const Text('Sends to all patients with appointments today',
                style: TextStyle(color: AppColors.slate500, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter broadcast message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (msgCtrl.text.trim().isNotEmpty) {
                    _sendBroadcast(msgCtrl.text.trim(), ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                    'Send to ${ref.read(todayQueueProvider).valueOrNull?.length ?? 0} Patients'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'video':
      return 'video';
    case 'audio':
      return 'audio';
    case 'chat':
      return 'chat';
    case 'in_person':
      return 'in-person';
    default:
      return type;
  }
}

class _ReminderList extends StatelessWidget {
  final List<AppAppointment> appointments;
  final Set<String> sentIds;
  final Future<void> Function(AppAppointment) onSend; // ignore: prefer_function_declarations_over_variables
  const _ReminderList({
    required this.appointments,
    required this.sentIds,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 48, color: AppColors.slate200),
          SizedBox(height: 12),
          Text('No appointments to remind',
              style: TextStyle(color: AppColors.slate400)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: appointments.length,
      itemBuilder: (ctx, i) {
        final apt = appointments[i];
        return _ReminderCard(
          appointment: apt,
          sent: sentIds.contains(apt.id),
          onSend: () => onSend(apt),
        );
      },
    );
  }
}

class _ReminderCard extends StatefulWidget {
  final AppAppointment appointment;
  final bool sent;
  final Future<void> Function() onSend;
  const _ReminderCard({
    required this.appointment,
    required this.sent,
    required this.onSend,
  });

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    final name = apt.patientName ?? 'Patient';
    final initials =
        name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join().toUpperCase();
    final typeLabel = _typeLabel(apt.type);

    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppColors.patientPrimary.withValues(alpha: 0.1),
                child: Text(initials,
                    style: const TextStyle(
                        color: AppColors.patientPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    Text(
                        '${typeLabel[0].toUpperCase()}${typeLabel.substring(1)} • ${apt.formattedDate} ${apt.formattedTime}',
                        style: const TextStyle(
                            color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              if (apt.tokenNo != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.patientPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Token #${apt.tokenNo}',
                      style: const TextStyle(
                          color: AppColors.patientPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Reminder: Your $typeLabel appointment'
              '${apt.formattedDate.isNotEmpty ? ' on ${apt.formattedDate}' : ' today'}'
              '${apt.formattedTime.isNotEmpty ? ' at ${apt.formattedTime}' : ''}. '
              'Please be ready on time.',
              style: const TextStyle(color: AppColors.slate700, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.sent
                      ? const Color(0xFF059669).withValues(alpha: 0.1)
                      : const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.sent ? 'Sent' : 'Pending',
                  style: TextStyle(
                    color: widget.sent
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (!widget.sent)
                TextButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          setState(() => _sending = true);
                          await widget.onSend();
                          if (mounted) setState(() => _sending = false);
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.patientPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: DlLoader())
                      : const Text('Send Now',
                          style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label,
            style:
                const TextStyle(color: AppColors.slate500, fontSize: 10)),
      ],
    );
  }
}
