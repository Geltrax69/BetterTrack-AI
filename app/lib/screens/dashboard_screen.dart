import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/async_value.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/balance_card.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'add_expense_sheet.dart';
import 'ai_chat_screen.dart';
import 'create_group_sheet.dart';
import 'scan_receipt.dart';
import 'settle_up_screen.dart';

/// Combined payload for the dashboard's dynamic sections.
class _DashData {
  final Summary summary;
  final List<Budget> budgets;
  final List<Activity> activity;
  const _DashData(this.summary, this.budgets, this.activity);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AsyncValue<_DashData> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncLoading());
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final repo = Repository.instance;
      final results = await Future.wait([
        repo.summary(),
        repo.budgets(),
        repo.activity(),
      ]);
      if (!mounted) return;
      setState(() => _state = AsyncData(_DashData(
            results[0] as Summary,
            results[1] as List<Budget>,
            results[2] as List<Activity>,
          )));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: _fetch,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
          children: [
            const _Header(),
            const SizedBox(height: AppSpacing.x20),
            AsyncView<_DashData>(
              state: _state,
              onRetry: _load,
              minLoadingHeight: 360,
              loadingLabel: 'Loading your money…',
              builder: (context, data) => _Content(data: data, onChanged: _fetch),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final _DashData data;
  final Future<void> Function() onChanged;
  const _Content({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BalanceCard(
          owed: data.summary.owed,
          owing: data.summary.owing,
          net: data.summary.net,
        ),
        const SizedBox(height: AppSpacing.x12),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettleUpScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x16, vertical: AppSpacing.x12),
            decoration: BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded,
                    size: 20, color: AppColors.primaryDark),
                const SizedBox(width: AppSpacing.x12),
                Expanded(
                  child: Text('View settle-up plan',
                      style: AppType.bodyLarge),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x24),
        _QuickActions(onChanged: onChanged),
        const SizedBox(height: AppSpacing.x24),
        const SectionHeader(title: 'Budgets'),
        if (data.budgets.isEmpty)
          Text('No budgets yet.', style: AppType.body)
        else
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [for (final b in data.budgets) BudgetCard(budget: b)],
            ),
          ),
        const SizedBox(height: AppSpacing.x24),
        const SectionHeader(title: 'Recent activity'),
        if (data.activity.isEmpty)
          Text('Nothing here yet.', style: AppType.body)
        else
          for (final a in data.activity) ActivityTile(activity: a),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
  final Future<void> Function() onChanged;
  const _QuickActions({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        QuickAction(
          icon: Icons.add_rounded,
          label: 'Add\nExpense',
          color: AppColors.primary,
          onTap: () async {
            final created = await AddExpenseSheet.show(context);
            if (created) await onChanged();
          },
        ),
        const SizedBox(width: AppSpacing.x12),
        QuickAction(
          icon: Icons.document_scanner_rounded,
          label: 'Scan\nReceipt',
          color: AppColors.food,
          onTap: () async {
            final created = await ScanReceipt.run(context);
            if (created) await onChanged();
          },
        ),
        const SizedBox(width: AppSpacing.x12),
        QuickAction(
          icon: Icons.group_add_rounded,
          label: 'Create\nGroup',
          color: AppColors.travel,
          onTap: () async {
            final created = await CreateGroupSheet.show(context);
            if (created) await onChanged();
          },
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
}
