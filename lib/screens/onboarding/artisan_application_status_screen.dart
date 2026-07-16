import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class ArtisanApplicationStatusScreen extends ConsumerWidget {
  const ArtisanApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Application Status')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (user) {
          final rejected = user?.artisanStatus == 'rejected';
          final color = rejected ? AppColors.error : AppColors.warning;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          rejected
                              ? Icons.cancel_outlined
                              : Icons.hourglass_top_rounded,
                          color: color,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          rejected
                              ? 'Application needs changes'
                              : 'Under review',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      rejected
                          ? 'Your application was not approved. You can update it and apply again once the verification workflow is available.'
                          : "We'll notify you once an admin reviews your application. This usually takes 1–2 days.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
