import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const TextField(
              decoration: InputDecoration(
                labelText: "Enter your email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 30),

            PrimaryButton(
              text: "Send Reset Link",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}