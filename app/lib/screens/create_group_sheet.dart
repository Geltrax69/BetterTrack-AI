import 'package:flutter/material.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/state_button.dart';

/// Bottom sheet to create a group against the live backend. Add member names as
/// chips, pick a currency, and submit. Returns true if a group was created so
/// the caller can refresh.
class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const CreateGroupSheet(),
    );
    return created ?? false;
  }

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _name = TextEditingController();
  final _member = TextEditingController();
  final List<String> _members = ['You'];
  String _currency = '₹';
  String? _error;

  static const _currencies = ['₹', r'$', '€', '£'];

  @override
  void dispose() {
    _name.dispose();
    _member.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _member.text.trim();
    if (name.isEmpty) return;
    if (!_members.any((m) => m.toLowerCase() == name.toLowerCase())) {
      setState(() => _members.add(name));
    }
    _member.clear();
  }

  Future<bool> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give your group a name.');
      return false;
    }
    setState(() => _error = null);
    try {
      final group = await Repository.instance.createGroup(
        name: name,
        members: _members,
        currency: _currency,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        showSuccess(context, 'Group created — ${group.name}');
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
          Text('Create group', style: AppType.h2),
          const SizedBox(height: AppSpacing.x16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                hintText: 'Group name (e.g. Goa Trip)'),
          ),
          const SizedBox(height: AppSpacing.x16),
          Text('Currency', style: AppType.caption),
          const SizedBox(height: AppSpacing.x8),
          Wrap(
            spacing: AppSpacing.x8,
            children: [
              for (final c in _currencies)
                ChoiceChip(
                  label: Text(c),
                  selected: _currency == c,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _currency = c),
                  backgroundColor: AppColors.secondary,
                  selectedColor: AppColors.primary,
                  labelStyle:
                      AppType.bodyLarge.copyWith(color: AppColors.textPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small)),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.x16),
          Text('Members', style: AppType.caption),
          const SizedBox(height: AppSpacing.x8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _member,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addMember(),
                  decoration: const InputDecoration(hintText: 'Add a name'),
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              GestureDetector(
                onTap: _addMember,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          Wrap(
            spacing: AppSpacing.x8,
            runSpacing: AppSpacing.x8,
            children: [
              for (final m in _members)
                Chip(
                  label: Text(m, style: AppType.body),
                  backgroundColor: AppColors.secondary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small)),
                  deleteIcon: m == 'You'
                      ? null
                      : const Icon(Icons.close_rounded, size: 16),
                  onDeleted: m == 'You'
                      ? null
                      : () => setState(() => _members.remove(m)),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.x12),
            Text(_error!,
                style: AppType.caption.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.x20),
          StateButton(
            label: 'Create group',
            icon: Icons.group_add_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
