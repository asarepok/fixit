import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/user_name_label.dart';

// The customer's "Chat" tab: every thread they're part of. Just a
// Scaffold wrapped around ChatThreadsList, see that widget for the actual
// content, the artisan dashboard embeds the same list under its own app
// bar instead of this one.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Messages')),
    body: const ChatThreadsList(),
  );
}

// The signed-in user's chat threads, live, newest activity first, either
// side (customer or artisan).
class ChatThreadsList extends ConsumerWidget {
  const ChatThreadsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(myChatsProvider);
    final myUid = ref.watch(authRepositoryProvider).currentUserId;

    return threadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
      data: (threads) {
        if (threads.isEmpty) {
          return const EmptyState(
            icon: Icons.forum_outlined,
            title: 'No conversations yet',
            message: 'Messaging opens up once a booking is accepted.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myChatsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final thread = threads[index];
              final otherUid = thread.customerId == myUid
                  ? thread.artisanId
                  : thread.customerId;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: UserNameLabel(uid: otherUid),
                  subtitle: Text(
                    thread.lastMessage.isEmpty
                        ? 'No messages yet'
                        : thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () =>
                      context.push(AppRoutes.chatThread, extra: thread.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
