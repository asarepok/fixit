import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart';

const _paymentsCollection = "payments";

// Everything about moving money: initiating a MoMo charge, checking if
// it's been approved, releasing escrow to the artisan, and refunding.
// Every write in this flow goes through a Cloud Function, never a direct
// Firestore write, see functions/src/payments for the actual MoMo calls.
// This repository only ever reads payment documents directly.
class PaymentRepository {
  final FunctionsService _functionsService;
  final FirestoreService _firestoreService;

  PaymentRepository(this._functionsService, this._firestoreService);

  // Starts a MoMo charge for an accepted, quoted booking. Returns the new
  // payment's id, used to poll checkPaymentStatus next.
  Future<String> initiatePayment(String bookingId) async {
    final result = await _functionsService.call(
      "initiateMomoPayment",
      {"bookingId": bookingId},
    );
    return result["paymentId"] as String;
  }

  // Polled by the "Confirm on Your Phone" screen every few seconds while
  // it's open, the one deliberate exception to this app's usual
  // fetch-on-open pattern.
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    final result = await _functionsService.call(
      "checkMomoPaymentStatus",
      {"paymentId": paymentId},
    );
    return PaymentStatus.fromValue(result["status"] as String?);
  }

  // Called by the customer once the artisan has marked the job complete,
  // pays the artisan out of escrow.
  Future<PaymentStatus> releaseEscrow(String paymentId) async {
    final result = await _functionsService.call(
      "releaseEscrowToArtisan",
      {"paymentId": paymentId},
    );
    return PaymentStatus.fromValue(result["status"] as String?);
  }

  // Admin only, for disputes. Refunds whatever's still held in escrow
  // back to the customer.
  Future<PaymentStatus> refund(String paymentId, {String? reason}) async {
    final result = await _functionsService.call(
      "refundEscrow",
      {"paymentId": paymentId, "reason": reason},
    );
    return PaymentStatus.fromValue(result["status"] as String?);
  }

  Future<Payment?> getPayment(String paymentId) async {
    final data = await _firestoreService.getDocumentWithId(
      _paymentsCollection,
      paymentId,
    );
    if (data == null) return null;
    return Payment.fromMap(data);
  }

  // Every payment, for the admin Manage Payments screen.
  Future<List<Payment>> getAllPayments() async {
    final docs = await _firestoreService.getCollectionOrdered(
      _paymentsCollection,
      orderBy: "createdAt",
      descending: true,
    );
    return docs.map(Payment.fromMap).toList();
  }
}
