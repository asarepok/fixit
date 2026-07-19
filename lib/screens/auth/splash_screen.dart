import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _continueFromSplash);
  }

  void _continueFromSplash() {
    if (!mounted) return;
    final uid = ref.read(authStateProvider).valueOrNull;
    context.go(uid == null ? AppRoutes.onboarding : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A near-black background rather than the logo's own navy or orange,
      // matching either exactly would make that half of the logo vanish
      // into it. This also matches the app's own dark theme surface.
      backgroundColor: const Color(0xFF14171B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/fixit_logo.png',
              width: 220,
            ),
            const SizedBox(height: 18),
            const Text(
              'Trusted artisans at your fingertips',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
