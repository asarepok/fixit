import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

// The account creation screen. Only draws the form and validates that
// fields are filled in, the actual account creation and saving the new
// user document both happen in AuthController.register.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Checks the fields are filled in, then calls AuthController.register,
  // which creates the Firebase Auth account and the user's Firestore
  // document. Every new account is a plain customer, Become an Artisan is
  // a separate action reachable later from Home/Profile, not part of
  // signing up.
  Future<void> registerUser() async {
    if (Validators.isEmpty(_nameController.text) ||
        Validators.isEmpty(_emailController.text) ||
        Validators.isEmpty(_phoneController.text) ||
        Validators.isEmpty(_passwordController.text)) {
      context.showSnack("Please fill all fields");
      return;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      context.showSnack('Enter a valid email address.');
      return;
    }
    if (!Validators.isValidGhanaPhone(_phoneController.text)) {
      context.showSnack('Enter a valid Ghana phone number, e.g. 024 555 0142.');
      return;
    }
    if (_passwordController.text.length < 6) {
      context.showSnack('Password must be at least 6 characters.');
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (mounted) {
        ref.read(appModeProvider.notifier).state = AppMode.customer;
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        context.showSnack(e.toString().replaceFirst("Exception: ", ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // True while registerUser's call to AuthController is in flight.
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Book reliable artisans in just a few taps.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            Text('FULL NAME', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Your full name'),
            ),

            const SizedBox(height: 18),
            Text('EMAIL', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),

            const SizedBox(height: 18),
            Text('PHONE', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '024 000 0000'),
            ),

            const SizedBox(height: 18),
            Text('PASSWORD', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Create a password'),
            ),

            const SizedBox(height: 28),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: "Create Account",
                    onPressed: registerUser,
                  ),
          ],
        ),
      ),
    );
  }
}
