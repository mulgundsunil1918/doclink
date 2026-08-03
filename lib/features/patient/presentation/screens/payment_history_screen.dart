import 'package:flutter/material.dart';
import '../../../../shared/widgets/dl_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(patientPaymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.patientSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Payment History',
            style:
                TextStyle(color: AppColors.slate800, fontWeight: FontWeight.w700)),
      ),
      body: paymentsAsync.when(
        loading: () =>
            const Center(child: DlLoader()),
        error: (_, __) =>
            const Center(child: Text('Failed to load payments')),
        data: (payments) {
          if (payments.isEmpty) {
            return _EmptyState();
          }

          final totalSpent = payments
              .where((p) => p.status == 'success')
              .fold(0.0, (s, p) => s + p.amount);
          final totalRefunded = payments
              .where((p) => p.status == 'refunded')
              .fold(0.0, (s, p) => s + p.amount);
          final thisYear = payments
              .where((p) =>
                  p.status == 'success' &&
                  p.createdAt.year == DateTime.now().year)
              .fold(0.0, (s, p) => s + p.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Summary card
                DlCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Spent',
                                style: TextStyle(
                                    color: AppColors.slate500, fontSize: 12)),
                            Text('₹${totalSpent.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: AppColors.patientPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800)),
                            Text('${payments.length} transaction${payments.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: AppColors.slate500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _SmallStat(
                            label: 'Refunded',
                            value: '₹${totalRefunded.toStringAsFixed(0)}',
                            color: const Color(0xFFD97706),
                          ),
                          const SizedBox(height: 8),
                          _SmallStat(
                            label: 'This Year',
                            value: '₹${thisYear.toStringAsFixed(0)}',
                            color: const Color(0xFF059669),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...payments.map((p) => _PaymentCard(payment: p)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded,
              size: 64, color: AppColors.slate200),
          const SizedBox(height: 16),
          const Text('No payments yet',
              style: TextStyle(
                  color: AppColors.slate600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Your payment history will appear here.',
              style: TextStyle(color: AppColors.slate400, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final AppPayment payment;
  const _PaymentCard({required this.payment});

  Color get _statusColor {
    switch (payment.status) {
      case 'success':
        return const Color(0xFF059669);
      case 'refunded':
        return const Color(0xFFD97706);
      case 'failed':
        return const Color(0xFFDC2626);
      default:
        return AppColors.slate400;
    }
  }

  String get _typLabel {
    switch (payment.appointmentType) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'chat':
        return 'Chat';
      case 'in_person':
        return 'In-Person';
      default:
        return 'Consultation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        payment.status[0].toUpperCase() + payment.status.substring(1);

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
                  color:
                      AppColors.patientPrimary.withValues(alpha: 0.1),
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
                    Text(payment.doctorName ?? 'Doctor',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            fontSize: 14)),
                    Text('$_typLabel • ${payment.formattedDate}',
                        style: const TextStyle(
                            color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${payment.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                          fontSize: 16)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
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
              const Icon(Icons.payment_rounded,
                  size: 14, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(payment.method.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.slate500, fontSize: 12)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'ID: ${payment.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                      color: AppColors.slate400, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
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
  const _SmallStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label,
            style: const TextStyle(
                color: AppColors.slate500, fontSize: 11)),
      ],
    );
  }
}
