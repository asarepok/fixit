// Mirrors a document in the "chats" collection, one thread per booking.
// Ticket style, not real-time: ChatRepository fetches these with plain
// reads, no live listeners.
class ChatThread {
  final String id;
  final String customerId;
  final String artisanId;
  final String bookingId;
  final String lastMessage;
  final DateTime? updatedAt;

  const ChatThread({
    required this.id,
    required this.customerId,
    required this.artisanId,
    required this.bookingId,
    this.lastMessage = "",
    this.updatedAt,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      id: map["id"] as String,
      customerId: map["customerId"] as String,
      artisanId: map["artisanId"] as String,
      bookingId: map["bookingId"] as String,
      lastMessage: map["lastMessage"] as String? ?? "",
      updatedAt: (map["updatedAt"] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      "customerId": customerId,
      "artisanId": artisanId,
      "bookingId": bookingId,
      "lastMessage": "",
      "updatedAt": null,
    };
  }
}

// One message inside a chat thread's "messages" subcollection.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime? sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.sentAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map["id"] as String,
      senderId: map["senderId"] as String,
      text: map["text"] as String? ?? "",
      sentAt: (map["sentAt"] as dynamic)?.toDate(),
    );
  }
}
