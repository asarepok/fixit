import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

// An initials avatar for a given uid, live. Falls back to a generic
// person glyph while the name is loading rather than an empty circle, so
// a list of these never flashes blank.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, required this.uid, this.radius = 22});

  final String uid;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(uid));
    final name = userAsync.valueOrNull?.name.trim() ?? '';
    final initials = name.isEmpty
        ? null
        : name.split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: initials == null
          ? Icon(Icons.person, color: Colors.white, size: radius)
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.62,
              ),
            ),
    );
  }
}
