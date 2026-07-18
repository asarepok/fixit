import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          const SizedBox(height: 28),
          loading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: 'Submit Review', onPressed: _submit),
        ],
      ),
    );
  }
}
