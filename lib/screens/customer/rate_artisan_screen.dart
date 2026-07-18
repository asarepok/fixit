import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme.dart';
import '../../providers/review_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

class RateArtisanArgs {
  const RateArtisanArgs({required this.bookingId, required this.artisanName});
  final String bookingId;
  final String artisanName;
}

class RateArtisanScreen extends ConsumerStatefulWidget {
  const RateArtisanScreen({super.key, required this.args});
  final RateArtisanArgs args;

  @override
  ConsumerState<RateArtisanScreen> createState() => _RateArtisanScreenState();
}

class _RateArtisanScreenState extends ConsumerState<RateArtisanScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  XFile? _photo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null && mounted) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      context.showSnack('Choose a star rating first.');
      return;
    }
    try {
      await ref.read(reviewControllerProvider.notifier).submitReview(
            bookingId: widget.args.bookingId,
            rating: _rating,
            comment: _commentController.text.trim(),
            photo: _photo,
          );
      if (mounted) {
        context.showSnack('Thanks for the review!');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        context.showSnack(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(reviewControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Artisan')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How was ${widget.args.artisanName}?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your review helps customers find trusted artisans.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.accentOf(context),
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'COMMENT (OPTIONAL)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Share what went well.',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ADD A PHOTO (OPTIONAL)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          _PhotoPicker(photo: _photo, onTap: _pickPhoto, onClear: () => setState(() => _photo = null)),
          const SizedBox(height: 28),
          loading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: 'Submit Review', onPressed: _submit),
        ],
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photo, required this.onTap, required this.onClear});
  final XFile? photo;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Image.file(
              File(photo!.path),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
            const SizedBox(height: 6),
            const Text('Tap to add a photo of the work'),
          ],
        ),
      ),
    );
  }
}
