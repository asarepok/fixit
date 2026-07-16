import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

// The login screen. Only draws the form and reacts to the result of
// signing in, it does not call Firebase itself. Signing in and looking up
// the role both happen in AuthController (lib/providers/auth_provider.dart).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Calls AuthController.login, which signs the user in with Firebase Auth
  // and looks up their role in Firestore. Every account opens Home except
  // admins, artisan mode is switched into from Home, not chosen here.
  Future<void> loginUser() async {
    try {
      final role = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (!mounted) return;

      if (role == "admin") {
        context.go(AppRoutes.adminDashboard);
      } else {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // AuthService turns any FirebaseAuthException into a plain Exception,
      // so this can catch a normal Exception and does not need to import
      // firebase_auth just to read the error message.
      if (mounted) {
        context.showSnack(e.toString().replaceFirst("Exception: ", ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // isLoading comes from AuthController's AsyncNotifier state, true while
    // login() is in flight. Used below to show a spinner instead of the
    // login button.
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to find trusted help near you.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            Text('EMAIL', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),
            const SizedBox(height: 20),
            Text('PASSWORD', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(text: 'Login', onPressed: loginUser),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
