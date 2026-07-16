import '../models/chat_model.dart';
import '../services/firestore_service.dart';

const _chatsCollection = "chats";

// One ticket-style thread per booking. Everything here is a plain fetch,
// no live listeners, screens refetch on open or right after sending a
// message, see chat_provider.dart.
class ChatRepository {
  final FirestoreService _firestoreService;

  ChatRepository(this._firestoreService);

  // Returns the existing thread for this booking, or creates one. Called
  // once, right when a booking is created, by BookingController, so a
  // chat always exists from the start rather than being created lazily
  // on first message.
  Future<String> getOrCreateChat({
    required String customerId,
    required String artisanId,
    required String bookingId,
  }) async {
    final existing = await _firestoreService.queryWhereTwo(
      _chatsCollection,
      "bookingId",
      bookingId,
      "customerId",
      customerId,
    );

    if (existing.isNotEmpty) {
      return existing.first["id"] as String;
    }

    final thread = ChatThread(
      id: "",
      customerId: customerId,
      artisanId: artisanId,
      bookingId: bookingId,
    );

    return _firestoreService.addDocument(_chatsCollection, thread.toCreateMap());
  }

  // Every thread this user is part of, either side, newest activity
  // first. Firestore can't OR two equality filters in one query, so this
  // runs both and merges them.
  Future<List<ChatThread>> getMyChats(String uid) async {
    final asCustomer = await _firestoreService.queryWhereOrdered(
      _chatsCollection,
      "customerId",
      uid,
    );
    final asArtisan = await _firestoreService.queryWhereOrdered(
      _chatsCollection,
      "artisanId",
      uid,
    );

    final threads = [...asCustomer, ...asArtisan].map(ChatThread.fromMap).toList();

    threads.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return threads;
  }

  Future<List<ChatMessage>> getMessages(String chatId) async {
    final docs = await _firestoreService.getCollectionOrdered(
      "$_chatsCollection/$chatId/messages",
      orderBy: "sentAt",
    );
    return docs.map(ChatMessage.fromMap).toList();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _firestoreService.addDocument("$_chatsCollection/$chatId/messages", {
      "senderId": senderId,
      "text": text,
      "sentAt": DateTime.now().toUtc(),
    });

    await _firestoreService.updateDocument(_chatsCollection, chatId, {
      "lastMessage": text,
      "updatedAt": DateTime.now().toUtc(),
    });
  }
}
