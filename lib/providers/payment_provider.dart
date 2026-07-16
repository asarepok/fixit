import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/functions_service.dart';
import 'auth_provider.dart';
import 'booking_provider.dart';

final functionsServiceProvider =
    Provider<FunctionsService>((ref) => FunctionsService());

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    ref.watch(functionsServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// A single payment, for showing its status on a booking, keyed by
// paymentId.
final paymentProvider =
    FutureProvider.autoDispose.family<Payment?, String>((ref, paymentId) {
  return ref.watch(paymentRepositoryProvider).getPayment(paymentId);
});

// Every payment, for the admin Manage Payments screen.
final allPaymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) {
  return ref.watch(paymentRepositoryProvider).getAllPayments();
});

class PaymentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Starts the MoMo charge for an accepted, quoted booking. The "Confirm
  // on Your Phone" screen then polls checkStatus with the returned id.
  Future<String> initiatePayment(String bookingId) async {
    state = const AsyncLoading();
    try {
      final paymentId =
          await ref.read(paymentRepositoryProvider).initiatePayment(bookingId);
      state = const AsyncData(null);
      return paymentId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Deliberately does not touch AsyncNotifier state, this gets called
  // every few seconds by a polling screen and shouldn't flash a loading
  // state each time.
  Future<PaymentStatus> checkStatus(String bookingId, String paymentId) async {
    final status =
        await ref.read(paymentRepositoryProvider).checkPaymentStatus(paymentId);
    ref.invalidate(paymentProvider(paymentId));
    ref.invalidate(bookingProvider(bookingId));
    return status;
  }

  Future<void> releaseEscrow(String bookingId, String paymentId) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).releaseEscrow(paymentId);
      ref.invalidate(paymentProvider(paymentId));
      ref.invalidate(bookingProvider(bookingId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Admin only, for disputes.
  Future<void> refund(String bookingId, String paymentId, {String? reason}) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).refund(paymentId, reason: reason);
      ref.invalidate(paymentProvider(paymentId));
      ref.invalidate(bookingProvider(bookingId));
      ref.invalidate(allPaymentsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, void>(PaymentController.new);
