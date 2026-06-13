import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/async_value.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'add_expense_sheet.dart';
import 'ai_chat_screen.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Group group;
  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(group.name, style: AppType.h3),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryDark,
            labelStyle: AppType.bodyLarge,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Expenses'),
              Tab(text: 'Budgets'),
              Tab(text: 'Members'),
              Tab(text: 'Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Overview(group: group),
            _Expenses(groupId: group.id),
            _Budgets(),
            _Members(count: group.memberCount),
            AiChatScreen(embedded: true, groupId: group.id),
          ],
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  final Group group;
  const _Overview({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x20),
      children: [
        Container(
          height: 160,
          padding: const EdgeInsets.all(AppSpacing.x24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Group balance', style: AppType.body.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.x4),
              Text(formatMoney(group.outstanding.abs(), symbol: group.currency),
                  style: AppType.financial().copyWith(fontSize: 34)),
              const Spacer(),
              Text(
                group.outstanding == 0
                    ? 'Everyone is settled up'
                    : group.outstanding > 0
                        ? 'You are owed overall'
                        : 'You owe overall',
                style: AppType.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x24),
        Row(
          children: [
            _MiniStat(label: 'Total expenses', value: formatMoney(38600)),
            const SizedBox(width: AppSpacing.x12),
            _MiniStat(label: 'Active budgets', value: '3'),
          ],
        ),
        const SizedBox(height: AppSpacing.x24),
        const SectionHeader(title: 'Recent activity'),
        for (final a in MockData.activity) ActivityTile(activity: a),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
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

class _Expenses extends StatefulWidget {
  final String groupId;
  const _Expenses({required this.groupId});

  @override
  State<_Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<_Expenses> {
  AsyncValue<List<Expense>> _state = const AsyncLoading();

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
      final list = await Repository.instance.expenses(groupId: widget.groupId);
      if (!mounted) return;
      setState(() => _state = AsyncData(list));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: _fetch,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.x20),
        children: [
          AsyncView<List<Expense>>(
            state: _state,
            onRetry: _load,
            loadingLabel: 'Loading expenses…',
            builder: (context, list) {
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No expenses yet',
                  cta: 'Add an expense',
                  onCta: () async {
                    final ok = await AddExpenseSheet.show(context,
                        groupId: widget.groupId);
                    if (ok) await _fetch();
                  },
                );
              }
              return Column(
                children: [for (final e in list) ExpenseCard(expense: e)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Budgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x20),
      children: [
        for (final b in MockData.budgets)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x12),
            child: BudgetCardWide(budget: b),
          ),
      ],
    );
  }
}

class _Members extends StatelessWidget {
  final int count;
  const _Members({required this.count});

  static const _names = ['Sam', 'Riya', 'Aman', 'Neha', 'Karan', 'Priya', 'Dev', 'Tara'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x20),
      children: [
        for (var i = 0; i < count; i++)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.x12),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x16, vertical: AppSpacing.x8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(_names[i % _names.length].characters.first,
                      style: const TextStyle(color: AppColors.textPrimary)),
                ),
                const SizedBox(width: AppSpacing.x12),
                Text(_names[i % _names.length], style: AppType.bodyLarge),
                const Spacer(),
                if (i == 0)
                  const TagChip(label: 'You', color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}
