import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/state_button.dart';

/// Bottom sheet to create an expense against the live backend, with inline
/// validation and a self-managing loading/success button. Returns true if an
/// expense was created so the caller can refresh.
class AddExpenseSheet extends StatefulWidget {
  final String? groupId;
  final String? prefillName;
  final double? prefillAmount;
  final String? prefillCategory;
  const AddExpenseSheet({
    super.key,
    this.groupId,
    this.prefillName,
    this.prefillAmount,
    this.prefillCategory,
  });

  static Future<bool> show(
    BuildContext context, {
    String? groupId,
    String? prefillName,
    double? prefillAmount,
    String? prefillCategory,
  }) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => AddExpenseSheet(
        groupId: groupId,
        prefillName: prefillName,
        prefillAmount: prefillAmount,
        prefillCategory: prefillCategory,
      ),
    );
    return created ?? false;
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late final _name = TextEditingController(text: widget.prefillName ?? '');
  late final _amount = TextEditingController(
      text: widget.prefillAmount != null
          ? widget.prefillAmount!.toStringAsFixed(0)
          : '');
  final _payer = TextEditingController(text: 'You');
  late String _category =
      _cats.containsKey(widget.prefillCategory) ? widget.prefillCategory! : 'food';
  String? _error;

  static const _cats = {
    'food': 'Food',
    'travel': 'Travel',
    'entertainment': 'Fun',
    'shopping': 'Shopping',
  };

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _payer.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    final name = _name.text.trim();
    final amount = double.tryParse(_amount.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Enter a name and a valid amount.');
      return false;
    }
    setState(() => _error = null);
    try {
      await Repository.instance.createExpense(
        name: name,
        category: _category,
        amount: amount,
        payer: _payer.text.trim().isEmpty ? 'You' : _payer.text.trim(),
        groupId: widget.groupId,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        showSuccess(context, 'Expense added — $name');
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        showFailure(context, e.toString());
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.x20, AppSpacing.x20, AppSpacing.x20, bottom + AppSpacing.x20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x16),
          Text('Add expense', style: AppType.h2),
          const SizedBox(height: AppSpacing.x16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What was it for?'),
          ),
          const SizedBox(height: AppSpacing.x12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
                hintText: 'Amount', prefixText: '₹ '),
          ),
          const SizedBox(height: AppSpacing.x12),
          Wrap(
            spacing: AppSpacing.x8,
            children: [
              for (final e in _cats.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _category == e.key,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _category = e.key),
                  backgroundColor: AppColors.secondary,
                  selectedColor: AppColors.primary,
                  labelStyle: AppType.body.copyWith(color: AppColors.textPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small)),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          TextField(
            controller: _payer,
            decoration: const InputDecoration(hintText: 'Paid by'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.x12),
            Text(_error!, style: AppType.caption.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.x20),
          StateButton(
            label: 'Add expense',
            icon: Icons.add_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
