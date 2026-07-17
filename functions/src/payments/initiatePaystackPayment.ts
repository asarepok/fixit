import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {paystackSecretKey} from "../paystack/config";
import {initializeTransaction} from "../paystack/client";

const db = () => admin.firestore();

/** Called from the "Pay with Paystack" screen once a booking has been
 * accepted with a quote. Creates the payment record and starts a Paystack
 * transaction, returning the authorization URL, Paystack's hosted
 * checkout page, which the app opens in a plain webview so every channel
 * (mobile money, card, ...) is available. The "Confirm Payment" screen
 * then calls checkPaystackPaymentStatus once the webview redirects back,
 * which is the only thing that ever trusts a charge actually went
 * through. */
export const initiatePaystackPayment = onCall(
  {secrets: [paystackSecretKey]},
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
    const email = customer?.email;
    if (!email) {
      throw new HttpsError(
        "failed-precondition",
        "No email on file for this account."
      );
    }

    const paymentRef = db().collection("payments").doc();

    const {authorizationUrl, reference} = await initializeTransaction({
      amount: booking.amount,
      email,
      reference: paymentRef.id,
      secretKey: paystackSecretKey.value(),
    });

    await paymentRef.set({
      bookingId,
      customerId: booking.customerId,
      artisanId: booking.artisanId,
      amount: booking.amount,
      status: "pending",
      paystackReference: reference,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await bookingRef.update({
      paymentStatus: "pending",
      paymentId: paymentRef.id,
    });

    return {paymentId: paymentRef.id, authorizationUrl};
  }
);
