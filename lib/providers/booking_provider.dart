import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';
import 'auth_provider.dart';
import 'chat_provider.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(firestoreServiceProvider));
});

// The customer's "My Bookings" list.
final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Future.value(const []);
  return ref.watch(bookingRepositoryProvider).getMyBookings(uid);
});

// The artisan's "Requests" list: pending bookings waiting on them.
final artisanRequestsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Future.value(const []);
  return ref.watch(bookingRepositoryProvider).getArtisanRequests(uid);
});

// The artisan's "Jobs" list: accepted or in-progress work.
final artisanJobsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  final uid = ref.watch(authRepositoryProvider).currentUserId;
  if (uid == null) return Future.value(const []);
  return ref.watch(bookingRepositoryProvider).getArtisanJobs(uid);
});

// Every booking, for the admin Manage Bookings screen.
final allBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).getAllBookings();
});

// A single booking, for the Booking Detail screen, keyed by bookingId.
final bookingProvider = FutureProvider.autoDispose.family<Booking?, String>((
  ref,
  bookingId,
) {
  return ref.watch(bookingRepositoryProvider).getBooking(bookingId);
});

// Every action a booking can go through: creating one, accepting with a
// quote, declining, cancelling, starting the job, and marking it done.
class BookingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  void _refreshLists() {
    ref.invalidate(myBookingsProvider);
    ref.invalidate(artisanRequestsProvider);
    ref.invalidate(artisanJobsProvider);
    ref.invalidate(allBookingsProvider);
  }

  // Remembers the id of a booking create that's still in progress or
  // failed partway, keyed by what was actually requested. If the same
  // request comes through again (the customer retrying after an error, or
  // a double tap) before the first attempt finished, this resumes that
  // same booking instead of creating a duplicate. Cleared once a create
  // actually succeeds.
  String? _pendingKey;
  String? _pendingBookingId;

  // Creates the booking, then a chat thread for it, then attaches the
  // thread's id back onto the booking. A chat needs the booking's id to
  // exist first, so this can't all happen in one write, see
  // BookingRepository.attachChatId for why.
  Future<String> createBooking({
    required String artisanId,
    required String description,
    required String location,
  }) async {
    state = const AsyncLoading();
    try {
      final customerId = ref.read(authRepositoryProvider).currentUserId!;
      if (customerId == artisanId) {
        throw Exception('You cannot book your own service.');
      }
      final bookingRepo = ref.read(bookingRepositoryProvider);

      final key = '$customerId|$artisanId|$description|$location';
      final bookingId = (key == _pendingKey && _pendingBookingId != null)
          ? _pendingBookingId!
          : bookingRepo.newBookingId();
      _pendingKey = key;
      _pendingBookingId = bookingId;

      await bookingRepo.createBooking(
        bookingId: bookingId,
        customerId: customerId,
        artisanId: artisanId,
        description: description,
        location: location,
      );

      final chatId = await ref
          .read(chatRepositoryProvider)
          .getOrCreateChat(
            customerId: customerId,
            artisanId: artisanId,
            bookingId: bookingId,
          );

      await bookingRepo.attachChatId(bookingId, chatId);

      _pendingKey = null;
      _pendingBookingId = null;

      _refreshLists();
      state = const AsyncData(null);
      return bookingId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> acceptBooking(String bookingId, double amount) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(bookingRepositoryProvider)
          .acceptBooking(bookingId, amount);
      ref.invalidate(bookingProvider(bookingId));
      _refreshLists();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> declineBooking(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).declineBooking(bookingId);
      ref.invalidate(bookingProvider(bookingId));
      _refreshLists();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      ref.invalidate(bookingProvider(bookingId));
      _refreshLists();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> startJob(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).startJob(bookingId);
      ref.invalidate(bookingProvider(bookingId));
      _refreshLists();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> completeJob(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).completeJob(bookingId);
      ref.invalidate(bookingProvider(bookingId));
      _refreshLists();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(BookingController.new);
