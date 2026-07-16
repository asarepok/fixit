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
      final role = await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

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
      if (mounted) context.showSnack(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  @override
  Widget build(BuildContext context) {
    // isLoading comes from AuthController's AsyncNotifier state, true while
    // login() is in flight. Used below to show a spinner instead of the
    // login button.
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push(AppRoutes.forgotPassword);
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 25),

              isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      text: "Login",
                      onPressed: loginUser,
                    ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.register);
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
