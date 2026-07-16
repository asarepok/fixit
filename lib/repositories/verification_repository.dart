import 'package:image_picker/image_picker.dart';

import '../models/verification_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

const _requestsCollection = "verification_requests";
const _usersCollection = "users";

// The Become an Artisan application: submitting one, checking its status,
// and an admin approving or rejecting it.
class VerificationRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  VerificationRepository(this._firestoreService, this._storageService);

  // Uploads the ID/certificate photo, creates the application, and flips
  // the applicant's own artisanStatus to "pending". That one-way
  // none-to-pending flip is the only self-write firestore.rules allows on
  // artisanStatus, anything past that is admin-only.
  Future<void> submitApplication({
    required String artisanId,
    required String profession,
    required String bio,
    required XFile document,
  }) async {
    final documentUrl = await _storageService.uploadFile(
      "verification_documents/$artisanId/${DateTime.now().millisecondsSinceEpoch}.jpg",
      document,
    );

    final request = VerificationRequest(
      id: "",
      artisanId: artisanId,
      profession: profession,
      bio: bio,
      documentUrl: documentUrl,
      status: VerificationStatus.pending,
    );

    final data = request.toCreateMap();
    data["submittedAt"] = DateTime.now().toUtc();

    await _firestoreService.addDocument(_requestsCollection, data);

    await _firestoreService.updateDocument(_usersCollection, artisanId, {
      "profession": profession,
      "bio": bio,
      "artisanStatus": "pending",
    });
  }

  // The applicant's own most recent application, so the status screen can
  // show pending/rejected without an admin's view.
  Future<VerificationRequest?> getMyApplication(String artisanId) async {
    final docs = await _firestoreService.queryWhereOrdered(
      _requestsCollection,
      "artisanId",
      artisanId,
      orderBy: "submittedAt",
      descending: true,
    );
    if (docs.isEmpty) return null;
    return VerificationRequest.fromMap(docs.first);
  }

  // The admin review queue.
  Future<List<VerificationRequest>> getPendingApplications() async {
    final docs = await _firestoreService.queryWhereOrdered(
      _requestsCollection,
      "status",
      VerificationStatus.pending.value,
      orderBy: "submittedAt",
    );
    return docs.map(VerificationRequest.fromMap).toList();
  }

  // Approves or rejects an application, and updates the applicant's own
  // artisanStatus to match. Admin only, both writes rely on the isAdmin
  // bypass in firestore.rules.
  Future<void> reviewApplication({
    required String requestId,
    required String artisanId,
    required bool approved,
    String? note,
  }) async {
    final status = approved ? VerificationStatus.verified : VerificationStatus.rejected;

    await _firestoreService.updateDocument(_requestsCollection, requestId, {
      "status": status.value,
      "reviewerNote": note,
    });

    await _firestoreService.updateDocument(_usersCollection, artisanId, {
      "artisanStatus": status.value,
    });
  }
}
