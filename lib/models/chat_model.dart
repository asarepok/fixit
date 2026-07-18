// Mirrors a document in the "chats" collection, one thread per
// customer/artisan pair, shared across every booking between them.
class ChatThread {
  final String id;
  final String customerId;
  final String artisanId;
  // The booking that started this thread. Later bookings between the
  // same two people reuse this same thread and don't change this field.
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
  // True for the auto-posted "New booking" divider the thread gets when
  // a later booking between the same two people reuses it, false for a
  // real message either side typed.
  final bool system;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.sentAt,
    this.system = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map["id"] as String,
      senderId: map["senderId"] as String,
      text: map["text"] as String? ?? "",
      sentAt: (map["sentAt"] as dynamic)?.toDate(),
      system: map["system"] as bool? ?? false,
    );
  }
}
