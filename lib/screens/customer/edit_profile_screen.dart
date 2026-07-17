import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

// Mobile money networks Paystack can pay an artisan out to in Ghana. Kept
// as a fixed list here rather than fetched from Paystack, since a person
// picking their own network from three familiar names is simpler than
// showing them Paystack's full mobile-money-provider list.
const _momoNetworks = ['MTN', 'Vodafone', 'AirtelTigo'];

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _momoNetwork;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProfileProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _momoNetwork = user?.momoNetwork;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      context.showSnack('Enter your name and phone number.');
      return;
    }
    if (!Validators.isValidGhanaPhone(_phoneController.text.trim())) {
      context.showSnack('Enter a valid Ghana phone number, e.g. 024 555 0142.');
      return;
    }
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            momoNetwork: _momoNetwork,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) context.showSnack(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('NAME', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 20),
          Text('PHONE', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '024 000 0000'),
          ),
          if (user?.isArtisan == true) ...[
            const SizedBox(height: 20),
            Text(
              'MOBILE MONEY NETWORK',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Used to pay you out once a customer releases payment.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _momoNetwork,
              hint: const Text('Select a network'),
              items: _momoNetworks
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (value) => setState(() => _momoNetwork = value),
            ),
          ],
          const SizedBox(height: 28),
          loading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: 'Save Changes', onPressed: _save),
        ],
      ),
    );
  }
}
