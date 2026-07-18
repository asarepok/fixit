import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/verification_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/empty_state.dart';

class ManageArtisansScreen extends ConsumerWidget {
  const ManageArtisansScreen({super.key});
  Future<void> _review(
    BuildContext context,
    WidgetRef ref, {
    required String requestId,
    required String artisanId,
    required bool approved,
  }) async {
    try {
      await ref
          .read(verificationControllerProvider.notifier)
          .reviewApplication(
            requestId: requestId,
            artisanId: artisanId,
            approved: approved,
          );
      if (context.mounted) {
        context.showSnack(
          approved ? 'Artisan approved.' : 'Application declined.',
        );
      }
    } catch (error) {
      if (context.mounted) context.showSnack(error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(pendingApplicationsProvider);
    final loading = ref.watch(verificationControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Artisans')),
      body: applications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const EmptyState(
                icon: Icons.fact_check_outlined,
                title: 'No applications awaiting review',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.profession,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(item.bio),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () => _review(
                                          context,
                                          ref,
                                          requestId: item.id,
                                          artisanId: item.artisanId,
                                          approved: false,
                                        ),
                                  child: const Text('Decline'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: loading
                                      ? null
                                      : () => _review(
                                          context,
                                          ref,
                                          requestId: item.id,
                                          artisanId: item.artisanId,
                                          approved: true,
                                        ),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
