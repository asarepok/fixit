import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/user_model.dart';

// An artisan result: avatar, name with a verified badge (every artisan
// shown here has passed review, so that badge is doing real work, not
// decoration), profession as a tonal pill rather than plain caption text,
// and rating pulled out into its own badge on the trailing edge instead
// of buried inline with everything else. Distance, when known, sits next
// to the rating so the two numbers a customer actually compares (how far,
// how good) read together.
class ArtisanCard extends StatelessWidget {
  const ArtisanCard({
    super.key,
    required this.artisan,
    this.distanceKm,
    this.onTap,
  });

  final UserModel artisan;
  final double? distanceKm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rating = artisan.averageRating ?? 0;
    final initials = artisan.name.trim().isEmpty
        ? 'A'
        : artisan.name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((word) => word[0])
              .join();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primary,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          artisan.name.isEmpty ? 'Unknown Artisan' : artisan.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.verified_rounded, size: 16, color: colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      artisan.profession?.isNotEmpty == true
                          ? artisan.profession!
                          : 'Verified artisan',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.accentOf(context), size: 17),
                    const SizedBox(width: 2),
                    Text(
                      rating == 0 ? 'New' : rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (artisan.ratingCount != null && artisan.ratingCount! > 0)
                  Text(
                    '(${artisan.ratingCount})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                if (distanceKm != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${distanceKm!.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
