import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'ai_chat_screen.dart';
import 'group_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
        children: [
          _Header(),
          const SizedBox(height: AppSpacing.x20),
          const BalanceCard(
            owed: MockData.totalOwed,
            owing: MockData.totalOwing,
            net: 8150,
          ),
          const SizedBox(height: AppSpacing.x24),
          _QuickActions(),
          const SizedBox(height: AppSpacing.x24),
          const SectionHeader(title: 'Budgets', action: 'See all'),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final b in MockData.budgets) BudgetCard(budget: b),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          const SectionHeader(title: 'Recent activity', action: 'See all'),
          for (final a in MockData.activity) ActivityTile(activity: a),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Text('S', style: TextStyle(color: AppColors.textPrimary)),
        ),
        const SizedBox(width: AppSpacing.x12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning', style: AppType.caption),
              Text('Hello, Sam', style: AppType.h2),
            ],
          ),
        ),
        _IconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        QuickAction(
          icon: Icons.add_rounded,
          label: 'Add\nExpense',
          color: AppColors.primary,
          onTap: () => _snack(context, 'Add Expense'),
        ),
        const SizedBox(width: AppSpacing.x12),
        QuickAction(
          icon: Icons.document_scanner_rounded,
          label: 'Scan\nReceipt',
          color: AppColors.food,
          onTap: () => _snack(context, 'Scan Receipt (OCR)'),
        ),
        const SizedBox(width: AppSpacing.x12),
        QuickAction(
          icon: Icons.group_add_rounded,
          label: 'Create\nGroup',
          color: AppColors.travel,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  GroupDetailsScreen(group: MockData.groups.first))),
        ),
        const SizedBox(width: AppSpacing.x12),
        QuickAction(
          icon: Icons.auto_awesome_rounded,
          label: 'AI\nAssistant',
          color: AppColors.aiAccent,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiChatScreen())),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}
