import 'package:flutter/material.dart';
import '../services/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/state_button.dart';

final _settings = AppSettings.instance;

/// Shared scaffold for every settings sub-screen.
class _SettingsScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsScaffold({required this.title, required this.children});

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
        title: Text(title, style: AppType.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x20),
        children: children,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.x12),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x16, vertical: AppSpacing.x4),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: child,
      );
}

class _SwitchRow extends StatelessWidget {
  final String flagKey;
  final String label;
  final String? subtitle;
  final bool fallback;
  const _SwitchRow(this.flagKey, this.label,
      {this.subtitle, this.fallback = true});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.primaryDark,
        title: Text(label, style: AppType.bodyLarge),
        subtitle: subtitle == null ? null : Text(subtitle!, style: AppType.caption),
        value: _settings.flag(flagKey, fallback: fallback),
        onChanged: (v) => _settings.setFlag(flagKey, v),
      ),
    );
  }
}

// ── Default currency ──
class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => _SettingsScaffold(
        title: 'Default currency',
        children: [
          for (final e in AppSettings.currencies.entries)
            _Card(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _settings.setCurrency(e.key),
                title: Text('${e.value}  ${e.key}', style: AppType.bodyLarge),
                trailing: _settings.currencyCode == e.key
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryDark)
                    : const Icon(Icons.radio_button_unchecked_rounded,
                        color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notifications ──
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => const _SettingsScaffold(
        title: 'Notifications',
        children: [
          _SwitchRow('notif_expense', 'Expense added',
              subtitle: 'When someone adds an expense to your group'),
          _SwitchRow('notif_settlement', 'Settlements',
              subtitle: 'When a balance is settled'),
          _SwitchRow('notif_budget', 'Budget alerts',
              subtitle: 'When a budget is close to or over its limit'),
          _SwitchRow('notif_ai', 'AI suggestions',
              subtitle: 'Smart nudges from BetterTrack AI'),
        ],
      ),
    );
  }
}

// ── AI preferences ──
class AiPreferencesScreen extends StatelessWidget {
  const AiPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => _SettingsScaffold(
        title: 'AI preferences',
        children: [
          _Card(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primaryDark),
              title: Text('Model', style: AppType.bodyLarge),
              trailing: Text('Gemini 2.5 Flash', style: AppType.body),
            ),
          ),
          const _SwitchRow('ai_suggestions', 'Smart suggestions',
              subtitle: 'Let the assistant suggest splits and categories'),
          const _SwitchRow('ai_autodraft', 'Auto-draft from chat',
              subtitle: 'Turn “I spent ₹500 on lunch” into a draft expense'),
          const _SwitchRow('ai_insights', 'Weekly insights',
              subtitle: 'A short spending summary every week'),
        ],
      ),
    );
  }
}

// ── Privacy & security ──
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => const _SettingsScaffold(
        title: 'Privacy & security',
        children: [
          _SwitchRow('sec_applock', 'App lock',
              subtitle: 'Require Face ID / passcode to open', fallback: false),
          _SwitchRow('sec_hideamounts', 'Hide amounts',
              subtitle: 'Blur balances on the dashboard', fallback: false),
          _SwitchRow('sec_analytics', 'Share anonymous analytics',
              subtitle: 'Help improve BetterTrack', fallback: true),
        ],
      ),
    );
  }
}

// ── Payment methods ──
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.x20, AppSpacing.x20,
            AppSpacing.x20, MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.x20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add payment method', style: AppType.h2),
            const SizedBox(height: AppSpacing.x16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                  hintText: 'e.g. UPI · you@okhdfc / Card •••• 1234'),
            ),
            const SizedBox(height: AppSpacing.x20),
            StateButton(
              label: 'Add',
              icon: Icons.add_rounded,
              onPressed: () async {
                final v = controller.text.trim();
                if (v.isEmpty) return false;
                await _settings.addPayment(v);
                if (ctx.mounted) Navigator.of(ctx).pop(true);
                return true;
              },
            ),
          ],
        ),
      ),
    );
    if (added == true) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Payment method added'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final methods = _settings.paymentMethods;
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
            title: Text('Payment methods', style: AppType.h3),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            onPressed: () => _add(context),
            icon: const Icon(Icons.add_rounded),
            label: Text('Add', style: AppType.bodyLarge),
          ),
          body: methods.isEmpty
              ? Center(child: Text('No payment methods yet.', style: AppType.body))
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.x20),
                  children: [
                    for (final m in methods)
                      _Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.account_balance_wallet_rounded,
                              color: AppColors.textPrimary),
                          title: Text(m, style: AppType.bodyLarge),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error),
                            onPressed: () => _settings.removePayment(m),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

// ── Help & support ──
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = {
    'How do I split an expense?':
        'Open a group, tap Add expense, enter the amount and who paid — the '
        'split is shared equally by default.',
    'How do I invite someone?':
        'Open a group, tap the share icon, and send them the 6-character code '
        'or the invite link. They tap Join and enter the code.',
    'Is my data private?':
        'Your data stays in your backend. You can turn off anonymous analytics '
        'under Privacy & security.',
    'How does the AI assistant work?':
        'It uses Gemini to understand messages like “I spent ₹500 on lunch” and '
        'drafts an expense for you to confirm.',
  };

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Help & support',
      children: [
        for (final e in _faqs.entries)
          _Card(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: AppSpacing.x12),
                title: Text(e.key, style: AppType.bodyLarge),
                iconColor: AppColors.primaryDark,
                children: [Text(e.value, style: AppType.body)],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.x8),
        _Card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline_rounded,
                color: AppColors.textPrimary),
            title: Text('Contact support', style: AppType.bodyLarge),
            subtitle: Text('support@bettertrack.ai', style: AppType.caption),
            onTap: () => showSuccess(context, 'support@bettertrack.ai'),
          ),
        ),
      ],
    );
  }
}

// ── Edit profile ──
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: _settings.name);
  late final _email = TextEditingController(text: _settings.email);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Edit profile',
      children: [
        Text('Name', style: AppType.caption),
        const SizedBox(height: AppSpacing.x8),
        TextField(controller: _name),
        const SizedBox(height: AppSpacing.x16),
        Text('Email', style: AppType.caption),
        const SizedBox(height: AppSpacing.x8),
        TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: AppSpacing.x24),
        Builder(builder: (context) {
          return StateButton(
            label: 'Save changes',
            icon: Icons.check_rounded,
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await _settings.setProfile(_name.text.trim(), _email.text.trim());
              nav.pop();
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Profile updated'),
                ));
              return true;
            },
          );
        }),
      ],
    );
  }
}
