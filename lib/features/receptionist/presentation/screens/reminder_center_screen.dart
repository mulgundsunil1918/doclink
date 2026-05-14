import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class ReminderCenterScreen extends StatefulWidget {
  const ReminderCenterScreen({super.key});
  @override
  State<ReminderCenterScreen> createState() => _ReminderCenterScreenState();
}

class _ReminderCenterScreenState extends State<ReminderCenterScreen>
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

  final _reminders = [
    _Reminder(
      patient: 'Riya Sharma',
      phone: '+91 98765 43210',
      type: 'Appointment',
      message: 'Reminder: Your video consultation is tomorrow at 10:00 AM',
      channel: 'SMS+WhatsApp',
      scheduledAt: 'Today, 9:00 PM',
      status: 'pending',
    ),
    _Reminder(
      patient: 'Karan Patel',
      phone: '+91 87654 32109',
      type: 'Follow-up',
      message: 'Dr. Mehta recommends a follow-up after 2 weeks',
      channel: 'WhatsApp',
      scheduledAt: 'Today, 6:00 PM',
      status: 'sent',
    ),
    _Reminder(
      patient: 'Sunita Rao',
      phone: '+91 76543 21098',
      type: 'Lab Report',
      message: 'Please upload your latest blood report before the appointment',
      channel: 'SMS',
      scheduledAt: 'Yesterday, 4:00 PM',
      status: 'sent',
    ),
    _Reminder(
      patient: 'Amit Verma',
      phone: '+91 65432 10987',
      type: 'Appointment',
      message: 'Your appointment is confirmed for tomorrow 2:30 PM',
      channel: 'SMS+WhatsApp',
      scheduledAt: 'Tomorrow, 9:00 AM',
      status: 'scheduled',
    ),
    _Reminder(
      patient: 'Deepa Menon',
      phone: '+91 54321 09876',
      type: 'No-Show',
      message: 'We missed you today. Please reschedule your appointment.',
      channel: 'WhatsApp',
      scheduledAt: 'Today, 3:00 PM',
      status: 'failed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pending = _reminders.where((r) => r.status == 'pending').length;
    final sent = _reminders.where((r) => r.status == 'sent').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Reminder Center',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.patientPrimary,
          unselectedLabelColor: AppColors.slate400,
          indicatorColor: AppColors.patientPrimary,
          tabs: [
            Tab(text: 'All (${_reminders.length})'),
            Tab(text: 'Pending ($pending)'),
            Tab(text: 'Sent ($sent)'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _MiniStat(label: 'Sent Today', value: '$sent', color: const Color(0xFF059669)),
                const SizedBox(width: 8),
                _MiniStat(label: 'Pending', value: '$pending', color: const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _MiniStat(
                  label: 'Failed',
                  value: '${_reminders.where((r) => r.status == 'failed').length}',
                  color: const Color(0xFFDC2626),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showBroadcastSheet(context),
                  icon: const Icon(Icons.broadcast_on_personal_rounded, size: 16),
                  label: const Text('Broadcast', style: TextStyle(fontSize: 12)),
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
                _ReminderList(reminders: _reminders, onSend: _sendReminder),
                _ReminderList(
                  reminders: _reminders.where((r) => r.status == 'pending').toList(),
                  onSend: _sendReminder,
                ),
                _ReminderList(
                  reminders: _reminders.where((r) => r.status == 'sent').toList(),
                  onSend: _sendReminder,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateReminderSheet(context),
        backgroundColor: AppColors.patientPrimary,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('New Reminder'),
      ),
    );
  }

  void _sendReminder(BuildContext context, _Reminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder sent to ${reminder.patient} via ${reminder.channel}'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  void _showBroadcastSheet(BuildContext context) {
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
            const Text('Broadcast Message',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 12),
            const Text('Send to all patients with upcoming appointments',
                style: TextStyle(color: AppColors.slate500, fontSize: 13)),
            const SizedBox(height: 20),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter broadcast message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Send via:',
                style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['SMS', 'WhatsApp', 'Push'].map((c) => FilterChip(
                    label: Text(c),
                    selected: c != 'Push',
                    onSelected: (_) {},
                    selectedColor: AppColors.patientPrimary.withValues(alpha: 0.15),
                  )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast sent to 5 patients')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Send to 5 Patients'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateReminderSheet(BuildContext context) {
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
            const Text('Create Reminder',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Patient Name / Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: 'Appointment',
              decoration: const InputDecoration(
                labelText: 'Reminder Type',
                border: OutlineInputBorder(),
              ),
              items: ['Appointment', 'Follow-up', 'Lab Report', 'Medication', 'No-Show']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder scheduled')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Schedule Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderList extends StatelessWidget {
  final List<_Reminder> reminders;
  final void Function(BuildContext, _Reminder) onSend;
  const _ReminderList({required this.reminders, required this.onSend});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const Center(child: Text('No reminders', style: TextStyle(color: AppColors.slate400)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reminders.length,
      itemBuilder: (ctx, i) => _ReminderCard(
        reminder: reminders[i],
        onSend: () => onSend(context, reminders[i]),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final _Reminder reminder;
  final VoidCallback onSend;
  const _ReminderCard({required this.reminder, required this.onSend});

  Color get _statusColor {
    switch (reminder.status) {
      case 'sent': return const Color(0xFF059669);
      case 'pending': return const Color(0xFFD97706);
      case 'scheduled': return AppColors.patientPrimary;
      case 'failed': return const Color(0xFFDC2626);
      default: return AppColors.slate400;
    }
  }

  IconData get _channelIcon {
    if (reminder.channel.contains('WhatsApp')) return Icons.chat_rounded;
    return Icons.sms_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.patient,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    Text(reminder.phone,
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reminder.status[0].toUpperCase() + reminder.status.substring(1),
                  style: TextStyle(
                      color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(reminder.message,
                style: const TextStyle(color: AppColors.slate700, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(_channelIcon, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(reminder.channel,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(reminder.scheduledAt,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
              const Spacer(),
              if (reminder.status == 'pending' || reminder.status == 'failed')
                TextButton(
                  onPressed: onSend,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.patientPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    reminder.status == 'failed' ? 'Retry' : 'Send Now',
                    style: const TextStyle(fontSize: 12),
                  ),
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
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.slate500, fontSize: 10)),
      ],
    );
  }
}

class _Reminder {
  final String patient, phone, type, message, channel, scheduledAt, status;
  const _Reminder({
    required this.patient,
    required this.phone,
    required this.type,
    required this.message,
    required this.channel,
    required this.scheduledAt,
    required this.status,
  });
}
