import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';

/// Bottom sheet that shows a group's join code + link, with Copy and a native
/// Share action so members can be invited.
class ShareGroupSheet extends StatelessWidget {
  final Group group;
  const ShareGroupSheet({super.key, required this.group});

  static Future<void> show(BuildContext context, Group group) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ShareGroupSheet(group: group),
    );
  }

  String get _inviteText =>
      'Join my "${group.name}" group on BetterTrack AI.\n'
      'Code: ${group.code}\n${group.shareLink}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.x20, AppSpacing.x12, AppSpacing.x20, AppSpacing.x24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: AppSpacing.x20),
          Text('Invite to ${group.name}', style: AppType.h2),
          const SizedBox(height: AppSpacing.x4),
          Text('Share this code or link so others can join.', style: AppType.body),
          const SizedBox(height: AppSpacing.x20),
          // Big code display.
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.x24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              children: [
                Text('GROUP CODE',
                    style: AppType.caption.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.x8),
                Text(
                  group.code,
                  textAlign: TextAlign.center,
                  style: AppType.displayLarge.copyWith(letterSpacing: 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: group.code));
                    showSuccess(context, 'Code copied');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                  label: const Text('Copy code'),
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _share(context),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      _inviteText,
      subject: 'Join ${group.name} on BetterTrack',
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }
}
