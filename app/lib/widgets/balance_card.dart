import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'cards.dart' show formatMoney;

/// The hero Balance Card — height 180, radius 32, Primary Blue (design.md).
class BalanceCard extends StatelessWidget {
  final double owed;
  final double owing;
  final double net;
  const BalanceCard({
    super.key,
    required this.owed,
    required this.owing,
    required this.net,
  });

  String _fmt(double v) => formatMoney(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.x24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Net balance',
              style: AppType.body.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.x4),
          Text(
            '${net >= 0 ? '+' : '-'}${_fmt(net)}',
            style: AppType.financial().copyWith(fontSize: 32),
          ),
          const Spacer(),
          Row(
            children: [
              _Pill(label: 'You are owed', value: '+${_fmt(owed)}'),
              const SizedBox(width: AppSpacing.x12),
              _Pill(label: 'You owe', value: '-${_fmt(owing)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  const _Pill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x16, vertical: AppSpacing.x8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppType.caption),
            const SizedBox(height: 2),
            Text(value, style: AppType.bodyLarge),
          ],
        ),
      ),
    );
  }
}
