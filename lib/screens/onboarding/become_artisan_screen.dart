import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../widgets/primary_button.dart';

class BecomeArtisanScreen extends StatelessWidget {
  const BecomeArtisanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer Your Services')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Icon(
            Icons.handyman_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Become an artisan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            "You'll need three things: your trade, a short bio, and a photo of an ID or trade certificate. Review usually takes 1–2 days.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          const _Step(number: '1', text: 'Tell us your profession'),
          const SizedBox(height: 12),
          const _Step(
            number: '2',
            text: 'Write a short bio customers will see',
          ),
          const SizedBox(height: 12),
          const _Step(number: '3', text: 'Upload proof of ID or certification'),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Get Started',
            onPressed: () => context.push(AppRoutes.artisanApplication),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).inputDecorationTheme.enabledBorder!.borderSide.color,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$number. $text',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
