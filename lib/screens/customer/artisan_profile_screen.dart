import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../models/portfolio_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/grouped_card.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/user_name_label.dart';

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
    final reviewCount = artisan?.ratingCount ?? 0;
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
                  const SizedBox(height: 20),
                  _RatingSummary(rating: rating, reviewCount: reviewCount),
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
                    _PortfolioSection(artisanId: artisan!.uid),
                    const SizedBox(height: 32),
                    SectionHeading(
                      eyebrow: 'Feedback',
                      title: reviewCount == 0 ? 'Reviews' : 'Reviews ($reviewCount)',
                    ),
                    const SizedBox(height: 12),
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

// A grid of the artisan's own work photos, if they've added any. Hidden
// entirely rather than showing an empty state, an artisan with no
// portfolio yet just doesn't get this section on their public profile.
class _PortfolioSection extends ConsumerWidget {
  const _PortfolioSection({required this.artisanId});
  final String artisanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider(artisanId));
    final items = portfolioAsync.valueOrNull ?? const <PortfolioItem>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: 'Portfolio', title: 'My Work'),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => openPhoto(context, item.imageUrl),
                    child: Image.network(
                      item.imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// The number a customer actually scans for before booking, given its own
// visual weight instead of sharing a line with the profession caption.
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating, required this.reviewCount});
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (rating == 0) {
      return Center(
        child: Text(
          'New artisan · no reviews yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                index < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: AppColors.accentOf(context),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reviewCount == 1 ? '1 review' : '$reviewCount reviews',
            style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
          ),
        ],
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
        return GroupedCard(
          indent: 60,
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
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(uid: review.customerId, radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: UserNameLabel(
                        uid: review.customerId,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (review.createdAt != null)
                      Text(
                        timeAgo(review.createdAt!),
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 15,
                      color: AppColors.accentOf(context),
                    ),
                  ),
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (review.photoUrl != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => openPhoto(context, review.photoUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        review.photoUrl!,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
