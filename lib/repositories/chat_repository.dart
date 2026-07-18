import 'dart:async';

import '../models/chat_model.dart';
import '../services/firestore_service.dart';

const _chatsCollection = "chats";

// One thread per customer/artisan pair, shared across every booking
// between them. getOrCreateChat is still a plain one-time read (it only
// ever runs once, right when a booking is created), but the threads list
// and a thread's messages are both live, see streamMyChats and
// streamMessages.
class ChatRepository {
  final FirestoreService _firestoreService;

  ChatRepository(this._firestoreService);

  // Returns the existing thread between this customer and artisan, or
  // creates one. Called once, right when a booking is created, by
  // BookingController, so a chat always exists from the start rather
  // than being created lazily on first message. A later booking between
  // the same two people reuses the same thread instead of starting a
  // new one.
  Future<String> getOrCreateChat({
    required String customerId,
    required String artisanId,
    required String bookingId,
  }) async {
    final existing = await _firestoreService.queryWhereTwo(
      _chatsCollection,
      "customerId",
      customerId,
      "artisanId",
      artisanId,
    );

    if (existing.isNotEmpty) {
      final chatId = existing.first["id"] as String;
      await sendMessage(
        chatId: chatId,
        senderId: customerId,
        text: "New booking request",
        system: true,
      );
      return chatId;
    }

    final thread = ChatThread(
      id: "",
      customerId: customerId,
      artisanId: artisanId,
      bookingId: bookingId,
    );

    return _firestoreService.addDocument(_chatsCollection, thread.toCreateMap());
  }

  // A single thread's own details, live, so a chat screen that only has a
  // chatId on hand (every navigation to one only ever passes the id) can
  // show who the other side is.
  Stream<ChatThread?> streamChatThread(String chatId) {
    return _firestoreService
        .streamDocumentWithId(_chatsCollection, chatId)
        .map((data) => data == null ? null : ChatThread.fromMap(data));
  }

  List<ChatThread> _mergeAndSort(
    List<Map<String, dynamic>> asCustomer,
    List<Map<String, dynamic>> asArtisan,
  ) {
    final threads = [...asCustomer, ...asArtisan].map(ChatThread.fromMap).toList();

    threads.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return threads;
  }

  // Every thread this user is part of, live, newest activity first.
  // Firestore still can't OR two equality filters in one query, so this
  // runs two live listeners (one for each side) and re-merges whenever
  // either one changes, the same merge getMyChats used to do once.
  Stream<List<ChatThread>> streamMyChats(String uid) {
    final controller = StreamController<List<ChatThread>>.broadcast();
    List<Map<String, dynamic>>? asCustomer;
    List<Map<String, dynamic>>? asArtisan;

    void emitIfReady() {
      if (asCustomer == null || asArtisan == null) return;
      controller.add(_mergeAndSort(asCustomer!, asArtisan!));
    }

    final customerSub = _firestoreService
        .streamCollectionWhere(_chatsCollection, "customerId", uid)
        .listen((docs) {
      asCustomer = docs;
      emitIfReady();
    });
    final artisanSub = _firestoreService
        .streamCollectionWhere(_chatsCollection, "artisanId", uid)
        .listen((docs) {
      asArtisan = docs;
      emitIfReady();
    });

    controller.onCancel = () {
      customerSub.cancel();
      artisanSub.cancel();
    };

    return controller.stream;
  }

  // A thread's messages, live, oldest first so new ones append at the
  // bottom. Replaces the old fetch-on-open/refetch-after-send pattern,
  // both sides of a conversation see a new message the moment it's sent.
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _firestoreService
        .streamCollectionOrdered("$_chatsCollection/$chatId/messages", orderBy: "sentAt")
        .map((docs) => docs.map(ChatMessage.fromMap).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    bool system = false,
  }) async {
    await _firestoreService.addDocument("$_chatsCollection/$chatId/messages", {
      "senderId": senderId,
      "text": text,
      "sentAt": DateTime.now().toUtc(),
      "system": system,
    });

    await _firestoreService.updateDocument(_chatsCollection, chatId, {
      "lastMessage": text,
      "updatedAt": DateTime.now().toUtc(),
    });
  }
}
