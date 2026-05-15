import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedDay = 'Mon';
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final slots = MockData.weekSlots[_selectedDay] ?? [];
    final booked = MockData.bookedSlots[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule & Slots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _showAddSlotDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Day picker
          Container(
            color: AppColors.doctorCard,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: _days.map((d) {
                final sel = d == _selectedDay;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = d),
                    child: Column(
                      children: [
                        Text(d,
                            style: TextStyle(
                              fontSize: 11,
                              color: sel ? AppColors.doctorPrimary : AppColors.slate400,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                            )),
                        const SizedBox(height: 4),
                        if (sel)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.doctorPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Stats row
          Container(
            color: AppColors.doctorCard,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _Stat('Total Slots', '${slots.length}', AppColors.doctorPrimary),
                const SizedBox(width: 12),
                _Stat('Booked', '${booked.length}', AppColors.warning),
                const SizedBox(width: 12),
                _Stat('Available', '${slots.length - booked.length}', AppColors.doctorAccent),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.doctorBorder),
          // Slot grid
          Expanded(
            child: slots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.weekend_rounded, size: 48, color: AppColors.slate600),
                        const SizedBox(height: 12),
                        const Text('No slots on Sunday', style: TextStyle(color: AppColors.slate400)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showAddSlotDialog,
                          child: const Text('Add Slots'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (_, i) {
                      final time = slots[i];
                      final isBooked = booked.contains(time);
                      return _SlotChip(
                        time: time,
                        isBooked: isBooked,
                        onTap: isBooked
                            ? () => context.push('/doctor/appointment/apt_00${i + 1}')
                            : () => _confirmDeleteSlot(time),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSlotDialog,
        backgroundColor: AppColors.doctorPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Slot', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddSlotDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Slot — $_selectedDay',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
                         '14:00', '14:30', '15:00', '15:30', '17:00', '17:30']
                  .map((t) => ActionChip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primaryLight,
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Slot $t added on $_selectedDay')),
                          );
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSlot(String time) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Block slot $time?'),
        content: Text('This will prevent new bookings for $_selectedDay $time.',
            style: const TextStyle(color: AppColors.slate400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Slot $time blocked')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.slate400)),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String time;
  final bool isBooked;
  final VoidCallback onTap;
  const _SlotChip({required this.time, required this.isBooked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isBooked
              ? AppColors.primaryLight
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBooked ? AppColors.primary : AppColors.border,
            width: isBooked ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isBooked ? AppColors.primary : AppColors.textSecondary,
                )),
            if (isBooked)
              const Text('Booked',
                  style: TextStyle(fontSize: 9, color: AppColors.doctorPrimary)),
          ],
        ),
      ),
    );
  }
}
