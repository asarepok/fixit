import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  momoCollectionApiKey,
  momoCollectionApiUser,
  momoCollectionSubscriptionKey,
} from "../momo/config";
import {requestToPay} from "../momo/client";

const db = () => admin.firestore();

/** Called from the "Pay with MoMo" screen once a booking has been
 * accepted with a quote. Creates the payment record and kicks off the
 * MoMo collection request, the customer approves it on their own phone,
 * the "Confirm on Your Phone" screen then polls checkMomoPaymentStatus. */
export const initiateMomoPayment = onCall(
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

    const {bookingId} = request.data as {bookingId?: string};
    if (!bookingId) {
      throw new HttpsError("invalid-argument", "bookingId is required.");
    }

    const bookingRef = db().collection("bookings").doc(bookingId);
    const booking = (await bookingRef.get()).data();

    if (!booking) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    if (booking.customerId !== uid) {
      throw new HttpsError("permission-denied", "This isn't your booking.");
    }
    if (booking.status !== "accepted") {
      throw new HttpsError(
        "failed-precondition",
        "This booking hasn't been accepted with a quote yet."
      );
    }
    if (!booking.amount) {
      throw new HttpsError(
        "failed-precondition",
        "No quote has been set for this booking yet."
      );
    }

    const customer = (await db().collection("users").doc(uid).get()).data();
    const phoneNumber = customer?.phone;
    if (!phoneNumber) {
      throw new HttpsError(
        "failed-precondition",
        "No phone number on file for this account."
      );
    }

    const paymentRef = db().collection("payments").doc();

    const referenceId = await requestToPay({
      amount: booking.amount,
      phoneNumber,
      externalId: paymentRef.id,
      payerMessage: `FixIt GH booking ${bookingId}`,
      creds: {
        subscriptionKey: momoCollectionSubscriptionKey.value(),
        apiUser: momoCollectionApiUser.value(),
        apiKey: momoCollectionApiKey.value(),
      },
    });

    await paymentRef.set({
      bookingId,
      customerId: booking.customerId,
      artisanId: booking.artisanId,
      amount: booking.amount,
      status: "pending",
      momoReferenceId: referenceId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await bookingRef.update({
      paymentStatus: "pending",
      paymentId: paymentRef.id,
    });

    return {paymentId: paymentRef.id};
  }
);
