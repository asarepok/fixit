import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import 'auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(firestoreServiceProvider));
});

// The signed-in user's ticket inbox, every thread they're part of, either
// side, newest activity first.
final myChatsProvider = FutureProvider.autoDispose<List<ChatThread>>((ref) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Future.value(const []);
  return ref.watch(chatRepositoryProvider).getMyChats(uid);
});

// A single thread's messages, keyed by chatId. Fetch-on-open, refetch by
// invalidating this after sending, no live listener.
final chatMessagesProvider =
    FutureProvider.autoDispose.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
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

    ref.invalidate(chatMessagesProvider(chatId));
    ref.invalidate(myChatsProvider);
  }
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);
