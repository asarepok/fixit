import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/verification_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

class ArtisanApplicationScreen extends ConsumerStatefulWidget {
  const ArtisanApplicationScreen({super.key});

  @override
  ConsumerState<ArtisanApplicationScreen> createState() =>
      _ArtisanApplicationScreenState();
}

class _ArtisanApplicationScreenState
    extends ConsumerState<ArtisanApplicationScreen> {
  final _professionController = TextEditingController();
  final _bioController = TextEditingController();
  XFile? _document;

  @override
  void dispose() {
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDocument() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null && mounted) setState(() => _document = file);
  }

  Future<void> _submit() async {
    if (_professionController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty ||
        _document == null) {
      context.showSnack(
        'Complete your profession, bio, and proof of identity.',
      );
      return;
    }

    try {
      await ref
          .read(verificationControllerProvider.notifier)
          .submitApplication(
            profession: _professionController.text.trim(),
            bio: _bioController.text.trim(),
            document: _document!,
          );
      if (mounted) context.go(AppRoutes.artisanApplicationStatus);
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    }
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
            onTap: _selectDocument,
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
                    _document != null
                        ? Icons.check_circle
                        : Icons.cloud_upload_outlined,
                    color: _document != null
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _document != null
                        ? 'Proof selected'
                        : 'Tap to upload a photo',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          ref.watch(verificationControllerProvider).isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: 'Submit Application', onPressed: _submit),
        ],
      ),
    );
  }
}
