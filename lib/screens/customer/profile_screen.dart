import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/extensions.dart';

// Shows the signed-in user's own profile. Reads the profile through
// currentUserProfileProvider rather than calling Firestore or
// FirebaseAuth directly, so it automatically shows a loading spinner while
// the profile loads and an error message if it fails.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Reads the device's GPS position through locationServiceProvider, then
  // saves it through AuthController.updateMyLocation. Used by the "Update
  // My Location" button below.
  Future<void> updateMyLocation(BuildContext context, WidgetRef ref) async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();

      await ref.read(authControllerProvider.notifier).updateMyLocation(
            position.latitude,
            position.longitude,
          );

      if (context.mounted) {
        context.showSnack("Location updated successfully");
      }
    } catch (e) {
      if (context.mounted) context.showSnack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValue<UserModel?>: loading while the profile is being fetched,
    // an error if it fails, or the loaded UserModel in data.
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("No profile found"));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),

                const SizedBox(height: 20),

                Text(
                  user.name.isEmpty ? "No name" : user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 10),

                Text(user.email),

                const SizedBox(height: 10),

                Text(user.phone),

                const SizedBox(height: 10),

                Chip(label: Text(user.role)),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: () async {
                    await context.push(AppRoutes.editProfile);
                    // Refetch the profile in case it was changed on the
                    // edit screen.
                    ref.invalidate(currentUserProfileProvider);
                  },
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text("Settings"),
                  onPressed: () {
                    context.push(AppRoutes.settings);
                  },
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text("Update My Location"),
                  onPressed: () => updateMyLocation(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
