import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
        children: [
          Text('Profile', style: AppType.h1),
          const SizedBox(height: AppSpacing.x24),
          Container(
            padding: const EdgeInsets.all(AppSpacing.x20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text('S',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 24)),
                ),
                const SizedBox(width: AppSpacing.x16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sam Mehta', style: AppType.h2),
                    Text('sam@bettertrack.ai',
                        style: AppType.body
                            .copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          _Tile(icon: Icons.account_balance_wallet_rounded, label: 'Payment methods'),
          _Tile(icon: Icons.currency_exchange_rounded, label: 'Default currency', trailing: '₹ INR'),
          _Tile(icon: Icons.notifications_none_rounded, label: 'Notifications'),
          _Tile(icon: Icons.auto_awesome_rounded, label: 'AI preferences'),
          _Tile(icon: Icons.lock_outline_rounded, label: 'Privacy & security'),
          _Tile(icon: Icons.help_outline_rounded, label: 'Help & support'),
          const SizedBox(height: AppSpacing.x12),
          _Tile(icon: Icons.logout_rounded, label: 'Log out', danger: true),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool danger;
  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x12),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x16, vertical: AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: color),
        title: Text(label, style: AppType.bodyLarge.copyWith(color: color)),
        trailing: trailing != null
            ? Text(trailing!, style: AppType.body)
            : (danger
                ? null
                : const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary)),
        onTap: () {},
      ),
    );
  }
}
