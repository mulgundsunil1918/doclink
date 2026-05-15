import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _step = 0; // 0=doctor, 1=type, 2=slot, 3=payment, 4=confirm
  String _selectedType = '';
  String _selectedSlot = '';
  bool _paymentDone = false;

  static const _consultTypes = [
    (icon: Icons.videocam_rounded, label: 'Video', fee: '₹1,000', color: AppColors.doctorPrimary),
    (icon: Icons.call_rounded, label: 'Audio', fee: '₹750', color: Color(0xFF7C3AED)),
    (icon: Icons.chat_rounded, label: 'Chat', fee: '₹500', color: AppColors.doctorAccent),
    (icon: Icons.local_hospital_rounded, label: 'In-Person', fee: '₹500', color: AppColors.warning),
  ];

  static const _slots = [
    '09:00 AM', '09:20 AM', '09:40 AM',
    '10:00 AM', '10:20 AM', '10:40 AM',
    '11:00 AM', '04:00 PM', '04:20 PM',
    '04:40 PM', '05:00 PM', '05:20 PM',
  ];
  static const _bookedSlots = ['09:00 AM', '09:20 AM', '09:40 AM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: AppColors.patientSurface,
        title: Text(
          ['Doctor', 'Consultation Type', 'Select Slot',
           'Payment', 'Confirmed!'][_step.clamp(0, 4)],
          style: const TextStyle(color: AppColors.slate900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate700),
          onPressed: _step > 0
              ? () => setState(() => _step--)
              : () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      0 => _DoctorCard(doc: MockData.doctor, onNext: () => setState(() => _step = 1)),
      1 => _TypeSelector(
          types: _consultTypes,
          selected: _selectedType,
          onSelect: (t) => setState(() {
            _selectedType = t;
            _step = 2;
          }),
        ),
      2 => _SlotPicker(
          slots: _slots,
          bookedSlots: _bookedSlots,
          selected: _selectedSlot,
          onSelect: (s) => setState(() {
            _selectedSlot = s;
            _step = 3;
          }),
        ),
      3 => _PaymentStep(
          type: _selectedType,
          slot: _selectedSlot,
          onPay: () {
            setState(() {
              _paymentDone = true;
              _step = 4;
            });
          },
        ),
      _ => _ConfirmStep(
          doc: MockData.doctor,
          type: _selectedType,
          slot: _selectedSlot,
          onDone: () => context.go('/patient/home'),
          onJoin: () => context.push('/call'),
        ),
    };
  }
}

class _DoctorCard extends StatelessWidget {
  final MockDoctor doc;
  final VoidCallback onNext;
  const _DoctorCard({required this.doc, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.patientBorder, width: 0.5),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.1),
                child: Text(
                  doc.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.patientPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(doc.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                      fontSize: 18)),
              Text(doc.specialty,
                  style: const TextStyle(
                      color: AppColors.patientPrimary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 16),
                  Text(' ${doc.rating}  ·  ${doc.experience} yrs  ·  ${doc.city}',
                      style: const TextStyle(
                          color: AppColors.slate500, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Pill(Icons.verified_user_rounded, 'KYC Verified', AppColors.doctorAccent),
                  _Pill(Icons.language_rounded, 'Hindi, English', AppColors.doctorPrimary),
                  _Pill(Icons.people_rounded, '${doc.totalPatients}+ Patients',
                      const Color(0xFF7C3AED)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.patientPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Book Appointment'),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final List<({IconData icon, String label, String fee, Color color})> types;
  final String selected;
  final ValueChanged<String> onSelect;
  const _TypeSelector({required this.types, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
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
                                fontSize: selected == t.label ? 15 : 14,
                              )),
                          const Text('Available today',
                              style: TextStyle(
                                  color: AppColors.doctorAccent, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(t.fee,
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
  final String selected;
  final ValueChanged<String> onSelect;
  const _SlotPicker(
      {required this.slots, required this.bookedSlots,
       required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available slots — Today',
            style: TextStyle(
                color: AppColors.slate700, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        const Text('14 May 2026 · Dr. Arjun Mehta',
            style: TextStyle(color: AppColors.slate400, fontSize: 12)),
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
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.slate500)),
      ],
    );
  }
}

class _PaymentStep extends StatefulWidget {
  final String type, slot;
  final VoidCallback onPay;
  const _PaymentStep({required this.type, required this.slot, required this.onPay});

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  String _method = 'UPI';
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final fee = {'Video': 1000, 'Audio': 750, 'Chat': 500, 'In-Person': 500}[widget.type] ?? 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.patientBorder, width: 0.5),
          ),
          child: Column(
            children: [
              _SummaryRow('Doctor', 'Dr. Arjun Mehta'),
              _SummaryRow('Type', '${widget.type} Consultation'),
              _SummaryRow('Slot', widget.slot),
              _SummaryRow('Date', '14 May 2026'),
              const Divider(height: 20, color: AppColors.patientBorder),
              Row(
                children: [
                  const Expanded(
                    child: Text('Consultation Fee',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.slate900)),
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

        const Text('Payment Method',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.slate700, fontSize: 14)),
        const SizedBox(height: 10),

        ...['UPI', 'Card', 'NetBanking', 'Wallet'].map((m) => GestureDetector(
              onTap: () => setState(() => _method = m),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _method == m
                        ? AppColors.patientPrimary
                        : AppColors.patientBorder,
                    width: _method == m ? 2 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      switch (m) {
                        'UPI' => Icons.qr_code_rounded,
                        'Card' => Icons.credit_card_rounded,
                        'NetBanking' => Icons.account_balance_rounded,
                        _ => Icons.account_balance_wallet_rounded,
                      },
                      color: _method == m
                          ? AppColors.patientPrimary
                          : AppColors.slate400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(m,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _method == m
                                ? AppColors.patientPrimary
                                : AppColors.slate700,
                          )),
                    ),
                    if (_method == m)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.patientPrimary, size: 18),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _paying ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.patientPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: _paying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Pay ₹$fee via $_method'),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Secured by Razorpay · 256-bit SSL',
              style: TextStyle(color: AppColors.slate400, fontSize: 11)),
        ),
      ],
    );
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _paying = false);
      widget.onPay();
    }
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
                style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
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
  final MockDoctor doc;
  final String type, slot;
  final VoidCallback onDone, onJoin;
  const _ConfirmStep({
    required this.doc,
    required this.type,
    required this.slot,
    required this.onDone,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
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
        Text('Payment successful · Appointment with ${doc.name}',
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
              _SummaryRow('Doctor', doc.name),
              _SummaryRow('Specialty', doc.specialty),
              _SummaryRow('Type', '$type Consultation'),
              _SummaryRow('Date', '14 May 2026'),
              _SummaryRow('Time', slot),
              _SummaryRow('Token', '#007'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('📱 Prescription & call link sent via WhatsApp',
            style: TextStyle(color: AppColors.doctorAccent, fontSize: 12)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.patientPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.videocam_rounded),
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
