import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/async_value.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/cards.dart';

/// Shows the CSV import result: the who-pays-whom plan (Aisha), per-person net,
/// a tappable breakdown of every expense behind a number (Rohan), and the
/// anomalies the importer flagged (Meera).
class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({super.key});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  AsyncValue<ImportReport> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncLoading());
    try {
      final report = await Repository.instance.importReport();
      if (!mounted) return;
      setState(() => _state = AsyncData(report));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settle up', style: AppType.h3),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x20, AppSpacing.x8, AppSpacing.x20, AppSpacing.x32),
          children: [
            AsyncView<ImportReport>(
              state: _state,
              onRetry: _load,
              minLoadingHeight: 400,
              loadingLabel: 'Crunching the spreadsheet…',
              builder: (context, r) => _Content(report: r),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ImportReport report;
  const _Content({required this.report});

  @override
  Widget build(BuildContext context) {
    final s = report.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Import summary chips.
        Wrap(
          spacing: AppSpacing.x8,
          runSpacing: AppSpacing.x8,
          children: [
            _chip('${s['expenses_kept'] ?? 0} expenses', AppColors.primary),
            _chip('${s['skipped'] ?? 0} skipped', AppColors.warning),
            _chip('${s['anomalies'] ?? 0} anomalies', AppColors.aiAccent),
            _chip('${s['need_approval'] ?? 0} need approval', AppColors.error),
          ],
        ),
        const SizedBox(height: AppSpacing.x24),

        Text('Who pays whom', style: AppType.h2),
        Text('The fewest transfers to settle everyone.', style: AppType.body),
        const SizedBox(height: AppSpacing.x12),
        if (report.settleUp.isEmpty)
          Text('Everyone is settled up 🎉', style: AppType.bodyLarge)
        else
          for (final t in report.settleUp) _TransferRow(t: t),

        const SizedBox(height: AppSpacing.x24),
        Text('Net position', style: AppType.h2),
        Text('Tap a person to see every expense behind their number.',
            style: AppType.body),
        const SizedBox(height: AppSpacing.x12),
        for (final e in (report.netBalances.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value))))
          _PersonRow(name: e.key, net: e.value),

        const SizedBox(height: AppSpacing.x24),
        Text('Flagged for approval', style: AppType.h2),
        const SizedBox(height: AppSpacing.x12),
        ...report.anomalies
            .where((a) => a.needsApproval)
            .map((a) => _AnomalyRow(a: a)),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x12, vertical: AppSpacing.x8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Text(label, style: AppType.caption.copyWith(color: AppColors.textPrimary)),
      );
}

class _TransferRow extends StatelessWidget {
  final Transfer t;
  const _TransferRow({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x12),
      padding: const EdgeInsets.all(AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          _avatar(t.from, AppColors.error),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.x8),
            child: Icon(Icons.arrow_forward_rounded,
                size: 18, color: AppColors.textSecondary),
          ),
          _avatar(t.to, AppColors.success),
          const SizedBox(width: AppSpacing.x12),
          Expanded(
            child: Text('${t.from} pays ${t.to}', style: AppType.bodyLarge),
          ),
          Text(formatMoney(t.amount),
              style: AppType.h3.copyWith(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _avatar(String name, Color color) => CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.25),
        child: Text(name.characters.first,
            style: AppType.caption.copyWith(color: AppColors.textPrimary)),
      );
}

class _PersonRow extends StatelessWidget {
  final String name;
  final double net;
  const _PersonRow({required this.name, required this.net});

  @override
  Widget build(BuildContext context) {
    final owed = net >= 0;
    final color = net.abs() < 1 ? AppColors.textSecondary : (owed ? AppColors.success : AppColors.error);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _BreakdownScreen(person: name))),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.x8),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x16, vertical: AppSpacing.x12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(name.characters.first,
                  style: const TextStyle(color: AppColors.textPrimary)),
            ),
            const SizedBox(width: AppSpacing.x12),
            Expanded(child: Text(name, style: AppType.bodyLarge)),
            Text('${owed ? '+' : '-'}${formatMoney(net)}',
                style: AppType.bodyLarge.copyWith(color: color)),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AnomalyRow extends StatelessWidget {
  final ImportAnomaly a;
  const _AnomalyRow({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x12),
      padding: const EdgeInsets.all(AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.x8),
              Text('Row ${a.row} · ${a.kind}',
                  style: AppType.caption.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.x8),
          Text(a.detail, style: AppType.body.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.x4),
          Text('→ ${a.action}', style: AppType.caption),
          const SizedBox(height: AppSpacing.x12),
          Row(
            children: [
              Expanded(
                child: _approveBtn(context, 'Approve', AppColors.success, true),
              ),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: _approveBtn(context, 'Keep as-is', AppColors.secondary, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _approveBtn(BuildContext context, String label, Color color, bool primary) {
    return GestureDetector(
      onTap: () => showSuccess(context,
          primary ? 'Approved — row ${a.row}' : 'Kept row ${a.row} unchanged'),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? color : AppColors.surface,
          border: primary ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Text(label,
            style: AppType.body.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}

class _BreakdownScreen extends StatefulWidget {
  final String person;
  const _BreakdownScreen({required this.person});

  @override
  State<_BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<_BreakdownScreen> {
  AsyncValue<List<Map<String, dynamic>>> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncLoading());
    try {
      final lines = await Repository.instance.balanceBreakdown(widget.person);
      if (!mounted) return;
      setState(() => _state = AsyncData(lines));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("${widget.person}'s expenses", style: AppType.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x20),
        children: [
          Text('Every line behind the number — no magic.', style: AppType.body),
          const SizedBox(height: AppSpacing.x16),
          AsyncView<List<Map<String, dynamic>>>(
            state: _state,
            onRetry: _load,
            builder: (context, lines) => Column(
              children: [for (final l in lines) _Line(line: l)],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final Map<String, dynamic> line;
  const _Line({required this.line});

  @override
  Widget build(BuildContext context) {
    final effect = (line['effect'] as num?)?.toDouble() ?? 0;
    final positive = effect >= 0;
    final paid = (line['paid'] as num?)?.toDouble();
    final share = (line['your_share'] as num?)?.toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x8),
      padding: const EdgeInsets.all(AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line['description']?.toString() ?? '',
                    style: AppType.bodyLarge),
                Text(
                  line['note']?.toString() ??
                      'paid ${formatMoney(paid ?? 0)} · your share ${formatMoney(share ?? 0)}',
                  style: AppType.caption,
                ),
                Text(line['date']?.toString() ?? '', style: AppType.caption),
              ],
            ),
          ),
          Text('${positive ? '+' : '-'}${formatMoney(effect)}',
              style: AppType.bodyLarge.copyWith(
                  color: positive ? AppColors.success : AppColors.error)),
        ],
      ),
    );
  }
}
