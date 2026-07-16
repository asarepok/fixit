import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const db = () => admin.firestore();

/** Creates a review and updates the artisan's rolling average rating in
 * the same transaction. Runs server-side, via the Admin SDK, because a
 * customer submitting a review needs to update a field on someone else's
 * user document (the artisan's averageRating/ratingCount), which
 * firestore.rules can't safely allow an arbitrary client to do directly. */
export const submitReview = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const {bookingId, rating, comment} = request.data as {
    bookingId?: string;
    rating?: number;
    comment?: string;
  };

  if (!bookingId) {
    throw new HttpsError("invalid-argument", "bookingId is required.");
  }
  if (!rating || rating < 1 || rating > 5) {
    throw new HttpsError("invalid-argument", "rating must be between 1 and 5.");
  }

  const booking = (
    await db().collection("bookings").doc(bookingId).get()
  ).data();

  if (!booking) {
    throw new HttpsError("not-found", "Booking not found.");
  }
  if (booking.customerId !== uid) {
    throw new HttpsError("permission-denied", "This isn't your booking.");
  }
  if (booking.status !== "completed") {
    throw new HttpsError(
      "failed-precondition",
      "This booking isn't completed yet."
    );
  }

  const existing = await db()
    .collection("reviews")
    .where("bookingId", "==", bookingId)
    .limit(1)
    .get();
  if (!existing.empty) {
    throw new HttpsError(
      "already-exists",
      "You've already reviewed this booking."
    );
  }

  const artisanRef = db().collection("users").doc(booking.artisanId);
  const reviewRef = db().collection("reviews").doc();

  await db().runTransaction(async (tx) => {
    const artisanSnap = await tx.get(artisanRef);
    const artisan = artisanSnap.data() ?? {};

    const previousCount = (artisan.ratingCount as number | undefined) ?? 0;
    const previousAverage = (artisan.averageRating as number | undefined) ?? 0;
    const newCount = previousCount + 1;
    const newAverage = (previousAverage * previousCount + rating) / newCount;

    tx.set(reviewRef, {
      bookingId,
      customerId: uid,
      artisanId: booking.artisanId,
      rating,
      comment: comment ?? "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.update(artisanRef, {
      averageRating: newAverage,
      ratingCount: newCount,
    });
  });

  return {reviewId: reviewRef.id};
});
