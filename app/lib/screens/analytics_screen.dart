import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
        children: [
          Text('Analytics', style: AppType.h1),
          const SizedBox(height: AppSpacing.x20),
          Row(
            children: [
              _StatCard(
                label: 'Total spent',
                value: formatMoney(12450),
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.x12),
              _StatCard(
                label: 'Top spender',
                value: 'You',
                color: AppColors.aiAccent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          Row(
            children: [
              _StatCard(
                label: 'Settlement rate',
                value: '82%',
                color: AppColors.travel,
              ),
              const SizedBox(width: AppSpacing.x12),
              _StatCard(
                label: 'Food spend',
                value: formatMoney(8200),
                color: AppColors.food,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x24),
          const SectionHeader(title: 'Spending trend'),
          _ChartCard(child: _LineChart()),
          const SizedBox(height: AppSpacing.x24),
          const SectionHeader(title: 'By category'),
          _ChartCard(child: _CategoryPie()),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppType.caption),
            const SizedBox(height: AppSpacing.x8),
            Text(value, style: AppType.h2.copyWith(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSpacing.x20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: child,
    );
  }
}

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      duration: Duration.zero, // instant render; avoids leaked animation tickers
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= MockData.months.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(MockData.months[i], style: AppType.caption),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.primaryDark,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            spots: [
              for (var i = 0; i < MockData.monthlySpend.length; i++)
                FlSpot(i.toDouble(), MockData.monthlySpend[i] / 1000),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.food,
      AppColors.travel,
      AppColors.entertainment,
      AppColors.shopping,
    ];
    final entries = MockData.categorySplit.entries.toList();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            duration: Duration.zero,
            PieChartData(
              centerSpaceRadius: 30,
              sectionsSpace: 3,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: colors[i % colors.length],
                    title: '',
                    radius: 46,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x8),
                      Expanded(
                        child: Text(entries[i].key,
                            style: AppType.caption,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
