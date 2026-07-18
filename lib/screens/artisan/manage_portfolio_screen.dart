import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/portfolio_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/photo_viewer.dart';

// Lets an artisan build the "my work" gallery customers see on their
// public profile: add a photo, remove one, see what's live right now.
class ManagePortfolioScreen extends ConsumerWidget {
  const ManagePortfolioScreen({super.key});

  Future<void> _addPhoto(BuildContext context, WidgetRef ref) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    try {
      await ref.read(portfolioControllerProvider.notifier).addPhoto(file);
    } catch (error) {
      if (context.mounted) {
        context.showSnack(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PortfolioItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this photo?'),
        content: const Text('It will no longer show on your public profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(portfolioControllerProvider.notifier).deletePhoto(item);
    } catch (error) {
      if (context.mounted) {
        context.showSnack(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authRepositoryProvider).currentUserId;
    final portfolioAsync = uid == null
        ? const AsyncValue<List<PortfolioItem>>.data([])
        : ref.watch(portfolioProvider(uid));
    final loading = ref.watch(portfolioControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('My Work')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : () => _addPhoto(context, ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add Photo'),
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No photos yet',
              message: 'Add photos of work you\'ve done, customers see these on your profile.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InkWell(
                      onTap: () => openPhoto(context, item.imageUrl),
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => _confirmDelete(context, ref, item),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
