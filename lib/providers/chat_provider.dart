import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import 'auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(firestoreServiceProvider));
});

// The signed-in user's ticket inbox, live, every thread they're part of,
// either side, newest activity first.
final myChatsProvider = StreamProvider.autoDispose<List<ChatThread>>((ref) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).streamMyChats(uid);
});

// A single thread's messages, live, keyed by chatId. Both sides of a
// conversation see a new message the moment it's sent, no refresh needed.
final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).streamMessages(chatId);
});

// A single thread's own details, live, keyed by chatId. Lets the thread
// screen show who the other participant is, since navigating to it only
// ever passes the chatId.
final chatThreadProvider =
    StreamProvider.autoDispose.family<ChatThread?, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).streamChatThread(chatId);
});

class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessage(String chatId, String text) async {
    final uid = ref.read(authRepositoryProvider).currentUserId;
    if (uid == null) return;

    await ref.read(chatRepositoryProvider).sendMessage(
          chatId: chatId,
          senderId: uid,
          text: text,
        );
  }
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);
