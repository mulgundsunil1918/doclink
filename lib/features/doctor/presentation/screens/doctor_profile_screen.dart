import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doc = MockData.doctor;
    final qrData = 'https://doclink.app/doc/${doc.id}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile header
            DlCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.doctorPrimary.withValues(alpha: 0.15),
                        child: Text(
                          doc.name.split(' ').map((w) => w[0]).take(2).join(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.doctorPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.doctorAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.doctorCard, width: 2),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(doc.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(doc.specialty,
                      style: const TextStyle(color: AppColors.doctorAccent, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      Text(' ${doc.rating}  ·  ${doc.experience} yrs exp  ·  ${doc.city}',
                          style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat('${doc.totalPatients}', 'Patients'),
                      _Stat('${doc.patientsToday}', 'Today'),
                      _Stat('7 yrs', 'Experience'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR Code card
            DlCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: AppColors.doctorPrimary),
                      const SizedBox(width: 8),
                      Text('My Booking QR',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile link copied!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copy Link', style: TextStyle(fontSize: 12)),
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
                  Text(
                    'Patients scan this to book a consultation',
                    style: const TextStyle(color: AppColors.slate400, fontSize: 12),
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

            // Consultation modes
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Modes & Fees',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...[
                    (Icons.videocam_rounded, 'Video Consultation', '₹1,000', AppColors.doctorPrimary),
                    (Icons.call_rounded, 'Audio Consultation', '₹750', const Color(0xFF7C3AED)),
                    (Icons.chat_rounded, 'Chat Consultation', '₹500', AppColors.doctorAccent),
                    (Icons.local_hospital_rounded, 'In-Person', '₹500', AppColors.warning),
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

            // Registration info
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration Details',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _InfoRow('Reg. Number', doc.regNumber),
                  _InfoRow('Specialty', doc.specialty),
                  _InfoRow('Location', doc.city),
                  _InfoRow('KYC Status', 'Verified ✓'),
                ],
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
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
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
                style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
