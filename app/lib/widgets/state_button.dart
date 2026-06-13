import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A primary button that runs an async [onPressed] and shows its own
/// idle → loading (spinner) → success (check) lifecycle, so the user always
/// gets feedback. Re-enables itself after a brief success flash.
class StateButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Future<bool> Function() onPressed; // return true on success
  final Color color;
  const StateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primary,
  });

  @override
  State<StateButton> createState() => _StateButtonState();
}

enum _Status { idle, loading, success }

class _StateButtonState extends State<StateButton> {
  _Status _status = _Status.idle;

  Future<void> _run() async {
    if (_status != _Status.idle) return;
    setState(() => _status = _Status.loading);
    bool ok = false;
    try {
      ok = await widget.onPressed();
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      setState(() => _status = _Status.success);
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _status = _Status.idle);
    } else {
      setState(() => _status = _Status.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _status == _Status.loading;
    final success = _status == _Status.success;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : _run,
        style: ElevatedButton.styleFrom(
          backgroundColor: success ? AppColors.success : widget.color,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: widget.color.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const SizedBox(
                  key: ValueKey('l'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: AppColors.textPrimary),
                )
              : success
                  ? const Icon(Icons.check_rounded, key: ValueKey('s'))
                  : Row(
                      key: const ValueKey('i'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20),
                          const SizedBox(width: AppSpacing.x8),
                        ],
                        Text(widget.label, style: AppType.bodyLarge),
                      ],
                    ),
        ),
      ),
    );
  }
}
