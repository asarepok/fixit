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
  // attachChatId below, rather than trying to create both at once.
  //
  // Always call this exactly once per bookingId. Firestore treats a write
  // to an id that already has a document as an update, not a create, and
  // the update rule in firestore.rules is stricter than the create rule,
  // so writing here twice for the same id can be denied even when nothing
  // meaningful changed. BookingController is what makes a retry safe, by
  // remembering whether it already called this for the pending id and
  // skipping straight to the chat step if so, rather than this method
  // trying to detect that itself (a read here would hit the same problem
  // in reverse: reading an id that doesn't exist yet, on a normal first
  // attempt, is also denied by these rules).
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

  // A one-time read, used internally for a precondition check right
  // before a write (cancelBooking, startJob), not for displaying a
  // booking on screen, see streamBooking for that.
  Future<Booking?> getBooking(String bookingId) async {
    final data = await _firestoreService.getDocumentWithId(
      _bookingsCollection,
      bookingId,
    );
    if (data == null) return null;
    return Booking.fromMap(data);
  }

  // A single booking, live, for the Booking Detail screen. Updates on its
  // own the moment its status or paymentStatus changes, for example the
  // instant the other side accepts, declines, or the payment clears.
  Stream<Booking?> streamBooking(String bookingId) {
    return _firestoreService
        .streamDocumentWithId(_bookingsCollection, bookingId)
        .map((data) => data == null ? null : Booking.fromMap(data));
  }

  // The customer's "My Bookings" list, live, newest first.
  Stream<List<Booking>> streamMyBookings(String customerId) {
    return _firestoreService
        .streamCollectionWhere(
          _bookingsCollection,
          "customerId",
          customerId,
          orderBy: "createdAt",
          descending: true,
        )
        .map((docs) => docs.map(Booking.fromMap).toList());
  }

  // The artisan's "Requests" list, live: pending bookings waiting on them.
  Stream<List<Booking>> streamArtisanRequests(String artisanId) {
    return _firestoreService
        .streamCollectionWhere(
          _bookingsCollection,
          "artisanId",
          artisanId,
          orderBy: "createdAt",
          descending: true,
        )
        .map(
          (docs) => docs
              .map(Booking.fromMap)
              .where((b) => b.status == BookingStatus.pending)
              .toList(),
        );
  }

  // The artisan's "Jobs" list, live: accepted or in-progress work.
  Stream<List<Booking>> streamArtisanJobs(String artisanId) {
    return _firestoreService
        .streamCollectionWhere(
          _bookingsCollection,
          "artisanId",
          artisanId,
          orderBy: "createdAt",
          descending: true,
        )
        .map(
          (docs) => docs
              .map(Booking.fromMap)
              .where(
                (b) =>
                    b.status == BookingStatus.accepted ||
                    b.status == BookingStatus.inProgress,
              )
              .toList(),
        );
  }

  // Every booking, live, for the admin Manage Bookings screen, no filter.
  Stream<List<Booking>> streamAllBookings() {
    return _firestoreService
        .streamCollectionOrdered(
          _bookingsCollection,
          orderBy: "createdAt",
          descending: true,
        )
        .map((docs) => docs.map(Booking.fromMap).toList());
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
