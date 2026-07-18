import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {sendPushToUser} from "./send";

const db = () => admin.firestore();

/** Notifies whichever side of a chat thread didn't send the message.
 * Skips the "New booking" system dividers ChatRepository posts when a
 * thread gets reused for a later booking, those aren't a message from a
 * person and shouldn't push a notification. */
export const onMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message || message.system) return;

    const chat = (
      await db().collection("chats").doc(event.params.chatId).get()
    ).data();
    if (!chat) return;

    const recipientId =
      message.senderId === chat.customerId ? chat.artisanId : chat.customerId;

    await sendPushToUser(
      recipientId,
      {
        title: "New message",
        body: (message.text as string | undefined) ?? "",
      },
      {chatId: event.params.chatId, type: "chat_message"}
    );
  }
);
