import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {paystackSecretKey} from "../paystack/config";
import {verifyTransaction} from "../paystack/client";

const db = () => admin.firestore();

/** Polled by the "Confirm Payment" screen a few times right after the
 * checkout UI closes, the one deliberate exception to this app's usual
 * fetch-on-open pattern, since this wait is short and bounded. Once
 * resolved once, it stops calling Paystack and just returns the stored
 * status. This is also the only thing that ever trusts a charge actually
 * went through, never the checkout UI's own callback, see
 * paystackWebhook.ts for the other place that's independently true. */
export const checkPaystackPaymentStatus = onCall(
  {secrets: [paystackSecretKey]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in first.");
    }

    const {paymentId} = request.data as {paymentId?: string};
    if (!paymentId) {
      throw new HttpsError("invalid-argument", "paymentId is required.");
    }

    const paymentRef = db().collection("payments").doc(paymentId);
    const payment = (await paymentRef.get()).data();

    if (!payment) {
      throw new HttpsError("not-found", "Payment not found.");
    }
    if (payment.customerId !== uid) {
      throw new HttpsError("permission-denied", "This isn't your payment.");
    }

    if (payment.status !== "pending") {
      return {status: payment.status};
    }

    const paystackStatus = await verifyTransaction(
      payment.paystackReference,
      paystackSecretKey.value()
    );

    if (paystackStatus === "success") {
      await paymentRef.update({status: "held_in_escrow"});
      await db()
        .collection("bookings")
        .doc(payment.bookingId)
        .update({paymentStatus: "held_in_escrow"});
      return {status: "held_in_escrow"};
    }

    if (paystackStatus === "failed" || paystackStatus === "abandoned") {
      await paymentRef.update({status: "failed"});
      await db()
        .collection("bookings")
        .doc(payment.bookingId)
        .update({paymentStatus: "pending"});
      return {status: "failed"};
    }

    return {status: "pending"};
  }
);
