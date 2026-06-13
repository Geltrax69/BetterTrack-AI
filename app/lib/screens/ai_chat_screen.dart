import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';

/// AI Assistant chat. Lives inside group chat (mention @BetterTrack) but also
/// opens standalone from the dashboard / FAB. [embedded] hides the AppBar.
class AiChatScreen extends StatefulWidget {
  final bool embedded;
  final String? groupId;
  const AiChatScreen({super.key, this.embedded = false, this.groupId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages = List.of(MockData.chat);
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(ChatMessage(ChatRole.user, text, time: 'now'));
      _controller.clear();
      _sending = true; // shows the typing indicator
    });
    _scrollToEnd();
    try {
      final reply =
          await Repository.instance.aiChat(text, groupId: widget.groupId);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(ChatRole.ai, reply, time: 'now'));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(ChatRole.system, e.toString()));
        _sending = false;
      });
      showFailure(context, e.toString());
    }
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(AppSpacing.x16),
            itemCount: _messages.length + (_sending ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length) return const _TypingBubble();
              return _Bubble(message: _messages[i]);
            },
          ),
        ),
        _Composer(
            controller: _controller, onSend: _send, enabled: !_sending),
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

/// "BetterTrack AI is typing…" bubble shown while awaiting a reply.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
        padding: const EdgeInsets.all(AppSpacing.x12),
        decoration: BoxDecoration(
          color: AppColors.aiBubble,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = (_c.value - i * 0.2) % 1.0;
                final o = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: o),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const _Composer({
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

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
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask BetterTrack anything…',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x12),
            GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.5),
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
