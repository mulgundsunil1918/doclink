import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/payment/upi_payment_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  int _step = 0; // 0=doctor, 1=type, 2=slot, 3=payment, 4=confirm
  AppDoctor? _selectedDoctor;
  String _selectedType = '';
  String _selectedSlot = '';
  String? _bookedAppointmentId;

  static const _consultTypes = [
    (
      icon: Icons.videocam_rounded,
      label: 'Video',
      type: 'video',
      color: AppColors.doctorPrimary
    ),
    (
      icon: Icons.call_rounded,
      label: 'Audio',
      type: 'audio',
      color: Color(0xFF7C3AED)
    ),
    (
      icon: Icons.chat_rounded,
      label: 'Chat',
      type: 'chat',
      color: AppColors.doctorAccent
    ),
    (
      icon: Icons.local_hospital_rounded,
      label: 'In-Person',
      type: 'in_person',
      color: AppColors.warning
    ),
  ];

  List<String> _realSlots = const [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];
  List<String> _realBooked = const [];
  bool _loadingSlots = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: AppColors.patientSurface,
        title: Text(
          ['Select Doctor', 'Consultation Type', 'Select Slot', 'Payment',
              'Confirmed!'][_step.clamp(0, 4)],
          style: const TextStyle(color: AppColors.slate900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.slate700),
          onPressed:
              _step > 0 ? () => setState(() => _step--) : () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: List.generate(5, (i) {
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || active
                                ? AppColors.patientPrimary
                                : AppColors.patientBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (i < 4) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _DoctorSelector(
          onSelect: (doc) {
            setState(() {
              _selectedDoctor = doc;
              _step = 1;
            });
            _loadSlots(doc);
          },
        ),
      1 => _TypeSelector(
          types: _consultTypes,
          selected: _selectedType,
          doctorFee: _selectedDoctor?.consultationFee ?? 500,
          onSelect: (t) => setState(() {
            _selectedType = t;
            _step = 2;
          }),
        ),
      2 => _loadingSlots
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          : _SlotPicker(
              slots: _realSlots,
              bookedSlots: _realBooked,
              doctorName: _selectedDoctor?.name ?? 'Doctor',
              selected: _selectedSlot,
              onSelect: (s) => setState(() {
                _selectedSlot = s;
                _step = 3;
              }),
            ),
      3 => _PaymentStep(
          type: _selectedType,
          slot: _selectedSlot,
          doctorName: _selectedDoctor?.name ?? 'Doctor',
          doctorFee: _selectedDoctor?.consultationFee ?? 500,
          doctorUpiId: _selectedDoctor?.upiId,
          onPay: _handlePayment,
          patientPhone: ref.read(currentProfileProvider).valueOrNull?.phone,
        ),
      _ => _ConfirmStep(
          doctorName: _selectedDoctor?.name ?? 'Doctor',
          doctorSpecialty: _selectedDoctor?.specialty ?? '',
          type: _selectedType,
          slot: _selectedSlot,
          appointmentId: _bookedAppointmentId,
          onDone: () => context.go('/patient'),
          onJoin: () {
            if (_selectedType == 'chat' && _bookedAppointmentId != null) {
              context.push('/patient/chat', extra: _bookedAppointmentId);
            } else {
              context.push('/patient/video-call');
            }
          },
        ),
    };
  }

  Future<void> _loadSlots(AppDoctor doctor) async {
    setState(() => _loadingSlots = true);
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final row = await fetchDoctorAvailability(
          doctorId: doctor.id, date: dateStr);
      if (row != null && row['is_open'] == true) {
        final all = (row['slots'] as List? ?? []);
        setState(() {
          _realSlots = all
              .where((s) => s['status'] != 'blocked')
              .map((s) => _to12h(s['time'] as String))
              .toList();
          _realBooked = all
              .where((s) => s['status'] == 'booked')
              .map((s) => _to12h(s['time'] as String))
              .toList();
        });
      }
      // If doctor hasn't set schedule yet — keep defaults
    } catch (_) {}
    if (mounted) setState(() => _loadingSlots = false);
  }

  String _to12h(String t) {
    final p = t.split(':');
    int h = int.parse(p[0]);
    final m = p[1];
    final period = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:$m $period';
  }

  Future<void> _handlePayment(
      String utr, String txnRef, String? paidToUpiId) async {
    final patientId = ref.read(currentProfileProvider).valueOrNull?.id;
    final doctor = _selectedDoctor;
    if (patientId == null || doctor == null) return;

    const typeMap = {
      'Video': 'video',
      'Audio': 'audio',
      'Chat': 'chat',
      'In-Person': 'in_person',
    };
    const feeMultiplier = {
      'Video': 1.0,
      'Audio': 0.75,
      'Chat': 0.5,
      'In-Person': 0.5,
    };

    final now = DateTime.now();
    final slotParts = _selectedSlot.split(' ');
    final timeParts = slotParts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (slotParts[1] == 'PM' && hour != 12) hour += 12;
    if (slotParts[1] == 'AM' && hour == 12) hour = 0;
    final scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
    final amount = doctor.consultationFee * (feeMultiplier[_selectedType] ?? 1.0);

    try {
      final id = await bookAppointment(
        doctorId: doctor.id,
        patientId: patientId,
        type: typeMap[_selectedType] ?? 'video',
        scheduledAt: scheduledAt,
        chiefComplaint: null,
      );
      if (id != null) {
        await savePayment(
          appointmentId: id,
          patientId: patientId,
          amount: amount,
          method: paidToUpiId == null ? 'cash' : 'upi',
          upiTxnRef: txnRef,
          upiUtr: utr,
          paidToUpiId: paidToUpiId,
        );
      }
      setState(() {
        _bookedAppointmentId = id;
        _step = 4;
      });
      ref.invalidate(patientAppointmentsProvider);
      ref.invalidate(patientPaymentsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _DoctorSelector extends ConsumerWidget {
  final ValueChanged<AppDoctor> onSelect;
  const _DoctorSelector({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(allDoctorsProvider);
    return docsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Failed to load doctors',
            style: TextStyle(color: AppColors.slate500)),
      ),
      data: (docs) {
        if (docs.isEmpty) {
          return const Center(
            child: Text('No doctors available',
                style: TextStyle(color: AppColors.slate500)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a doctor',
                style: TextStyle(
                    color: AppColors.slate700,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 12),
            ...docs.map((doc) => _DoctorCard(doc: doc, onNext: () => onSelect(doc))),
          ],
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final AppDoctor doc;
  final VoidCallback onNext;
  const _DoctorCard({required this.doc, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.patientBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    AppColors.patientPrimary.withValues(alpha: 0.1),
                child: Text(
                  doc.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.patientPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${doc.name}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                            fontSize: 15)),
                    Text(doc.specialty,
                        style: const TextStyle(
                            color: AppColors.patientPrimary, fontSize: 12)),
                    if (doc.city != null)
                      Text(doc.city!,
                          style: const TextStyle(
                              color: AppColors.slate400, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 14),
                      Text(' ${doc.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                              color: AppColors.slate600, fontSize: 12)),
                    ],
                  ),
                  Text('₹${doc.consultationFee.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                          fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.patientPrimary,
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final List<({IconData icon, String label, String type, Color color})> types;
  final String selected;
  final double doctorFee;
  final ValueChanged<String> onSelect;
  const _TypeSelector({
    required this.types,
    required this.selected,
    required this.doctorFee,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final feeMap = {
      'Video': doctorFee,
      'Audio': doctorFee * 0.75,
      'Chat': doctorFee * 0.5,
      'In-Person': doctorFee * 0.5,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How would you like to consult?',
            style: TextStyle(
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 16),
        ...types.map((t) => GestureDetector(
              onTap: () => onSelect(t.label),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected == t.label ? t.color : AppColors.patientBorder,
                    width: selected == t.label ? 2 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(t.icon, color: t.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate900,
                                fontSize:
                                    selected == t.label ? 15 : 14,
                              )),
                          const Text('Available today',
                              style: TextStyle(
                                  color: AppColors.doctorAccent,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                        '₹${(feeMap[t.label] ?? doctorFee).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.slate900)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _SlotPicker extends StatelessWidget {
  final List<String> slots, bookedSlots;
  final String selected, doctorName;
  final ValueChanged<String> onSelect;
  const _SlotPicker({
    required this.slots,
    required this.bookedSlots,
    required this.selected,
    required this.doctorName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available slots — Today',
            style: TextStyle(
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 4),
        Text('$dateStr · Dr. $doctorName',
            style: const TextStyle(
                color: AppColors.slate400, fontSize: 12)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) {
            final s = slots[i];
            final booked = bookedSlots.contains(s);
            final sel = s == selected;
            return GestureDetector(
              onTap: booked ? null : () => onSelect(s),
              child: Container(
                decoration: BoxDecoration(
                  color: booked
                      ? AppColors.slate100
                      : sel
                          ? AppColors.patientPrimary
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: booked
                        ? AppColors.patientBorder
                        : sel
                            ? AppColors.patientPrimary
                            : AppColors.patientBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: booked
                        ? AppColors.slate300
                        : sel
                            ? Colors.white
                            : AppColors.slate700,
                    decoration: booked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Legend(AppColors.patientPrimary, 'Selected'),
            const SizedBox(width: 16),
            _Legend(AppColors.slate300, 'Booked'),
            const SizedBox(width: 16),
            _Legend(AppColors.patientBorder, 'Available'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.slate500)),
      ],
    );
  }
}

class _PaymentStep extends StatefulWidget {
  final String type, slot, doctorName;
  final double doctorFee;
  final String? doctorUpiId;
  final String? patientPhone;

  /// Reports the patient's UTR, our transaction reference, and the VPA the
  /// money was sent to. Doclink is never in the money path, so this is a claim
  /// the doctor still has to confirm against their own bank.
  final Future<void> Function(String utr, String txnRef, String? paidToUpiId)
      onPay;
  const _PaymentStep({
    required this.type,
    required this.slot,
    required this.doctorName,
    required this.doctorFee,
    required this.doctorUpiId,
    required this.onPay,
    this.patientPhone,
  });

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  static const _feeMultiplier = {
    'Video': 1.0,
    'Audio': 0.75,
    'Chat': 0.5,
    'In-Person': 0.5,
  };

  late final String _txnRef = UpiPaymentService.newTxnRef();
  final _utrCtrl = TextEditingController();

  /// True once the patient has been handed to their UPI app (or told to pay
  /// manually) and we are waiting for them to come back with the reference.
  bool _awaitingUtr = false;
  bool _submitting = false;

  bool get _hasUpi => UpiPaymentService.isValidVpa(widget.doctorUpiId);

  double get _fee => widget.doctorFee * (_feeMultiplier[widget.type] ?? 1.0);

  @override
  void dispose() {
    _utrCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUpi() async {
    final result = await UpiPaymentService.pay(
      payeeVpa: widget.doctorUpiId,
      payeeName: 'Dr. ${widget.doctorName}',
      amount: _fee,
      note: '${widget.type} consultation',
      txnRef: _txnRef,
    );
    if (!mounted) return;

    setState(() => _awaitingUtr = true);
    if (result == UpiLaunchResult.noUpiApp) {
      _snack('No UPI app found. Send ₹${_fee.toInt()} to '
          '${widget.doctorUpiId} from any UPI app, then enter the reference.');
    }
  }

  Future<void> _submitUtr() async {
    final utr = _utrCtrl.text.trim();
    if (utr.length < 6) {
      _snack('Enter the UPI reference / UTR shown in your payment app.');
      return;
    }
    setState(() => _submitting = true);
    await widget.onPay(utr, _txnRef, widget.doctorUpiId);
    if (mounted) setState(() => _submitting = false);
  }

  /// Doctor has not set up UPI yet — book the slot and settle at the clinic.
  Future<void> _payAtClinic() async {
    setState(() => _submitting = true);
    await widget.onPay('', _txnRef, null);
    if (mounted) setState(() => _submitting = false);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.slate900),
      );

  @override
  Widget build(BuildContext context) {
    final fee = _fee.toInt();
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.patientBorder, width: 0.5),
          ),
          child: Column(
            children: [
              _SummaryRow('Doctor', 'Dr. ${widget.doctorName}'),
              _SummaryRow('Type', '${widget.type} Consultation'),
              _SummaryRow('Slot', widget.slot),
              _SummaryRow('Date', dateStr),
              const Divider(height: 20, color: AppColors.patientBorder),
              Row(
                children: [
                  const Expanded(
                    child: Text('Consultation Fee',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900)),
                  ),
                  Text('₹$fee',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.patientPrimary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Who the money actually goes to — this is a direct transfer, so the
        // patient should see the doctor's own UPI ID before they send it.
        if (_hasUpi)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.patientPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.patientPrimary.withValues(alpha: 0.2),
                  width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded,
                    color: AppColors.patientPrimary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paid directly to your doctor',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.slate900)),
                      const SizedBox(height: 2),
                      Text(widget.doctorUpiId!,
                          style: const TextStyle(
                              color: AppColors.slate600,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy UPI ID',
                  icon: const Icon(Icons.copy_rounded,
                      size: 16, color: AppColors.slate500),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.doctorUpiId!));
                    _snack('UPI ID copied');
                  },
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4), width: 0.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFF92400E), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This doctor has not set up online payments yet. You can '
                    'book now and pay at the clinic.',
                    style: TextStyle(
                        color: Color(0xFF92400E), fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Step 1: hand off to the patient's UPI app.
        if (_hasUpi && !_awaitingUtr)
          ElevatedButton(
            onPressed: _launchUpi,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.patientPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, size: 20),
                const SizedBox(width: 8),
                Text('Pay ₹$fee via UPI',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

        // Step 2: the bank tells us nothing, so the patient supplies the UTR.
        if (_hasUpi && _awaitingUtr) ...[
          TextField(
            controller: _utrCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'UPI reference / UTR',
              hintText: 'e.g. 412345678901',
              helperText: 'Shown in your UPI app next to the payment',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitting ? null : _submitUtr,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.patientPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text("I've Paid — Confirm Booking",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: _submitting ? null : _launchUpi,
            child: const Text('Re-open UPI app'),
          ),
        ],

        // Doctor has no UPI configured — book now, settle in person.
        if (!_hasUpi)
          ElevatedButton(
            onPressed: _submitting ? null : _payAtClinic,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.patientPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Book & Pay ₹$fee at Clinic',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 8),
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 12, color: AppColors.slate400),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Paid bank-to-bank via UPI. Doclink never holds your money.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.slate400, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final String doctorName, doctorSpecialty, type, slot;
  final String? appointmentId;
  final VoidCallback onDone, onJoin;
  const _ConfirmStep({
    required this.doctorName,
    required this.doctorSpecialty,
    required this.type,
    required this.slot,
    required this.appointmentId,
    required this.onDone,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.doctorAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.doctorAccent, size: 48),
        ),
        const SizedBox(height: 20),
        const Text('Booking Confirmed!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900)),
        const SizedBox(height: 8),
        Text('Appointment with Dr. $doctorName',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate500, fontSize: 13)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.patientBorder, width: 0.5),
          ),
          child: Column(
            children: [
              _SummaryRow('Doctor', 'Dr. $doctorName'),
              _SummaryRow('Specialty', doctorSpecialty),
              _SummaryRow('Type', '$type Consultation'),
              _SummaryRow('Date', dateStr),
              _SummaryRow('Time', slot),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.patientPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Join Consultation'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: onDone,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.patientBorder),
          ),
          child: const Text('Back to Home',
              style: TextStyle(color: AppColors.slate700)),
        ),
      ],
    );
  }
}
