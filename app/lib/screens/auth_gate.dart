import 'package:flutter/material.dart';
import '../services/settings.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Shows the [LoginScreen] until the user is authenticated, then the app.
/// Reacts to [AppSettings] so sign-in / log-out switch screens instantly.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: AppSettings.instance.isLoggedIn
              ? const HomeShell(key: ValueKey('app'))
              : const LoginScreen(key: ValueKey('login')),
        );
      },
    );
  }
}
