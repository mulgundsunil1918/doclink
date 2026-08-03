import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});
  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    final monthlyAsync = ref.watch(doctorMonthlyEarningsProvider);
    final breakdownAsync = ref.watch(doctorBreakdownProvider);

    return doctorAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildScaffold(context, null, [], []),
      data: (doc) => monthlyAsync.when(
        loading: () => _buildScaffold(context, doc, [], []),
        error: (_, __) => _buildScaffold(context, doc, [], []),
        data: (monthly) => breakdownAsync.when(
          loading: () => _buildScaffold(context, doc, monthly, []),
          error: (_, __) => _buildScaffold(context, doc, monthly, []),
          data: (breakdown) =>
              _buildScaffold(context, doc, monthly, breakdown),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppDoctor? doc,
    List<({String month, double amount})> monthly,
    List<({String type, int count})> breakdown,
  ) {
    final earningsToday = doc?.earningsToday ?? 0;
    final earningsMonth = doc?.earningsMonth ?? 0;

    // Build chart data — use real monthly if available, else zeros
    final chartData = monthly.isNotEmpty
        ? monthly
        : List.generate(
            6,
            (i) {
              const labels = [
                'Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'
              ];
              final m = (DateTime.now().month - 5 + i - 1) % 12;
              return (month: labels[m], amount: 0.0);
            });

    final maxY = chartData.isEmpty
        ? 100000.0
        : (chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b) *
                1.2)
            .clamp(10000.0, double.infinity);

    // Breakdown colors by type
    const typeColors = {
      'video': Color(0xFF1D4ED8),
      'audio': Color(0xFF7C3AED),
      'chat': Color(0xFF0D9488),
      'in_person': Color(0xFFD97706),
    };
    const typeLabels = {
      'video': 'Video',
      'audio': 'Audio',
      'chat': 'Chat',
      'in_person': 'In-Person',
    };

    final totalConsults = breakdown.fold(0, (s, b) => s + b.count);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const _PendingUpiPayments(),
            Row(
              children: [
                Expanded(
                  child: DlCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${earningsToday.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.doctorAccent),
                        ),
                        const Text('from consultations',
                            style: TextStyle(
                                color: AppColors.slate500, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DlCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('This Month',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          earningsMonth >= 1000
                              ? '₹${(earningsMonth / 1000).toStringAsFixed(1)}k'
                              : '₹${earningsMonth.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.doctorPrimary),
                        ),
                        Text('${doc?.totalPatients ?? 0} total patients',
                            style: const TextStyle(
                                color: AppColors.slate500, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            DlCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.doctorAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.doctorAccent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Paid Directly To You',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 12)),
                        Text(
                          doc?.upiId ?? 'No UPI ID set',
                          style: TextStyle(
                              fontSize: doc?.upiId == null ? 15 : 18,
                              fontWeight: FontWeight.w700,
                              color: doc?.upiId == null
                                  ? AppColors.slate400
                                  : null),
                        ),
                        const Text(
                            'Doclink takes no cut — you keep 100%',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Monthly revenue chart
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Revenue',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text('Last 6 months',
                      style: TextStyle(
                          color: AppColors.slate400, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: chartData.every((e) => e.amount == 0)
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart_rounded,
                                    size: 40, color: AppColors.slate200),
                                SizedBox(height: 8),
                                Text('No payment data yet',
                                    style: TextStyle(
                                        color: AppColors.slate400,
                                        fontSize: 12)),
                              ],
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (g, gi, rod, ri) =>
                                      BarTooltipItem(
                                    rod.toY >= 1000
                                        ? '₹${(rod.toY / 1000).toStringAsFixed(1)}k'
                                        : '₹${rod.toY.toStringAsFixed(0)}',
                                    const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                                touchCallback: (e, res) {
                                  setState(() => _touchedIndex =
                                      res?.spot?.touchedBarGroupIndex ?? -1);
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= chartData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        chartData[i].month,
                                        style: const TextStyle(
                                            color: AppColors.slate400,
                                            fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: maxY / 4,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: AppColors.slate200,
                                  strokeWidth: 0.5,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups:
                                  chartData.asMap().entries.map((e) {
                                final touched = e.key == _touchedIndex;
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.amount,
                                      color: touched
                                          ? AppColors.doctorAccent
                                          : AppColors.doctorPrimary,
                                      width: 20,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown by consultation type
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Breakdown — This Month',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  if (breakdown.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No completed consultations this month',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 13)),
                      ),
                    )
                  else
                    ...breakdown.map((b) {
                      final color = typeColors[b.type] ??
                          AppColors.doctorPrimary;
                      final label =
                          typeLabels[b.type] ?? b.type;
                      final pct = totalConsults > 0
                          ? b.count / totalConsults
                          : 0.0;
                      return _BreakdownRow(
                        type: label,
                        count: b.count,
                        pct: pct,
                        color: color,
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _BreakdownRow extends StatelessWidget {
  final String type;
  final int count;
  final double pct;
  final Color color;
  const _BreakdownRow({
    required this.type,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(type,
                      style: const TextStyle(fontSize: 12))),
              Text('$count consult${count == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: AppColors.slate400, fontSize: 11)),
              const SizedBox(width: 8),
              Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.slate200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

/// Money patients say they sent by UPI, waiting on the doctor to confirm it
/// landed. Doclink is not in the money path, so only the doctor's own bank
/// statement can settle this — the app just tracks the claim.
class _PendingUpiPayments extends ConsumerWidget {
  const _PendingUpiPayments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(doctorPendingPaymentsProvider);

    return pending.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (payments) {
        if (payments.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: DlCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pending_actions_rounded,
                        size: 18, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Text('${payments.length} payment'
                        '${payments.length == 1 ? '' : 's'} to confirm',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Check your bank or UPI app, then confirm whether the money '
                  'arrived.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
                const SizedBox(height: 12),
                for (final p in payments) _PendingRow(payment: p),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PendingRow extends ConsumerStatefulWidget {
  final AppPayment payment;
  const _PendingRow({required this.payment});

  @override
  ConsumerState<_PendingRow> createState() => _PendingRowState();
}

class _PendingRowState extends ConsumerState<_PendingRow> {
  bool _busy = false;

  Future<void> _resolve(bool received) async {
    setState(() => _busy = true);
    try {
      await verifyPayment(widget.payment.id, received: received);
      ref.invalidate(doctorPendingPaymentsProvider);
      ref.invalidate(currentDoctorProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update: $e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${p.amount.toInt()} · ${p.patientName ?? 'Patient'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900)),
                Text(
                  p.upiUtr?.isNotEmpty == true
                      ? 'UTR ${p.upiUtr}'
                      : 'To be paid at clinic',
                  style: const TextStyle(
                      color: AppColors.slate400, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
          else ...[
            IconButton(
              tooltip: 'Money did not arrive',
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.slate400),
              onPressed: () => _resolve(false),
            ),
            IconButton(
              tooltip: 'Confirm received',
              icon: const Icon(Icons.check_circle_rounded,
                  size: 22, color: Color(0xFF16A34A)),
              onPressed: () => _resolve(true),
            ),
          ],
        ],
      ),
    );
  }
}
