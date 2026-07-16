import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks the signed-in artisan's current workspace for this app session.
// An account retains both capabilities; this only changes the active UI.
enum AppMode { customer, artisan }

final appModeProvider = StateProvider<AppMode>((ref) => AppMode.customer);
