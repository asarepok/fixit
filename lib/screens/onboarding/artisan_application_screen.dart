import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

class ArtisanApplicationScreen extends StatefulWidget {
  const ArtisanApplicationScreen({super.key});

  @override
  State<ArtisanApplicationScreen> createState() =>
      _ArtisanApplicationScreenState();
}

class _ArtisanApplicationScreenState extends State<ArtisanApplicationScreen> {
  final _professionController = TextEditingController();
  final _bioController = TextEditingController();
  bool _hasSelectedProof = false;

  @override
  void dispose() {
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_professionController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty ||
        !_hasSelectedProof) {
      context.showSnack(
        'Complete your profession, bio, and proof of identity.',
      );
      return;
    }

    context.showSnack(
      'Application submission will be connected when the verification provider is available.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Application')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('PROFESSION', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _professionController,
            decoration: const InputDecoration(hintText: 'e.g. Electrician'),
          ),
          const SizedBox(height: 20),
          Text('SHORT BIO', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell customers about your experience and services.',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ID OR CERTIFICATE',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _hasSelectedProof = true),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).inputDecorationTheme.enabledBorder!.borderSide.color,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasSelectedProof
                        ? Icons.check_circle
                        : Icons.cloud_upload_outlined,
                    color: _hasSelectedProof
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasSelectedProof
                        ? 'Proof selected'
                        : 'Tap to upload a photo',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(text: 'Submit Application', onPressed: _submit),
        ],
      ),
    );
  }
}
