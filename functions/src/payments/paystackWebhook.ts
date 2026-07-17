import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import {paystackSecretKey} from "../paystack/config";

const db = () => admin.firestore();

interface PaystackWebhookEvent {
  event: string;
  data: {reference?: string};
}

/** Paystack calls this directly when a charge or transfer settles, instead
 * of only relying on the app polling checkPaystackPaymentStatus. Set this
 * function's URL as the webhook in the Paystack dashboard once deployed.
 * Every request's signature is verified against the secret key before
 * anything in the payload is trusted, this endpoint has no other auth. */
export const paystackWebhook = onRequest(
  {secrets: [paystackSecretKey]},
  async (request, response) => {
    const signature = request.get("x-paystack-signature");
    const expected = crypto
      .createHmac("sha512", paystackSecretKey.value())
      .update(request.rawBody)
      .digest("hex");

    if (!signature || signature !== expected) {
      response.status(401).send("Invalid signature");
      return;
    }

    const event = request.body as PaystackWebhookEvent;
    const reference = event.data.reference;

    if (!reference) {
      response.sendStatus(200);
      return;
    }

    if (event.event === "charge.success") {
      const snapshot = await db()
        .collection("payments")
        .where("paystackReference", "==", reference)
        .limit(1)
        .get();
      const paymentDoc = snapshot.docs[0];
      if (paymentDoc && paymentDoc.data().status === "pending") {
        await paymentDoc.ref.update({status: "held_in_escrow"});
        await db()
          .collection("bookings")
          .doc(paymentDoc.data().bookingId)
          .update({paymentStatus: "held_in_escrow"});
      }
    }

    if (event.event === "transfer.success") {
      const snapshot = await db()
        .collection("payments")
        .where("paystackTransferReference", "==", reference)
        .limit(1)
        .get();
      const paymentDoc = snapshot.docs[0];
      if (paymentDoc && paymentDoc.data().status === "releasing") {
        await paymentDoc.ref.update({status: "released"});
      }
    }

    response.sendStatus(200);
  }
);
