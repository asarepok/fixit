import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

// Lets the signed-in user edit their name and phone number. Saving is done
// through AuthController.updateProfile, this screen never calls Firestore
// directly.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    // ProfileScreen is still on the navigation stack underneath this
    // screen and is already watching currentUserProfileProvider, so its
    // value is already loaded here. Using ref.read with valueOrNull avoids
    // fetching the profile a second time just to fill in these fields.
    final user = ref.read(currentUserProfileProvider).valueOrNull;
    nameController = TextEditingController(text: user?.name);
    phoneController = TextEditingController(text: user?.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Saves the edited name and phone number, then returns to the previous
  // screen. ProfileScreen refreshes its own copy of the profile after this
  // screen is popped.
  Future<void> updateProfile() async {
    await ref.read(authControllerProvider.notifier).updateProfile(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
