import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

// Shows a user's name for a given uid. Used anywhere a screen only has an
// id on hand, for example a booking's customerId, and needs to show
// something readable. Falls back to the raw uid while loading or if the
// lookup fails, rather than showing nothing.
class UserNameLabel extends ConsumerWidget {
  const UserNameLabel({super.key, required this.uid, this.style});

  final String uid;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(uid));
    return userAsync.when(
      loading: () => Text(uid, style: style, overflow: TextOverflow.ellipsis),
      error: (_, _) => Text(uid, style: style, overflow: TextOverflow.ellipsis),
      data: (user) => Text(
        user?.name ?? uid,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
