import 'package:flutter/material.dart';
import '../services/async_value.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'brand_spinner.dart';

/// Renders the right UI for an [AsyncValue]: branded spinner while loading,
/// an error card with Retry on failure, and [builder] once data arrives.
class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> state;
  final Widget Function(BuildContext, T) builder;
  final VoidCallback onRetry;
  final double minLoadingHeight;
  final String? loadingLabel;

  const AsyncView({
    super.key,
    required this.state,
    required this.builder,
    required this.onRetry,
    this.minLoadingHeight = 200,
    this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncLoading<T>() => SizedBox(
          height: minLoadingHeight,
          child: Center(child: BrandSpinner(label: loadingLabel)),
        ),
      AsyncError<T>(message: final m) => ErrorState(message: m, onRetry: onRetry),
      AsyncData<T>(value: final v) => builder(context, v),
    };
  }
}

/// Inline error card with a Retry action.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.x20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 32),
          const SizedBox(height: AppSpacing.x12),
          Text(message, textAlign: TextAlign.center, style: AppType.body),
          const SizedBox(height: AppSpacing.x16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Lightweight success / error toasts so every action gives feedback.
void showSuccess(BuildContext context, String message) =>
    _toast(context, message, AppColors.success, Icons.check_circle_rounded);

void showFailure(BuildContext context, String message) =>
    _toast(context, message, AppColors.error, Icons.error_rounded);

void _toast(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium)),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.x12),
            Expanded(
              child: Text(message,
                  style: AppType.body.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
}
