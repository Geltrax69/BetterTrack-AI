import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// AI Assistant chat. Lives inside group chat (mention @BetterTrack) but also
/// opens standalone from the dashboard / FAB. [embedded] hides the AppBar.
class AiChatScreen extends StatefulWidget {
  final bool embedded;
  const AiChatScreen({super.key, this.embedded = false});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  late final List<ChatMessage> _messages = List.of(MockData.chat);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(ChatRole.user, text, time: 'now'));
      // Stubbed assistant reply — real call goes to the FastAPI /ai endpoint.
      _messages.add(const ChatMessage(
        ChatRole.ai,
        'Got it! Once the backend API key is set, I\'ll parse this and draft '
        'the expense for you to confirm.',
        time: 'now',
      ));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: false,
            padding: const EdgeInsets.all(AppSpacing.x16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _Bubble(message: _messages[i]),
          ),
        ),
        _Composer(controller: _controller, onSend: _send),
      ],
    );

    if (widget.embedded) return body;

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
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.aiAccent,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.x12),
            Flexible(
              child: Text('BetterTrack AI',
                  style: AppType.h3, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.role == ChatRole.system) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.x8),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x12, vertical: AppSpacing.x4),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(message.text, style: AppType.caption),
        ),
      );
    }

    final isAi = message.role == ChatRole.ai;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
        padding: const EdgeInsets.all(AppSpacing.x12),
        decoration: BoxDecoration(
          color: isAi ? AppColors.aiBubble : AppColors.surface,
          border: isAi ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    Text('BetterTrack AI',
                        style: AppType.caption
                            .copyWith(color: AppColors.primaryDark)),
                  ],
                ),
              ),
            Text(message.text,
                style: AppType.body.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x16, AppSpacing.x8, AppSpacing.x16, AppSpacing.x12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask BetterTrack anything…',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x12),
            GestureDetector(
              onTap: onSend,
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(Icons.send_rounded,
                    color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
