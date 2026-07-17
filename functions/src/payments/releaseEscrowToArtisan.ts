import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const db = () => admin.firestore();

/** Called from the "Release Payment to [artisan]" button, which only
 * shows once the artisan has marked the booking completed. Money moving
 * doesn't happen just because the job is marked done, it needs this
 * explicit confirmation from whoever paid.
 *
 * This doesn't pay the artisan out through Paystack directly, it credits
 * their balance field instead, an actual payout (cashout) is a separate,
 * later action the artisan takes on their own, not automatic on release.
 * Keeping the two apart means a release is a single atomic Firestore
 * write instead of a Paystack API round trip, and a payout failure never
 * leaves a job in a half-released state. */
export const releaseEscrowToArtisan = onCall(
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

    // Reading the payment and flipping it from held_in_escrow to released
    // both happen inside this one transaction, that's what makes a
    // repeat call (a double tap, a retry after a dropped response) safe.
    // If two calls overlap, only the first to commit sees
    // held_in_escrow, the second re-reads the now-released status and
    // correctly fails the precondition check instead of crediting the
    // artisan's balance a second time.
    await db().runTransaction(async (tx) => {
      const paymentSnap = await tx.get(paymentRef);
      const payment = paymentSnap.data();

      if (!payment) {
        throw new HttpsError("not-found", "Payment not found.");
      }
      if (payment.customerId !== uid) {
        throw new HttpsError(
          "permission-denied",
          "Only the customer who paid can release this."
        );
      }
      if (payment.status !== "held_in_escrow") {
        throw new HttpsError(
          "failed-precondition",
          "This payment isn't held in escrow."
        );
      }

      const bookingRef = db().collection("bookings").doc(payment.bookingId);
      const bookingSnap = await tx.get(bookingRef);
      if (bookingSnap.data()?.status !== "completed") {
        throw new HttpsError(
          "failed-precondition",
          "The artisan hasn't marked this job complete yet."
        );
      }

      const artisanRef = db().collection("users").doc(payment.artisanId);
      tx.update(paymentRef, {status: "released"});
      tx.update(bookingRef, {paymentStatus: "released"});
      tx.update(artisanRef, {
        balance: admin.firestore.FieldValue.increment(payment.amount),
      });
    });

    return {status: "released"};
  }
);
