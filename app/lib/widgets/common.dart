import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Section header used across screens (e.g. "Your plan", "Recent activity").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppType.h2),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: AppType.bodyLarge.copyWith(color: AppColors.primaryDark)),
            ),
        ],
      ),
    );
  }
}

/// Quick action chips on the dashboard (Add Expense, Scan, Create Group, AI).
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 56, // preferred touch target
              width: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 26),
            ),
            const SizedBox(height: AppSpacing.x8),
            Text(label,
                textAlign: TextAlign.center,
                style: AppType.caption.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// A soft category/status chip.
class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const TagChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12, vertical: AppSpacing.x4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(label, style: AppType.caption.copyWith(color: AppColors.textPrimary)),
    );
  }
}

/// Empty-state placeholder (minimal, monochrome, blue accent — design.md).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String cta;
  final VoidCallback? onCta;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.cta,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.x16),
          Text(title, style: AppType.h3),
          const SizedBox(height: AppSpacing.x16),
          SizedBox(
            width: 220,
            child: ElevatedButton(onPressed: onCta, child: Text(cta)),
          ),
        ],
      ),
    );
  }
}
