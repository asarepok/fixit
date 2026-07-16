import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

class RateArtisanScreen extends StatefulWidget {
  const RateArtisanScreen({super.key});
  @override
  State<RateArtisanScreen> createState() => _RateArtisanScreenState();
}

class _RateArtisanScreenState extends State<RateArtisanScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Artisan')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How was the service?',
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
                  color: const Color(0xFFFFA62B),
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
          PrimaryButton(
            text: 'Submit Review',
            onPressed: () {
              if (_rating == 0) {
                context.showSnack('Choose a star rating first.');
                return;
              }
              context.showSnack(
                'Review submission will be connected when ReviewController is available.',
              );
            },
          ),
        ],
      ),
    );
  }
}
