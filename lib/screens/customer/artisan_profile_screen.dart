import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/user_model.dart';
import '../../widgets/primary_button.dart';

class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key, this.artisan});
  final UserModel? artisan;

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Icon(Icons.star_rounded, color: Color(0xFFFFA62B)),
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
              const Spacer(),
              PrimaryButton(
                text: 'Book Service',
                onPressed: () =>
                    context.push(AppRoutes.bookingDetails, extra: artisan),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
