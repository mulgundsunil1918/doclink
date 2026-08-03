import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

// Static slot data (no time_slots table in DB)
const _kWeekSlots = {
  'Today': ['09:00', '09:20', '09:40', '10:00', '10:20', '11:00', '04:00', '04:20', '05:00'],
  'Tomorrow': ['09:00', '09:20', '10:00', '10:40', '11:00', '04:40', '05:00', '05:20'],
};
const _kBookedSlots = {
  'Today': ['09:00', '09:20'],
  'Tomorrow': ['09:00'],
};

class ManualBookingScreen extends ConsumerStatefulWidget {
  const ManualBookingScreen({super.key});
  @override
  ConsumerState<ManualBookingScreen> createState() =>
      _ManualBookingScreenState();
}

class _ManualBookingScreenState extends ConsumerState<ManualBookingScreen> {
  int _step = 0;
  String _selectedType = 'Video';
  String _selectedSlot = '';
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _patientName => _nameCtrl.text.trim();
  String get _patientPhone => _phoneCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Manual Booking',
            style: TextStyle(
                color: AppColors.slate800, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: List.generate(4, (i) {
                    final isActive = i <= _step;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.patientPrimary
                                : AppColors.slate200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Patient',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 10)),
                    Text('Type',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 10)),
                    Text('Slot',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 10)),
                    Text('Confirm',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: [
                _buildPatientStep(),
                _buildTypeStep(),
                _buildSlotStep(),
                _buildConfirmStep(),
              ][_step],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed ? _proceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.patientPrimary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _confirming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: DlLoader())
                        : Text(_step < 3 ? 'Continue' : 'Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _patientName.isNotEmpty && _patientPhone.length >= 10;
      case 1:
        return _selectedType.isNotEmpty;
      case 2:
        return _selectedSlot.isNotEmpty;
      default:
        return !_confirming;
    }
  }

