import 'package:flutter/material.dart';

import '../models/user_model.dart';

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
    final rating = artisan.averageRating ?? 0;
    final initials = artisan.name.trim().isEmpty
        ? 'A'
        : artisan.name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((word) => word[0])
              .join();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.name.isEmpty ? 'Unknown Artisan' : artisan.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      artisan.profession?.isNotEmpty == true
                          ? artisan.profession!
                          : 'Verified artisan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFA62B),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating == 0 ? 'New' : rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (artisan.ratingCount != null)
                          Text(
                            ' (${artisan.ratingCount})',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (distanceKm != null)
                          Text(
                            ' · ${distanceKm!.toStringAsFixed(1)} km away',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
