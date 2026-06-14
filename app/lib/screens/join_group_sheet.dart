import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/state_button.dart';

/// Bottom sheet to join an existing group by its share code. Returns the joined
/// [Group] (or null if cancelled) so the caller can refresh / navigate.
class JoinGroupSheet extends StatefulWidget {
  final String? prefillCode;
  const JoinGroupSheet({super.key, this.prefillCode});

  static Future<Group?> show(BuildContext context, {String? prefillCode}) {
    return showModalBottomSheet<Group>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => JoinGroupSheet(prefillCode: prefillCode),
    );
  }

  @override
  State<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<JoinGroupSheet> {
  late final _code = TextEditingController(text: widget.prefillCode ?? '');
  final _name = TextEditingController(text: 'You');
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    final code = _code.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the group code.');
      return false;
    }
    setState(() => _error = null);
    try {
      final group = await Repository.instance.joinGroup(
        code: code,
        memberName: _name.text.trim().isEmpty ? 'You' : _name.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(group);
        showSuccess(context, 'Joined ${group.name} 🎉');
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
          Text('Join a group', style: AppType.h2),
          const SizedBox(height: AppSpacing.x4),
          Text('Enter the 6-character code a friend shared with you.',
              style: AppType.body),
          const SizedBox(height: AppSpacing.x16),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseFormatter(),
              LengthLimitingTextInputFormatter(8),
            ],
            style: AppType.h2.copyWith(letterSpacing: 4),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'ABC123'),
          ),
          const SizedBox(height: AppSpacing.x12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.x12),
            Text(_error!, style: AppType.caption.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.x20),
          StateButton(
            label: 'Join group',
            icon: Icons.login_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Forces input to upper case (join codes are case-insensitive but look tidy).
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