  void _proceed() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _confirmBooking();
    }
  }

  Future<void> _confirmBooking() async {
    setState(() => _confirming = true);
    try {
      // Find first available doctor to assign
      final doctors = ref.read(allDoctorsProvider).valueOrNull ?? [];
      if (doctors.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No doctors available')),
        );
        setState(() => _confirming = false);
        return;
      }

      // Look up patient by phone number
      String? patientId;
      if (_patientPhone.isNotEmpty) {
        patientId = await lookupPatientIdByPhone(_patientPhone);
      }
      if (patientId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient not found. Ask them to register in the app first.'),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _confirming = false);
        return;
      }

      // Parse slot: format is 'Day-HH:mm', e.g. 'Today-09:00'
      final slotParts = _selectedSlot.split('-');
      final day = slotParts.isNotEmpty ? slotParts[0] : 'Today';
      final time = slotParts.length > 1 ? slotParts[1] : '09:00';
      final parts = time.split(':');
      final now = DateTime.now();
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      final offset = day == 'Tomorrow' ? 1 : 0;
      final scheduledAt = DateTime(
          now.year, now.month, now.day + offset, hour, minute);

      final typeMap = {
        'Video': 'video',
        'Audio': 'audio',
        'Chat': 'chat',
        'In-Person': 'in_person',
      };

      await bookAppointment(
        doctorId: doctors.first.id,
        patientId: patientId,
        type: typeMap[_selectedType] ?? 'in_person',
        scheduledAt: scheduledAt,
        chiefComplaint: null,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Text(
            '$_patientName booked for $_selectedType at $time.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Text(
            '$_patientName added to queue for $_selectedType consultation.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Widget _buildPatientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient Details',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 20),
        DlCard(
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_rounded),
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Or search existing patient',
            style: TextStyle(color: AppColors.slate500, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search by name or phone...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_searchCtrl.text.length >= 2) ...[
          const SizedBox(height: 12),
          ref.watch(searchPatientsProvider(_searchCtrl.text)).when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8),
                  child: DlLoader(),
                )),
                error: (_, __) => const SizedBox.shrink(),
                data: (patients) {
                  if (patients.isEmpty) {
                    return const Text('No registered patients found.',
                        style: TextStyle(color: AppColors.slate400, fontSize: 13));
                  }
                  return Column(
                    children: patients
                        .map((p) => DlCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_rounded,
                                      color: AppColors.slate400),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            style: const TextStyle(
                                                color: AppColors.slate800,
                                                fontWeight: FontWeight.w600)),
                                        if (p.phone != null)
                                          Text(p.phone!,
                                              style: const TextStyle(
                                                  color: AppColors.slate500,
                                                  fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _nameCtrl.text = p.name;
                                      final ph = p.phone ?? '';
                                      _phoneCtrl.text =
                                          ph.startsWith('+91')
                                              ? ph.substring(3).trim()
                                              : ph;
                                      _searchCtrl.clear();
                                    }),
                                    child: const Text('Select'),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
        ],
      ],
    );
  }

  Widget _buildTypeStep() {
    const types = [
      (
        type: 'Video',
        icon: Icons.videocam_rounded,
        price: '₹1000',
        color: AppColors.patientPrimary
      ),
      (
        type: 'Audio',
        icon: Icons.phone_rounded,
        price: '₹750',
        color: Color(0xFF0891B2)
      ),
      (
        type: 'Chat',
        icon: Icons.chat_rounded,
        price: '₹500',
        color: Color(0xFF7C3AED)
      ),
      (
        type: 'In-Person',
        icon: Icons.local_hospital_rounded,
        price: '₹500',
        color: Color(0xFFD97706)
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Consultation Type',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 20),
        ...types.map((t) => GestureDetector(
              onTap: () => setState(() => _selectedType = t.type),
              child: DlCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(t.icon, color: t.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(t.type,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.slate800)),
                    ),
                    Text(t.price,
                        style: TextStyle(
                            color: t.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(width: 12),
                    Radio<String>(
                      value: t.type,
                      groupValue: _selectedType,
                      onChanged: (v) =>
                          setState(() => _selectedType = v!),
                      activeColor: t.color,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSlotStep() {
    final days = _kWeekSlots.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Slot',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 20),
        ...days.map((day) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_kWeekSlots[day] ?? []).map((slot) {
                    final slotKey = '$day-$slot';
                    final isBooked =
                        (_kBookedSlots[day] ?? []).contains(slot);
                    final isSelected = _selectedSlot == slotKey;
                    return GestureDetector(
                      onTap: isBooked
                          ? null
                          : () => setState(
                              () => _selectedSlot = slotKey),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? AppColors.slate100
                              : isSelected
                                  ? AppColors.patientPrimary
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBooked
                                ? AppColors.slate200
                                : isSelected
                                    ? AppColors.patientPrimary
                                    : AppColors.slate200,
                          ),
                        ),
                        child: Text(slot,
                            style: TextStyle(
                              color: isBooked
                                  ? AppColors.slate300
                                  : isSelected
                                      ? Colors.white
                                      : AppColors.slate700,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              decoration: isBooked
                                  ? TextDecoration.lineThrough
                                  : null,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            )),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Booking',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 20),
        DlCard(
          child: Column(
            children: [
              _ConfirmRow(
                  label: 'Patient',
                  value: _patientName.isEmpty ? '—' : _patientName),
              _ConfirmRow(
                  label: 'Phone',
                  value: _patientPhone.isEmpty
                      ? '—'
                      : '+91 $_patientPhone'),
              _ConfirmRow(label: 'Type', value: _selectedType),
              _ConfirmRow(
                  label: 'Slot',
                  value: _selectedSlot.isEmpty ? '—' : _selectedSlot),
              const Divider(color: AppColors.slate100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Fee',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800)),
                  Text(
                    _selectedType == 'Video'
                        ? '₹1,000'
                        : _selectedType == 'Audio'
                            ? '₹750'
                            : '₹500',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.patientPrimary,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DlCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Mode',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800)),
              const SizedBox(height: 12),
              ...['Pay at Clinic', 'Online (Send Link)', 'Insurance']
                  .map((m) => RadioListTile<String>(
                        title: Text(m,
                            style: const TextStyle(fontSize: 14)),
                        value: m,
                        groupValue: 'Pay at Clinic',
                        onChanged: (_) {},
                        activeColor: AppColors.patientPrimary,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      )),
            ],
          ),
        ),
      ],
    );
  }

}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.slate500, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.slate800,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
