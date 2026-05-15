import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final walletBalance = earningsMonth * 0.9;

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
                        const Text('Wallet Balance',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 12)),
                        Text(
                          walletBalance >= 1000
                              ? '₹${(walletBalance / 1000).toStringAsFixed(1)}k'
                              : '₹${walletBalance.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const Text('90% of monthly earnings',
                            style: TextStyle(
                                color: AppColors.slate400, fontSize: 11)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: walletBalance > 0
                        ? () => _showWithdrawSheet(context, walletBalance, doc)
                        : null,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 40)),
                    child: const Text('Withdraw'),
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

  void _showWithdrawSheet(BuildContext context, double balance, AppDoctor? doc) {
    final upiId = doc?.upiId;
    final doctorName = doc?.name ?? 'Doctor';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.doctorCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw ₹${balance.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Your earnings will be sent to your UPI ID.',
              style: TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (upiId != null) ...[
              // UPI ID display
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.doctorAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.doctorAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded,
                        color: AppColors.doctorAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('UPI ID',
                              style: TextStyle(
                                  color: AppColors.slate400, fontSize: 11)),
                          Text(upiId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 20, color: AppColors.slate400),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('UPI ID copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Open UPI app button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(
                      'upi://pay?pa=${Uri.encodeComponent(upiId)}'
                      '&pn=${Uri.encodeComponent('Dr $doctorName')}'
                      '&am=${balance.toStringAsFixed(2)}'
                      '&cu=INR'
                      '&tn=${Uri.encodeComponent('Doclink Payout')}',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'No UPI app found. Please copy the UPI ID and pay manually.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text('Pay ₹${balance.toStringAsFixed(0)} via UPI App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.doctorAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Opens PhonePe · GPay · Paytm · any UPI app',
                  style:
                      TextStyle(color: AppColors.slate400, fontSize: 11),
                ),
              ),
            ] else ...[
              // No UPI ID set
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.warning),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No UPI ID saved. Go to My Profile → UPI Payout ID to add it.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
