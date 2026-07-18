import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/user_model.dart';
import '../../providers/booking_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/primary_button.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  const BookingDetailsScreen({super.key, this.artisan});
  final UserModel? artisan;

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (_descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      context.showSnack("Let the artisan know what you need and where.");
      return;
    }
    if (widget.artisan == null) {
      context.showSnack('Choose an artisan before sending a request.');
      return;
    }
    try {
      final bookingId = await ref
          .read(bookingControllerProvider.notifier)
          .createBooking(
            artisanId: widget.artisan!.uid,
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
          );
      if (mounted) {
        // Replace, not push: the request form is done once a booking
        // exists, so back from the detail screen should return to
        // wherever the customer was before booking (the artisan's
        // profile), not to a stale, already-submitted form.
        context.pushReplacement(AppRoutes.bookingDetail, extra: bookingId);
      }
    } catch (error) {
      if (mounted) {
        context.showSnack(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artisanName = widget.artisan?.name.isNotEmpty == true
        ? widget.artisan!.name
        : 'this artisan';
    return Scaffold(
      appBar: AppBar(title: Text('Book $artisanName')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.artisan != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.handyman_outlined),
                ),
                title: Text(artisanName),
                subtitle: Text(
                  widget.artisan!.profession ?? 'Verified artisan',
                ),
              ),
            ),
          if (widget.artisan != null) const SizedBox(height: 24),
          Text(
            'WHAT DO YOU NEED DONE?',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: "e.g. My kitchen tap is leaking and needs a new washer",
            ),
          ),
          const SizedBox(height: 20),
          Text('WHERE', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. East Legon, near A&C Mall',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 28),
          ref.watch(bookingControllerProvider).isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: 'Send Request', onPressed: _sendRequest),
          const SizedBox(height: 12),
          Text(
            "We'll let you know as soon as they respond.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
