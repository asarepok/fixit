import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {sendPushToUser} from "./send";

/** Watches every booking write and pushes the customer or artisan a
 * notification when something they'd want to know about changes:
 * accepted/declined, job started/completed, payment secured/released.
 * A Firestore trigger rather than adding this to each write path, since
 * booking status changes go straight from the client (BookingRepository)
 * while payment changes go through releaseEscrowToArtisan, a trigger
 * fires regardless of which path made the write. */
export const onBookingUpdated = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const bookingId = event.params.bookingId;

    if (before.status !== after.status) {
      switch (after.status) {
      case "accepted":
        await sendPushToUser(
          after.customerId,
          {
            title: "Request accepted",
            body: "The artisan accepted your request and sent a quote.",
          },
          {bookingId, type: "booking_accepted"}
        );
        break;
      case "declined":
        await sendPushToUser(
          after.customerId,
          {
            title: "Request declined",
            body: "The artisan wasn't able to take this job.",
          },
          {bookingId, type: "booking_declined"}
        );
        break;
      case "in_progress":
        await sendPushToUser(
          after.customerId,
          {
            title: "Job started",
            body: "The artisan has started work on your job.",
          },
          {bookingId, type: "booking_in_progress"}
        );
        break;
      case "completed":
        await sendPushToUser(
          after.customerId,
          {
            title: "Job marked complete",
            body: "Happy with the work? Pay the artisan to wrap up.",
          },
          {bookingId, type: "booking_completed"}
        );
        break;
      }
    }

    if (before.paymentStatus !== after.paymentStatus) {
      if (after.paymentStatus === "held_in_escrow") {
        await sendPushToUser(
          after.artisanId,
          {
            title: "Payment secured",
            body: "The customer paid, you're clear to start the job.",
          },
          {bookingId, type: "payment_secured"}
        );
      }
      if (after.paymentStatus === "released") {
        await sendPushToUser(
          after.artisanId,
          {
            title: "You've been paid",
            body: "Payment for this job has been added to your balance.",
          },
          {bookingId, type: "payment_released"}
        );
      }
    }
  }
);
