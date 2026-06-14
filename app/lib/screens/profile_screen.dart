import 'package:flutter/material.dart';
import '../services/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import 'settings_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large)),
        title: Text('Log out?', style: AppType.h3),
        content: Text('You can sign back in any time.', style: AppType.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppType.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log out',
                style: AppType.bodyLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      showSuccess(context, 'Logged out');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) {
          final s = AppSettings.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
            children: [
              Text('Profile', style: AppType.h1),
              const SizedBox(height: AppSpacing.x24),
              GestureDetector(
                onTap: () => _open(context, const EditProfileScreen()),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.x20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          s.name.isNotEmpty ? s.name.characters.first : '?',
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: AppType.h2),
                            Text(s.email,
                                style: AppType.body
                                    .copyWith(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x24),
              _Tile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Payment methods',
                onTap: () => _open(context, const PaymentMethodsScreen()),
              ),
              _Tile(
                icon: Icons.currency_exchange_rounded,
                label: 'Default currency',
                trailing: '${s.currencySymbol} ${s.currencyCode}',
                onTap: () => _open(context, const CurrencyScreen()),
              ),
              _Tile(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => _open(context, const NotificationsScreen()),
              ),
              _Tile(
                icon: Icons.auto_awesome_rounded,
                label: 'AI preferences',
                onTap: () => _open(context, const AiPreferencesScreen()),
              ),
              _Tile(
                icon: Icons.lock_outline_rounded,
                label: 'Privacy & security',
                onTap: () => _open(context, const PrivacyScreen()),
              ),
              _Tile(
                icon: Icons.help_outline_rounded,
                label: 'Help & support',
                onTap: () => _open(context, const HelpScreen()),
              ),
              const SizedBox(height: AppSpacing.x12),
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Log out',
                danger: true,
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool danger;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
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
        onTap: onTap,
      ),
    );
  }
}
