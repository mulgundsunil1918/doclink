import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/dl_card.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final doc = MockData.doctor;
    final monthly = MockData.earningsMonthly;
    final breakdown = MockData.earningsBreakdown;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
              icon: const Icon(Icons.download_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Summary cards
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
                          '₹${doc.earningsToday.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.doctorAccent),
                        ),
                        const Text('${0} consultations',
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
                          '₹${(doc.earningsMonth / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.doctorPrimary),
                        ),
                        const Text('111 consultations',
                            style: TextStyle(
                                color: AppColors.slate500, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wallet balance
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
                          '₹${(doc.earningsMonth * 0.9 / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showWithdrawSheet(context),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 40)),
                    child: const Text('Withdraw'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Revenue chart
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Revenue',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text('Last 6 months',
                      style:
                          TextStyle(color: AppColors.slate400, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100000,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                              '₹${(rod.toY / 1000).toStringAsFixed(0)}k',
                              const TextStyle(color: Colors.white, fontSize: 11),
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
                              getTitlesWidget: (v, _) => Text(
                                monthly[v.toInt()].month,
                                style: const TextStyle(
                                    color: AppColors.slate400, fontSize: 10),
                              ),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 25000,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.slate700.withValues(alpha: 0.4),
                            strokeWidth: 0.5,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: monthly.asMap().entries.map((e) {
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
                                borderRadius: BorderRadius.circular(4),
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

            // Breakdown
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Breakdown — March',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ...breakdown.map((b) => _BreakdownRow(
                        type: b['type'] as String,
                        count: b['count'] as int,
                        amount: b['amount'] as int,
                        color: Color(b['color'] as int),
                        total: 87500,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tax summary
            DlCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tax Summary',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _TaxRow('Gross Earnings (Q4)', '₹2,62,500'),
                  _TaxRow('Platform Fee (10%)', '₹26,250'),
                  _TaxRow('GST on Platform Fee (18%)', '₹4,725'),
                  const Divider(color: AppColors.doctorBorder, height: 20),
                  _TaxRow('Net Earnings', '₹2,31,525',
                      bold: true, color: AppColors.doctorAccent),
                  const SizedBox(height: 4),
                  const Text(
                    'TDS applicable if earnings > ₹30k/quarter. Download Form 16A.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.doctorCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw to Bank',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.account_balance, color: AppColors.doctorPrimary),
              title: Text('HDFC Bank ****4521'),
              subtitle: Text('Primary account', style: TextStyle(color: AppColors.slate400)),
              trailing: Icon(Icons.check_circle, color: AppColors.doctorAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Withdrawal of ₹78,750 initiated. T+1 business day.')),
                );
              },
              child: const Text('Confirm Withdrawal — ₹78,750'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String type;
  final int count, amount, total;
  final Color color;
  const _BreakdownRow({
    required this.type,
    required this.count,
    required this.amount,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = amount / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(type, style: const TextStyle(fontSize: 12))),
              Text('$count consults',
                  style: const TextStyle(color: AppColors.slate400, fontSize: 11)),
              const SizedBox(width: 8),
              Text('₹${amount ~/ 1000}k',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.slate800,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? color;
  const _TaxRow(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  color: bold ? Colors.white : AppColors.slate400,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                )),
          ),
          Text(value,
              style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}
