import 'package:flutter/material.dart';
import '../services/repository.dart';
import '../services/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/state_button.dart';

/// Sign in / Sign up screen. On success it stores the auth token in
/// [AppSettings]; the [AuthGate] then swaps to the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _obscure = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validEmail(String s) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

  Future<bool> _submit() async {
    final email = _email.text.trim();
    final pass = _password.text;
    final name = _name.text.trim();
    if (!_validEmail(email)) {
      setState(() => _error = 'Enter a valid email.');
      return false;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return false;
    }
    if (_isSignUp && name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return false;
    }
    setState(() => _error = null);
    try {
      final res = _isSignUp
          ? await Repository.instance
              .signup(name: name, email: email, password: pass)
          : await Repository.instance.login(email: email, password: pass);
      await AppSettings.instance.signIn(
        token: res['token'] as String,
        name: res['name'] as String,
        email: res['email'] as String,
      );
      return true; // AuthGate rebuilds into the app
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        showFailure(context, e.toString());
      }
      return false;
    }
  }

  Future<void> _google() async {
    try {
      // Demo Google sign-in. Real OAuth needs the iOS Firebase plist +
      // google_sign_in; here we link a demo Google identity by email.
      final email = _validEmail(_email.text.trim())
          ? _email.text.trim()
          : 'you@gmail.com';
      final res = await Repository.instance
          .googleLogin(email: email, name: 'Google User');
      await AppSettings.instance.signIn(
        token: res['token'] as String,
        name: res['name'] as String,
        email: res['email'] as String,
      );
    } catch (e) {
      if (mounted) showFailure(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.x24),
          children: [
            const SizedBox(height: AppSpacing.x40),
            // Brand mark.
            Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 36, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.x16),
            Center(child: Text('BetterTrack AI', style: AppType.h1)),
            const SizedBox(height: AppSpacing.x4),
            Center(
              child: Text(
                _isSignUp ? 'Create your account' : 'Welcome back',
                style: AppType.body,
              ),
            ),
            const SizedBox(height: AppSpacing.x32),
            // Sign in / Sign up toggle.
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Row(
                children: [
                  _toggle('Sign in', !_isSignUp, () => setState(() {
                        _isSignUp = false;
                        _error = null;
                      })),
                  _toggle('Sign up', _isSignUp, () => setState(() {
                        _isSignUp = true;
                        _error = null;
                      })),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x24),
            if (_isSignUp) ...[
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.x12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.x12),
              Text(_error!,
                  style: AppType.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.x24),
            StateButton(
              label: _isSignUp ? 'Create account' : 'Sign in',
              icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.x20),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.x12),
                  child: Text('or', style: AppType.caption),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: AppSpacing.x20),
            OutlinedButton.icon(
              onPressed: _google,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              label: Text('Continue with Google', style: AppType.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppType.bodyLarge.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
