import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  momoDisbursementApiKey,
  momoDisbursementApiUser,
  momoDisbursementSubscriptionKey,
} from "../momo/config";
import {getTransferStatus, transfer} from "../momo/client";

const db = () => admin.firestore();

/** Called from the "Release Payment to [artisan]" button, which only
 * shows once the artisan has marked the booking completed. Money moving
 * doesn't happen just because the job is marked done, it needs this
 * explicit confirmation from whoever paid. */
export const releaseEscrowToArtisan = onCall(
  {
    secrets: [
      momoDisbursementSubscriptionKey,
      momoDisbursementApiUser,
      momoDisbursementApiKey,
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

    const booking = (
      await db().collection("bookings").doc(payment.bookingId).get()
    ).data();
    if (booking?.status !== "completed") {
      throw new HttpsError(
        "failed-precondition",
        "The artisan hasn't marked this job complete yet."
      );
    }

    const artisan = (
      await db().collection("users").doc(payment.artisanId).get()
    ).data();
    const phoneNumber = artisan?.phone;
    if (!phoneNumber) {
      throw new HttpsError(
        "failed-precondition",
        "No phone number on file for the artisan."
      );
    }

    const creds = {
      subscriptionKey: momoDisbursementSubscriptionKey.value(),
      apiUser: momoDisbursementApiUser.value(),
      apiKey: momoDisbursementApiKey.value(),
    };

    const referenceId = await transfer({
      amount: payment.amount,
      phoneNumber,
      externalId: paymentId,
      payerMessage: `FixIt GH payout, booking ${payment.bookingId}`,
      creds,
    });

    await paymentRef.update({
      status: "releasing",
      momoDisbursementReferenceId: referenceId,
    });

    // Sandbox settles fast, worth one immediate check so the customer
    // isn't left on "releasing" for a payout that already went through.
    const momoStatus = await getTransferStatus(referenceId, creds);
    if (momoStatus === "SUCCESSFUL") {
      await paymentRef.update({status: "released"});
      return {status: "released"};
    }

    return {status: "releasing"};
  }
);
