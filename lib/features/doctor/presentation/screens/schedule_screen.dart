import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum SlotStatus { available, booked, blocked }

class _Slot {
  final String time;
  SlotStatus status;
  _Slot(this.time, {this.status = SlotStatus.available});
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

List<_Slot> _defaultSlots() => [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    ].map(_Slot.new).toList();

// ── Screen ────────────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selectedDate;
  late final List<DateTime> _dates;

  // per-date availability toggle (true = open, false = day off)
  final Map<String, bool> _dayOpen = {};
  // per-date slot lists
  final Map<String, List<_Slot>> _slotMap = {};

  final _dateScrollCtrl = ScrollController();

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = today;
    _dates = List.generate(31, (i) => today.add(Duration(days: i)));
    // seed today open with default slots
    _dayOpen[_dateKey(today)] = true;
    _slotMap[_dateKey(today)] = _defaultSlots();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchedule());
  }

  @override
  void dispose() {
    _dateScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final today = _dates.first;
      final end = _dates.last;
      final rows = await Supabase.instance.client
          .from('doctor_availability')
          .select()
          .eq('doctor_id', uid)
          .gte('date', _dateKey(today))
          .lte('date', _dateKey(end));
      for (final row in rows as List) {
        final dk = row['date'] as String;
        _dayOpen[dk] = row['is_open'] as bool? ?? false;
        _slotMap[dk] = ((row['slots'] as List?) ?? [])
            .map((s) => _Slot(s['time'] as String,
                status: _parseStatus(s['status'] as String? ?? 'available')))
            .toList();
      }
      if (mounted) setState(() {});
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  SlotStatus _parseStatus(String s) => switch (s) {
    'booked' => SlotStatus.booked,
    'blocked' => SlotStatus.blocked,
    _ => SlotStatus.available,
  };

  Future<void> _saveDay() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final slots = (_slotMap[_key] ?? [])
          .map((s) => {'time': s.time, 'status': s.status.name})
          .toList();
      await saveDoctorAvailability(
        doctorId: uid,
        date: _key,
        isOpen: _dayOpen[_key] ?? false,
        slots: slots,
      );
    } catch (_) {}
    if (mounted) setState(() => _saving = false);
  }

  String get _key => _dateKey(_selectedDate);

  bool get _isOpen => _dayOpen[_key] ?? false;
  List<_Slot> get _slots => _slotMap[_key] ?? [];

  void _toggleDay(bool val) {
    setState(() {
      _dayOpen[_key] = val;
      if (val && (_slotMap[_key] == null || _slotMap[_key]!.isEmpty)) {
        _slotMap[_key] = _defaultSlots();
      }
    });
    _saveDay();
  }

  void _toggleSlot(_Slot slot) {
    if (slot.status == SlotStatus.booked) {
      // tapping booked slot → navigate to appointment
      context.push('/doctor/appointment/demo');
      return;
    }
    setState(() {
      slot.status = slot.status == SlotStatus.available
          ? SlotStatus.blocked
          : SlotStatus.available;
    });
    _saveDay();
  }

  Future<void> _addSlot() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    setState(() {
      final list = _slotMap[_key] ??= [];
      if (list.any((s) => s.time == timeStr)) return;
      list.add(_Slot(timeStr));
      list.sort((a, b) => a.time.compareTo(b.time));
    });
    _saveDay();
  }

  void _blockEntireDay() {
    setState(() {
      final list = _slotMap[_key];
      if (list == null) return;
      for (final s in list) {
        if (s.status == SlotStatus.available) s.status = SlotStatus.blocked;
      }
    });
    _saveDay();
  }

  void _clearAllBlocks() {
    setState(() {
      final list = _slotMap[_key];
      if (list == null) return;
      for (final s in list) {
        if (s.status == SlotStatus.blocked) s.status = SlotStatus.available;
      }
    });
    _saveDay();
  }

  // Split slots into morning / afternoon / evening
  Map<String, List<_Slot>> get _grouped {
    final morning = <_Slot>[];
    final afternoon = <_Slot>[];
    final evening = <_Slot>[];
    for (final s in _slots) {
      final h = int.parse(s.time.split(':')[0]);
      if (h < 12) {
        morning.add(s);
      } else if (h < 17) {
        afternoon.add(s);
      } else {
        evening.add(s);
      }
    }
    return {'Morning': morning, 'Afternoon': afternoon, 'Evening': evening};
  }

  @override
  Widget build(BuildContext context) {
    final avail = _slots.where((s) => s.status == SlotStatus.available).length;
    final booked = _slots.where((s) => s.status == SlotStatus.booked).length;
    final blocked = _slots.where((s) => s.status == SlotStatus.blocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Schedule',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (_isOpen)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'block_all') _blockEntireDay();
                if (v == 'unblock_all') _clearAllBlocks();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'block_all',
                    child: Text('Block all available slots')),
                PopupMenuItem(
                    value: 'unblock_all',
                    child: Text('Unblock all blocked slots')),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Date strip ───────────────────────────────────────────────────
              _DateStrip(
                dates: _dates,
                selected: _selectedDate,
                slotMap: _slotMap,
                dayOpen: _dayOpen,
                scrollCtrl: _dateScrollCtrl,
                onSelect: (d) {
                  setState(() => _selectedDate = d);
                  // Auto-open day if it was never configured
                  if (_dayOpen[_dateKey(d)] == null) {
                    _dayOpen[_dateKey(d)] = true;
                    _slotMap[_dateKey(d)] = _defaultSlots();
                  }
                },
              ),

              // ── Open/closed toggle ───────────────────────────────────────────
              _DayToggle(
                date: _selectedDate,
                isOpen: _isOpen,
                onChanged: _toggleDay,
                available: avail,
                booked: booked,
                blocked: blocked,
              ),

              // ── Slots ────────────────────────────────────────────────────────
              Expanded(
                child: !_isOpen
                    ? _DayOffPlaceholder(
                        onOpen: () => _toggleDay(true),
                      )
                    : _slots.isEmpty
                        ? _EmptySlots(onAdd: _addSlot)
                        : _SlotList(
                            grouped: _grouped,
                            onToggle: _toggleSlot,
                          ),
              ),
            ],
          ),
          if (_loading)
            const ColoredBox(
              color: Color(0x44FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _isOpen
          ? FloatingActionButton.extended(
              onPressed: _addSlot,
              backgroundColor: AppColors.doctorPrimary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Time Slot',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

// ── Date strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selected;
  final Map<String, List<_Slot>> slotMap;
  final Map<String, bool> dayOpen;
  final ScrollController scrollCtrl;
  final ValueChanged<DateTime> onSelect;

  const _DateStrip({
    required this.dates,
    required this.selected,
    required this.slotMap,
    required this.dayOpen,
    required this.scrollCtrl,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '${months[selected.month]} ${selected.year}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate600),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: scrollCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final d = dates[i];
                final key = _dateKey(d);
                final isSel = _dateKey(d) == _dateKey(selected);
                final open = dayOpen[key] ?? false;
                final slotCount = (slotMap[key] ?? [])
                    .where((s) => s.status == SlotStatus.available)
                    .length;
                final isToday = _dateKey(d) ==
                    _dateKey(DateTime.now());

                return GestureDetector(
                  onTap: () => onSelect(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.doctorPrimary
                          : open && slotCount > 0
                              ? AppColors.doctorPrimary.withValues(alpha: 0.06)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel
                            ? AppColors.doctorPrimary
                            : isToday
                                ? AppColors.doctorPrimary.withValues(alpha: 0.5)
                                : Colors.grey.shade200,
                        width: isToday && !isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[d.weekday],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSel ? Colors.white70 : AppColors.slate400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSel
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (open && slotCount > 0)
                          Text(
                            '$slotCount slots',
                            style: TextStyle(
                              fontSize: 8,
                              color: isSel
                                  ? Colors.white70
                                  : AppColors.doctorAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !open
                                  ? Colors.grey.shade300
                                  : Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Day open/closed toggle ─────────────────────────────────────────────────────

class _DayToggle extends StatelessWidget {
  final DateTime date;
  final bool isOpen;
  final ValueChanged<bool> onChanged;
  final int available, booked, blocked;

  const _DayToggle({
    required this.date,
    required this.isOpen,
    required this.onChanged,
    required this.available,
    required this.booked,
    required this.blocked,
  });

  @override
  Widget build(BuildContext context) {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                      '${days[date.weekday]}, ${date.day} ${months[date.month]}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOpen ? 'Open for appointments' : 'Day off — not accepting',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOpen
                            ? AppColors.doctorAccent
                            : AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: onChanged,
                activeThumbColor: AppColors.doctorAccent,
                activeTrackColor:
                    AppColors.doctorAccent.withValues(alpha: 0.25),
              ),
            ],
          ),
          if (isOpen) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatBadge('$available', 'Available',
                    AppColors.doctorAccent),
                const SizedBox(width: 8),
                _StatBadge('$booked', 'Booked',
                    AppColors.doctorPrimary),
                const SizedBox(width: 8),
                _StatBadge('$blocked', 'Blocked',
                    AppColors.slate400),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String count, label;
  final Color color;
  const _StatBadge(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

// ── Slot list ─────────────────────────────────────────────────────────────────

class _SlotList extends StatelessWidget {
  final Map<String, List<_Slot>> grouped;
  final ValueChanged<_Slot> onToggle;

  const _SlotList({required this.grouped, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: grouped.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => _SessionSection(
                title: e.key,
                slots: e.value,
                onToggle: onToggle,
              ))
          .toList(),
    );
  }
}

class _SessionSection extends StatelessWidget {
  final String title;
  final List<_Slot> slots;
  final ValueChanged<_Slot> onToggle;

  const _SessionSection({
    required this.title,
    required this.slots,
    required this.onToggle,
  });

  IconData get _icon => switch (title) {
        'Morning' => Icons.wb_sunny_rounded,
        'Afternoon' => Icons.wb_cloudy_rounded,
        _ => Icons.nights_stay_rounded,
      };

  Color get _color => switch (title) {
        'Morning' => const Color(0xFFF59E0B),
        'Afternoon' => AppColors.doctorPrimary,
        _ => const Color(0xFF7C3AED),
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_icon, size: 14, color: _color),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _color,
                    letterSpacing: 0.5)),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: _color.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) => _SlotChip(slot: slots[i], onTap: () => onToggle(slots[i])),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final _Slot slot;
  final VoidCallback onTap;
  const _SlotChip({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color bg, border, text;
    final IconData? icon;
    final String label;

    switch (slot.status) {
      case SlotStatus.available:
        bg = Colors.white;
        border = AppColors.doctorAccent.withValues(alpha: 0.5);
        text = AppColors.doctorAccent;
        icon = null;
        label = slot.time;
      case SlotStatus.booked:
        bg = AppColors.doctorPrimary.withValues(alpha: 0.1);
        border = AppColors.doctorPrimary;
        text = AppColors.doctorPrimary;
        icon = Icons.person_rounded;
        label = slot.time;
      case SlotStatus.blocked:
        bg = Colors.grey.shade100;
        border = Colors.grey.shade300;
        text = AppColors.slate400;
        icon = Icons.block_rounded;
        label = slot.time;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1.2),
          boxShadow: slot.status == SlotStatus.available
              ? [
                  BoxShadow(
                    color: AppColors.doctorAccent.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 12, color: text),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
            Text(
              slot.status == SlotStatus.available
                  ? 'open'
                  : slot.status == SlotStatus.booked
                      ? 'booked'
                      : 'blocked',
              style: TextStyle(
                fontSize: 9,
                color: text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholders ──────────────────────────────────────────────────────────────

class _DayOffPlaceholder extends StatelessWidget {
  final VoidCallback onOpen;
  const _DayOffPlaceholder({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_busy_rounded,
                  size: 40, color: AppColors.slate400),
            ),
            const SizedBox(height: 16),
            const Text('Day Off',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'You\'re not accepting appointments\non this day.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate400, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.toggle_on_rounded, size: 18),
              label: const Text('Open This Day'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlots extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySlots({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded,
              size: 48, color: AppColors.slate400),
          const SizedBox(height: 12),
          const Text('No slots yet',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Tap + to add time slots for this day.',
              style:
                  TextStyle(color: AppColors.slate400, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Slots'),
          ),
        ],
      ),
    );
  }
}
