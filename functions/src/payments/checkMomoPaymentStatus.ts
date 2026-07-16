import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  momoCollectionApiKey,
  momoCollectionApiUser,
  momoCollectionSubscriptionKey,
} from "../momo/config";
import {getRequestToPayStatus} from "../momo/client";

const db = () => admin.firestore();

/** Polled by the "Confirm on Your Phone" screen every few seconds while
 * it's open, the one deliberate exception to this app's usual
 * fetch-on-open pattern, since this wait is short and bounded. Once
 * resolved once, it stops calling MoMo and just returns the stored
 * status. */
export const checkMomoPaymentStatus = onCall(
  {
    secrets: [
      momoCollectionSubscriptionKey,
      momoCollectionApiUser,
      momoCollectionApiKey,
    ],
  },
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

    const momoStatus = await getRequestToPayStatus(payment.momoReferenceId, {
      subscriptionKey: momoCollectionSubscriptionKey.value(),
      apiUser: momoCollectionApiUser.value(),
      apiKey: momoCollectionApiKey.value(),
    });

    if (momoStatus === "SUCCESSFUL") {
      await paymentRef.update({status: "held_in_escrow"});
      await db()
        .collection("bookings")
        .doc(payment.bookingId)
        .update({paymentStatus: "held_in_escrow"});
      return {status: "held_in_escrow"};
    }

    if (momoStatus === "FAILED") {
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
