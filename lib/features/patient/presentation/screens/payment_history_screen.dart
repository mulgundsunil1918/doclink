import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  static const _payments = [
    _Payment(
      id: 'PAY001',
      doctor: 'Dr. Arjun Mehta',
      type: 'Video',
      amount: 1000,
      date: '12 Mar 2025',
      method: 'UPI',
      status: 'success',
    ),
    _Payment(
      id: 'PAY002',
      doctor: 'Dr. Arjun Mehta',
      type: 'Audio',
      amount: 750,
      date: '5 Feb 2025',
      method: 'Card',
      status: 'success',
    ),
    _Payment(
      id: 'PAY003',
      doctor: 'Dr. Arjun Mehta',
      type: 'Chat',
      amount: 500,
      date: '20 Jan 2025',
      method: 'Wallet',
      status: 'success',
    ),
    _Payment(
      id: 'PAY004',
      doctor: 'Dr. Arjun Mehta',
      type: 'Video',
      amount: 1000,
      date: '3 Jan 2025',
      method: 'UPI',
      status: 'refunded',
    ),
    _Payment(
      id: 'PAY005',
      doctor: 'Dr. Arjun Mehta',
      type: 'In-Person',
      amount: 500,
      date: '15 Dec 2024',
      method: 'Cash',
      status: 'success',
    ),
  ];

  int get _totalSpent =>
      _payments.where((p) => p.status == 'success').fold(0, (s, p) => s + p.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Payment History',
            style: TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.patientPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Summary
            DlCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Spent',
                            style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                        Text('₹$_totalSpent',
                            style: const TextStyle(
                                color: AppColors.patientPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                        Text('${_payments.length} consultations',
                            style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _SmallStat(
                        label: 'Refunded',
                        value: '₹${_payments.where((p) => p.status == 'refunded').fold(0, (s, p) => s + p.amount)}',
                        color: const Color(0xFFD97706),
                      ),
                      const SizedBox(height: 8),
                      _SmallStat(
                        label: 'This Year',
                        value: '₹${_payments.where((p) => p.status == 'success' && p.date.contains('2025')).fold(0, (s, p) => s + p.amount)}',
                        color: const Color(0xFF059669),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._payments.map((p) => _PaymentCard(payment: p)),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final _Payment payment;
  const _PaymentCard({required this.payment});

  Color get _statusColor {
    switch (payment.status) {
      case 'success': return const Color(0xFF059669);
      case 'refunded': return const Color(0xFFD97706);
      case 'failed': return const Color(0xFFDC2626);
      default: return AppColors.slate400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DlCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.patientPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.patientPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.doctor,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: AppColors.slate800, fontSize: 14)),
                    Text('${payment.type} • ${payment.date}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${payment.amount}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                          fontSize: 16)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      payment.status[0].toUpperCase() + payment.status.substring(1),
                      style: TextStyle(
                          color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.payment_rounded, size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(payment.method,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
              const SizedBox(width: 12),
              Text('ID: ${payment.id}',
                  style: const TextStyle(color: AppColors.slate400, fontSize: 11)),
              const Spacer(),
              if (payment.status == 'success')
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.patientPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text('Receipt', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SmallStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label, style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
      ],
    );
  }
}

class _Payment {
  final String id, doctor, type, date, method, status;
  final int amount;
  const _Payment({
    required this.id,
    required this.doctor,
    required this.type,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });
}
