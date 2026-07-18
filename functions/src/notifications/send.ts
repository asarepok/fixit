import * as admin from "firebase-admin";

const db = () => admin.firestore();

/** Sends a push to whatever FCM token is on this user's doc, if any.
 * Swallows send failures (an expired/invalid token, no token saved at
 * all) rather than throwing, a notification failing to send should
 * never break the write that triggered it. */
export async function sendPushToUser(
  uid: string,
  notification: {title: string; body: string},
  data: Record<string, string> = {}
): Promise<void> {
  const user = (await db().collection("users").doc(uid).get()).data();
  const token = user?.fcmToken as string | undefined;
  if (!token) return;

  try {
    await admin.messaging().send({token, notification, data});
  } catch (error) {
    console.error(`Failed to send push to ${uid}:`, error);
  }
}
