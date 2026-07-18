import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../providers/review_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/primary_button.dart';

class ArtisanProfileScreen extends ConsumerWidget {
  const ArtisanProfileScreen({super.key, this.artisan});
  final UserModel? artisan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = artisan?.name.isNotEmpty == true ? artisan!.name : 'Artisan';
    final profession = artisan?.profession?.isNotEmpty == true
        ? artisan!.profession!
        : 'Verified artisan';
    final rating = artisan?.averageRating ?? 0;
    final initials = name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Profile')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      profession,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.accentOf(context)),
                        const SizedBox(width: 4),
                        Text(
                          rating == 0
                              ? 'New artisan'
                              : '${rating.toStringAsFixed(1)} (${artisan?.ratingCount ?? 0})',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('ABOUT', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 10),
                  Text(
                    artisan?.bio?.isNotEmpty == true
                        ? artisan!.bio!
                        : 'This verified artisan is ready to help with your service request.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (artisan != null) ...[
                    const SizedBox(height: 32),
                    Text('REVIEWS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 10),
                    _ReviewsList(artisanId: artisan!.uid),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: PrimaryButton(
                  text: 'Book Service',
                  onPressed: () =>
                      context.push(AppRoutes.bookingDetails, extra: artisan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsList extends ConsumerWidget {
  const _ReviewsList({required this.artisanId});
  final String artisanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(artisanReviewsProvider(artisanId));
    return reviewsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        'Unable to load reviews right now.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Text(
            'No reviews yet. Be the first to book and leave one.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          children: reviews.map((review) => _ReviewTile(review: review)).toList(),
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: AppColors.accentOf(context),
                  ),
                ),
              ),
              if (review.createdAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  timeAgo(review.createdAt!),
                  style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
