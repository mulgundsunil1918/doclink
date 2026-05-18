import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';
import 'doctor_edit_profile_screen.dart';
import 'prescription_template_settings_screen.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    return doctorAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _buildScaffold(context, ref, null),
      data: (doc) => _buildScaffold(context, ref, doc),
    );
  }

  // Returns a stub AppDoctor so the edit screen can be opened even before
  // the profile is fully loaded or the doctors row exists in Supabase.
  AppDoctor _stubDoctor(WidgetRef ref) {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    return AppDoctor(
      id: profile?.id ?? '',
      name: profile?.name ?? 'Doctor',
      specialty: 'General Physician',
      consultationFee: 500,
      rating: 0,
      earningsToday: 0,
      earningsMonth: 0,
      totalPatients: 0,
      available: true,
      kycVerified: false,
    );
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, AppDoctor? doc) {
    final initials = doc?.initials ?? 'DR';
    final qrData =
        'https://doclink.app/doc/${doc?.id ?? 'unknown'}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DoctorEditProfileScreen(doc: doc ?? _stubDoctor(ref)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            DlCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            AppColors.doctorPrimary.withValues(alpha: 0.15),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.doctorPrimary,
                          ),
                        ),
                      ),
                      if (doc?.kycVerified == true)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.doctorAccent,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.doctorCard, width: 2),
                          ),
                          child: const Icon(Icons.verified,
                              color: Colors.white, size: 14),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(doc?.name ?? 'Doctor',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(doc?.specialty ?? 'General Physician',
                      style: const TextStyle(
                          color: AppColors.doctorAccent, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 16),
                      Text(
                          ' ${doc?.rating.toStringAsFixed(1) ?? '—'}  ·  ${doc?.city ?? ''}',
                          style: const TextStyle(
                              color: AppColors.slate400, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat('${doc?.totalPatients ?? 0}', 'Patients'),
                      _Stat(
                          doc?.rating.toStringAsFixed(1) ?? '—', 'Rating'),
                      _Stat(
                          doc?.kycVerified == true ? 'Yes' : 'Pending',
                          'KYC'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            DlCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded,
                          color: AppColors.doctorPrimary),
                      const SizedBox(width: 8),
                      Text('My Booking QR',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profile link copied!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copy Link',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Patients scan this to book a consultation',
                    style:
                        TextStyle(color: AppColors.slate400, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(qrData,
                      style: const TextStyle(
                        color: AppColors.doctorPrimary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share QR'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Download'),
                        ),
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
                  Text('Consultation Modes & Fees',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...[
                    (Icons.videocam_rounded, 'Video Consultation',
                        '₹${doc?.consultationFee.toStringAsFixed(0) ?? '—'}',
                        AppColors.doctorPrimary),
                    (Icons.call_rounded, 'Audio Consultation',
                        '₹${((doc?.consultationFee ?? 500) * 0.75).toStringAsFixed(0)}',
                        const Color(0xFF7C3AED)),
                    (Icons.chat_rounded, 'Chat Consultation',
                        '₹${((doc?.consultationFee ?? 500) * 0.5).toStringAsFixed(0)}',
                        AppColors.doctorAccent),
                    (Icons.local_hospital_rounded, 'In-Person',
                        '₹${((doc?.consultationFee ?? 500) * 0.5).toStringAsFixed(0)}',
                        AppColors.warning),
                  ].map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: m.$4.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(m.$1, color: m.$4, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(m.$2,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Text(m.$3,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.doctorAccent,
                                )),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration Details',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _InfoRow('Reg. Number', doc?.registrationNo ?? '—'),
                  _InfoRow('Specialty', doc?.specialty ?? '—'),
                  if (doc?.city != null) _InfoRow('Location', doc!.city!),
                  if (doc?.clinicName != null)
                    _InfoRow('Clinic', doc!.clinicName!),
                  _InfoRow('KYC Status',
                      doc?.kycVerified == true ? 'Verified ✓' : 'Pending'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // UPI ID card
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: AppColors.doctorAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('UPI Payout ID',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showUpiEditSheet(context, ref, doc?.upiId),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(doc?.upiId == null ? 'Add' : 'Edit'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.doctorPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (doc?.upiId != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.doctorAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.doctorAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.currency_rupee_rounded,
                              size: 16, color: AppColors.doctorAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              doc!.upiId!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                size: 18, color: AppColors.slate400),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: doc.upiId!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('UPI ID copied')),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Patients\' payments will be routed to this UPI ID when you withdraw.',
                      style: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 11,
                          height: 1.4),
                    ),
                  ] else
                    const Text(
                      'Add your UPI ID so you can receive payouts directly to your bank.',
                      style: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 12,
                          height: 1.4),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prescription Template
            DlCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.doctorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: AppColors.doctorPrimary, size: 20),
                ),
                title: const Text('Prescription Template',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text(
                    'Clinic header, colours, defaults & sections',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.slate400),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PrescriptionTemplateSettingsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpiEditSheet(
      BuildContext context, WidgetRef ref, String? current) {
    final ctrl = TextEditingController(text: current ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your UPI ID',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Enter your UPI ID (e.g. name@paytm, 9876543210@ybl)',
              style:
                  TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'yourname@paytm',
                prefixIcon: const Icon(Icons.currency_rupee_rounded,
                    color: AppColors.doctorAccent),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.doctorPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final upi = ctrl.text.trim();
                  if (upi.isEmpty) return;
                  await updateDoctorUpiId(upi);
                  ref.invalidate(currentDoctorProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('UPI ID saved successfully')),
                    );
                  }
                },
                child: const Text('Save UPI ID'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.slate400, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
