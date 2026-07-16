import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';

const _bookingsCollection = "bookings";

// Everything about the request -> work -> done lifecycle of a booking.
// This does not touch payments or chat directly, BookingController
// orchestrates those alongside this repository rather than this class
// reaching into ChatRepository or PaymentRepository itself.
class BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepository(this._firestoreService);

  // A fresh id for a new booking, chosen before any write happens. Letting
  // BookingController hold onto this id across a retry (instead of getting
  // handed a brand new one from addDocument each time) is what makes
  // creating a booking idempotent, see BookingController.createBooking.
  String newBookingId() => _firestoreService.newId(_bookingsCollection);

  // Creates a new booking at the given id, always starting as pending,
  // with no chat yet. A chat thread needs this booking's id to exist, so
  // BookingController creates the booking first, then the chat, then calls
  // attachChatId below, rather than trying to create both at once. Using
  // setDocument rather than addDocument means calling this again with the
  // same bookingId (a retry after a failure partway through) just
  // overwrites the same booking instead of creating a duplicate.
  Future<void> createBooking({
    required String bookingId,
    required String customerId,
    required String artisanId,
    required String description,
    required String location,
  }) async {
    if (customerId == artisanId) {
      throw Exception("You cannot book your own service.");
    }
    final booking = Booking(
      id: bookingId,
      customerId: customerId,
      artisanId: artisanId,
      description: description,
      location: location,
      status: BookingStatus.pending,
    );

    final data = booking.toCreateMap();
    data["createdAt"] = DateTime.now().toUtc();

    await _firestoreService.setDocument(_bookingsCollection, bookingId, data);
  }

  Future<void> attachChatId(String bookingId, String chatId) async {
    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "chatId": chatId,
    });
  }

  Future<Booking?> getBooking(String bookingId) async {
    final data = await _firestoreService.getDocumentWithId(
      _bookingsCollection,
      bookingId,
    );
    if (data == null) return null;
    return Booking.fromMap(data);
  }

  // The customer's "My Bookings" list, newest first.
  Future<List<Booking>> getMyBookings(String customerId) async {
    final docs = await _firestoreService.queryWhereOrdered(
      _bookingsCollection,
      "customerId",
      customerId,
      orderBy: "createdAt",
      descending: true,
    );
    return docs.map(Booking.fromMap).toList();
  }

  // The artisan's "Requests" list: pending bookings waiting on them.
  Future<List<Booking>> getArtisanRequests(String artisanId) async {
    final docs = await _firestoreService.queryWhereOrdered(
      _bookingsCollection,
      "artisanId",
      artisanId,
      orderBy: "createdAt",
      descending: true,
    );
    return docs
        .map(Booking.fromMap)
        .where((b) => b.status == BookingStatus.pending)
        .toList();
  }

  // The artisan's "Jobs" list: accepted or in-progress work.
  Future<List<Booking>> getArtisanJobs(String artisanId) async {
    final docs = await _firestoreService.queryWhereOrdered(
      _bookingsCollection,
      "artisanId",
      artisanId,
      orderBy: "createdAt",
      descending: true,
    );
    return docs
        .map(Booking.fromMap)
        .where(
          (b) =>
              b.status == BookingStatus.accepted ||
              b.status == BookingStatus.inProgress,
        )
        .toList();
  }

  // Every booking, for the admin Manage Bookings screen, no filtering.
  Future<List<Booking>> getAllBookings() async {
    final docs = await _firestoreService.getCollectionOrdered(
      _bookingsCollection,
      orderBy: "createdAt",
      descending: true,
    );
    return docs.map(Booking.fromMap).toList();
  }

  // Artisan accepts a pending request with a price quote, this is the
  // amount the customer will be asked to pay into escrow next.
  Future<void> acceptBooking(String bookingId, double amount) async {
    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "status": BookingStatus.accepted.value,
      "amount": amount,
    });
  }

  Future<void> declineBooking(String bookingId) async {
    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "status": BookingStatus.declined.value,
    });
  }

  // Only allowed while still pending, matches the rule enforced server
  // side in firestore.rules, checked here too for a friendlier error.
  Future<void> cancelBooking(String bookingId) async {
    final booking = await getBooking(bookingId);
    if (booking?.status != BookingStatus.pending) {
      throw Exception("This booking can no longer be cancelled.");
    }

    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "status": BookingStatus.cancelled.value,
    });
  }

  // Only allowed once payment is confirmed held in escrow, protects the
  // artisan from starting work with no money secured.
  Future<void> startJob(String bookingId) async {
    final booking = await getBooking(bookingId);
    if (booking?.paymentStatus != PaymentStatus.heldInEscrow) {
      throw Exception("Payment hasn't been secured for this job yet.");
    }

    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "status": BookingStatus.inProgress.value,
    });
  }

  // Marks the job done. This does not release escrow payment by itself,
  // the customer confirms that separately through PaymentRepository.
  Future<void> completeJob(String bookingId) async {
    await _firestoreService.updateDocument(_bookingsCollection, bookingId, {
      "status": BookingStatus.completed.value,
    });
  }
}
