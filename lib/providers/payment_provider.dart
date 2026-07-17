import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/functions_service.dart';
import 'auth_provider.dart';

final functionsServiceProvider =
    Provider<FunctionsService>((ref) => FunctionsService());

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    ref.watch(functionsServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// A single payment, live, for showing its status on a booking, keyed by
// paymentId.
final paymentProvider =
    StreamProvider.autoDispose.family<Payment?, String>((ref, paymentId) {
  return ref.watch(paymentRepositoryProvider).streamPayment(paymentId);
});

// Every payment, live, for the admin Manage Payments screen.
final allPaymentsProvider = StreamProvider.autoDispose<List<Payment>>((ref) {
  return ref.watch(paymentRepositoryProvider).streamAllPayments();
});

// Every action a payment can go through: initiating a charge, checking its
// status, releasing escrow, refunding. None of these need to invalidate
// paymentProvider/bookingProvider/allPaymentsProvider afterward anymore,
// they're all live streams now and pick up every write on their own,
// including the ones the Paystack webhook makes server-side.
class PaymentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Starts the Paystack charge for an accepted, quoted booking. The
  // payment screen uses the returned authorization URL to open Paystack's
  // hosted checkout in a webview, then checks status with the payment id
  // afterward.
  Future<PaystackInitiation> initiatePayment(String bookingId) async {
    state = const AsyncLoading();
    try {
      final initiation =
          await ref.read(paymentRepositoryProvider).initiatePayment(bookingId);
      state = const AsyncData(null);
      return initiation;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Deliberately does not touch AsyncNotifier state, this gets called
  // every few seconds by a polling screen and shouldn't flash a loading
  // state each time.
  Future<PaymentStatus> checkStatus(String bookingId, String paymentId) async {
    return ref.read(paymentRepositoryProvider).checkPaymentStatus(paymentId);
  }

  Future<void> releaseEscrow(String bookingId, String paymentId) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).releaseEscrow(paymentId);
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
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, void>(PaymentController.new);
