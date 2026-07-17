import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart';

const _paymentsCollection = "payments";

// Everything about moving money: initiating a Paystack charge, checking if
// it's been confirmed, releasing escrow to the artisan, and refunding.
// Every write in this flow goes through a Cloud Function, never a direct
// Firestore write, see functions/src/payments for the actual Paystack
// calls. This repository only ever reads payment documents directly.
class PaymentRepository {
  final FunctionsService _functionsService;
  final FirestoreService _firestoreService;

  PaymentRepository(this._functionsService, this._firestoreService);

  // Starts a Paystack charge for an accepted, quoted booking. Returns the
  // new payment's id (used to check status next) and the authorization
  // URL, Paystack's hosted checkout page, which the payment screen opens
  // in a webview to actually take the payment.
  Future<PaystackInitiation> initiatePayment(String bookingId) async {
    final result = await _functionsService.call(
      "initiatePaystackPayment",
      {"bookingId": bookingId},
    );
    return PaystackInitiation(
      paymentId: result["paymentId"] as String,
      authorizationUrl: result["authorizationUrl"] as String,
    );
  }

  // Called once the checkout UI closes, to get Paystack's own, verified
  // word on whether the charge actually went through, never trust the
  // checkout UI's own reported status for that.
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    final result = await _functionsService.call(
      "checkPaystackPaymentStatus",
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

  // A single payment, live. Updates on its own the moment its status
  // changes, for example the instant checkPaystackPaymentStatus (or the
  // webhook) confirms a charge, no polling or manual refresh needed.
  Stream<Payment?> streamPayment(String paymentId) {
    return _firestoreService
        .streamDocumentWithId(_paymentsCollection, paymentId)
        .map((data) => data == null ? null : Payment.fromMap(data));
  }

  // Every payment, live, for the admin Manage Payments screen.
  Stream<List<Payment>> streamAllPayments() {
    return _firestoreService
        .streamCollectionOrdered(
          _paymentsCollection,
          orderBy: "createdAt",
          descending: true,
        )
        .map((docs) => docs.map(Payment.fromMap).toList());
  }
}
