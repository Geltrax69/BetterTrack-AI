import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Indian-grouping currency format: last 3 digits, then groups of 2.
/// 8150 -> ₹8,150 · 1234567 -> ₹12,34,567
String formatMoney(double v, {String symbol = '₹'}) {
  final s = v.abs().toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d\d)+\d(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$symbol$s';
}

/// Horizontal-scroll Budget Card.
class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final alert = budget.overBudget;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(AppSpacing.x16),
      margin: const EdgeInsets.only(right: AppSpacing.x12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: budget.color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  alert ? Icons.warning_amber_rounded : Icons.savings_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (alert)
                const Icon(Icons.error_rounded,
                    color: AppColors.warning, size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          Text(budget.name, style: AppType.h3.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.x4),
          Text('${formatMoney(budget.spent)} of ${formatMoney(budget.limit)}',
              style: AppType.caption),
          const SizedBox(height: AppSpacing.x12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                alert ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width budget row (used inside Group Details > Budgets tab).
class BudgetCardWide extends StatelessWidget {
  final Budget budget;
  const BudgetCardWide({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final alert = budget.overBudget;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: budget.color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  alert ? Icons.warning_amber_rounded : Icons.savings_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              Text(budget.name, style: AppType.h3.copyWith(fontSize: 16)),
              const Spacer(),
              Text('${formatMoney(budget.spent)} / ${formatMoney(budget.limit)}',
                  style: AppType.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                alert ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Activity row on the dashboard.
class ActivityTile extends StatelessWidget {
  final Activity activity;
  const ActivityTile({super.key, required this.activity});

  (IconData, Color) get _visual {
    switch (activity.type) {
      case ActivityType.expenseAdded:
        return (Icons.receipt_long_rounded, AppColors.primary);
      case ActivityType.settlement:
        return (Icons.check_circle_rounded, AppColors.success);
      case ActivityType.budgetAlert:
        return (Icons.warning_amber_rounded, AppColors.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visual;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x8),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppType.bodyLarge),
                Text(activity.subtitle,
                    style: AppType.caption, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(activity.time, style: AppType.caption),
        ],
      ),
    );
  }
}

/// Group card on the Groups screen (radius 24).
class GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;
  const GroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final settled = group.outstanding == 0;
    final owed = group.outstanding > 0;
    final statusColor =
        settled ? AppColors.success : (owed ? AppColors.success : AppColors.error);
    final statusText = settled
        ? 'All settled'
        : owed
            ? 'You are owed ${formatMoney(group.outstanding, symbol: group.currency)}'
            : 'You owe ${formatMoney(group.outstanding, symbol: group.currency)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x20),
        margin: const EdgeInsets.only(bottom: AppSpacing.x16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppTheme.shadow1,
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: group.tint.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Center(
                child: Text(
                  group.name.characters.first,
                  style: AppType.h3,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(group.name, style: AppType.h3.copyWith(fontSize: 18)),
                      Text('${group.memberCount} members',
                          style: AppType.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(group.lastActivity,
                      style: AppType.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.x8),
                  Text(statusText,
                      style: AppType.bodyLarge.copyWith(color: statusColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expense Card (radius 20).
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x16),
      margin: const EdgeInsets.only(bottom: AppSpacing.x12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: expense.category.color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(expense.category.icon,
                color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: AppSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: AppType.bodyLarge),
                Text('${expense.payer} paid · ${expense.category.name}',
                    style: AppType.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(expense.amount),
                  style: AppType.h3.copyWith(fontSize: 16)),
              Text(
                expense.settled ? 'Settled' : 'Pending',
                style: AppType.caption.copyWith(
                  color: expense.settled ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
