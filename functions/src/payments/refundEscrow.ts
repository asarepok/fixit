import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  momoDisbursementApiKey,
  momoDisbursementApiUser,
  momoDisbursementSubscriptionKey,
} from "../momo/config";
import {transfer} from "../momo/client";

const db = () => admin.firestore();

async function callerIsAdmin(uid: string): Promise<boolean> {
  const user = (await db().collection("users").doc(uid).get()).data();
  return user?.role === "admin";
}

/** Called from the Manage Payments admin screen for disputes the normal
 * flow doesn't cover, refunds whatever's still held in escrow back to
 * the customer. Only reachable by an admin account. */
export const refundEscrow = onCall(
  {
    secrets: [
      momoDisbursementSubscriptionKey,
      momoDisbursementApiUser,
      momoDisbursementApiKey,
    ],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid || !(await callerIsAdmin(uid))) {
      throw new HttpsError("permission-denied", "Admin only.");
    }

    const {paymentId, reason} = request.data as {
      paymentId?: string;
      reason?: string;
    };
    if (!paymentId) {
      throw new HttpsError("invalid-argument", "paymentId is required.");
    }

    const paymentRef = db().collection("payments").doc(paymentId);
    const payment = (await paymentRef.get()).data();

    if (!payment) {
      throw new HttpsError("not-found", "Payment not found.");
    }
    if (payment.status !== "held_in_escrow") {
      throw new HttpsError(
        "failed-precondition",
        "Only money still held in escrow can be refunded."
      );
    }

    const customer = (
      await db().collection("users").doc(payment.customerId).get()
    ).data();
    const phoneNumber = customer?.phone;
    if (!phoneNumber) {
      throw new HttpsError(
        "failed-precondition",
        "No phone number on file for the customer."
      );
    }

    await transfer({
      amount: payment.amount,
      phoneNumber,
      externalId: paymentId,
      payerMessage: `FixIt GH refund, booking ${payment.bookingId}`,
      creds: {
        subscriptionKey: momoDisbursementSubscriptionKey.value(),
        apiUser: momoDisbursementApiUser.value(),
        apiKey: momoDisbursementApiKey.value(),
      },
    });

    await paymentRef.update({status: "refunded", refundReason: reason ?? null});
    await db()
      .collection("bookings")
      .doc(payment.bookingId)
      .update({paymentStatus: "refunded"});

    return {status: "refunded"};
  }
);
