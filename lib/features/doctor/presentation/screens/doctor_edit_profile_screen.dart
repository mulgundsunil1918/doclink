import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';

class DoctorEditProfileScreen extends ConsumerStatefulWidget {
  final AppDoctor doc;
  const DoctorEditProfileScreen({super.key, required this.doc});

  @override
  ConsumerState<DoctorEditProfileScreen> createState() =>
      _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState
    extends ConsumerState<DoctorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late bool _available;

  // controllers — one per editable field
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _specialty;
  late final TextEditingController _regNo;
  late final TextEditingController _city;
  late final TextEditingController _clinic;
  late final TextEditingController _bio;
  late final TextEditingController _whatsapp;
  late final TextEditingController _upiId;
  late final TextEditingController _fee;

  @override
  void initState() {
    super.initState();
    final d = widget.doc;
    _name = TextEditingController(text: d.name);
    _phone = TextEditingController(text: d.phone ?? '');
    _specialty = TextEditingController(text: d.specialty);
    _regNo = TextEditingController(text: d.registrationNo ?? '');
    _city = TextEditingController(text: d.city ?? '');
    _clinic = TextEditingController(text: d.clinicName ?? '');
    _bio = TextEditingController(text: d.bio ?? '');
    _whatsapp = TextEditingController(text: d.whatsappNumber ?? '');
    _upiId = TextEditingController(text: d.upiId ?? '');
    _fee =
        TextEditingController(text: d.consultationFee.toStringAsFixed(0));
    _available = d.available;
  }

  @override
  void dispose() {
    for (final c in [
      _name, _phone, _specialty, _regNo, _city, _clinic, _bio, _whatsapp, _upiId, _fee
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await updateDoctorProfile(
        uid: widget.doc.id,
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        specialty:
            _specialty.text.trim().isEmpty ? null : _specialty.text.trim(),
        registrationNo:
            _regNo.text.trim().isEmpty ? null : _regNo.text.trim(),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        clinicName: _clinic.text.trim().isEmpty ? null : _clinic.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        whatsappNumber:
            _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
        upiId: _upiId.text.trim().isEmpty ? null : _upiId.text.trim(),
        consultationFee: double.tryParse(_fee.text.trim()),
        available: _available,
      );
      ref.invalidate(currentDoctorProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeVal = double.tryParse(_fee.text) ?? widget.doc.consultationFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Section(label: 'Personal'),
            _Field(
              controller: _name,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            _Field(
              controller: _phone,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 8),
            _Section(label: 'Professional'),
            _Field(
              controller: _specialty,
              label: 'Specialty',
              icon: Icons.medical_services_outlined,
              hint: 'e.g. Cardiologist, General Physician',
            ),
            _Field(
              controller: _regNo,
              label: 'Registration Number',
              icon: Icons.badge_outlined,
              hint: 'MCI / State council number',
            ),
            _Field(
              controller: _clinic,
              label: 'Clinic / Hospital Name',
              icon: Icons.local_hospital_outlined,
            ),
            _Field(
              controller: _city,
              label: 'City / Location',
              icon: Icons.location_on_outlined,
            ),
            _Field(
              controller: _bio,
              label: 'Bio / About',
              icon: Icons.info_outline,
              maxLines: 4,
              hint: 'Brief description for patients',
            ),

            const SizedBox(height: 8),
            _Section(label: 'Consultation Rates'),
            _Field(
              controller: _fee,
              label: 'Base Consultation Fee (₹)',
              icon: Icons.currency_rupee_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              hint: '500',
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            _RatePreview(fee: feeVal),

            const SizedBox(height: 8),
            _Section(label: 'Availability'),
            _SwitchRow(
              label: 'Accepting Appointments',
              subtitle: _available
                  ? 'You are visible to patients'
                  : 'You are hidden from patients',
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),

            const SizedBox(height: 8),
            _Section(label: 'Contact & Payout'),
            _Field(
              controller: _whatsapp,
              label: 'WhatsApp Number',
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
              hint: '91XXXXXXXXXX',
            ),
            _Field(
              controller: _upiId,
              label: 'UPI Payout ID',
              icon: Icons.account_balance_wallet_outlined,
              hint: 'yourname@paytm',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            const Text(
              'Patients will send payment to your UPI ID when you receive payouts.',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.doctorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Profile',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.doctorPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ── Text field ─────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppColors.slate400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.doctorPrimary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ── Rate preview ───────────────────────────────────────────────────────────────
class _RatePreview extends StatelessWidget {
  final double fee;
  const _RatePreview({required this.fee});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.videocam_rounded, 'Video', fee, AppColors.doctorPrimary),
      (Icons.call_rounded, 'Audio', fee * 0.75, const Color(0xFF7C3AED)),
      (Icons.chat_rounded, 'Chat', fee * 0.5, AppColors.doctorAccent),
      (Icons.local_hospital_rounded, 'In-Person', fee * 0.5, AppColors.warning),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.doctorPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.doctorPrimary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Derived rates (auto-calculated)',
              style: TextStyle(
                  color: AppColors.slate400,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(r.$1, size: 16, color: r.$4),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(r.$2,
                            style: const TextStyle(fontSize: 12))),
                    Text('₹${r.$3.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: r.$4)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Switch row ─────────────────────────────────────────────────────────────────
class _SwitchRow extends StatelessWidget {
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: value ? AppColors.doctorAccent : AppColors.slate400,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.slate400, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.doctorAccent,
          ),
        ],
      ),
    );
  }
}
