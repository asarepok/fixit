import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Thin wrapper around Firebase Storage. Takes an XFile (from image_picker)
// rather than dart:io's File, so this works on web too.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, XFile file) async {
    final ref = _storage.ref(path);
    final bytes = await file.readAsBytes();
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  // Deletes by download URL rather than path, since that's what a
  // Firestore doc has on hand (PortfolioRepository.deletePhoto). Swallows
  // a "not found" error, the doc is what a screen actually reacts to, a
  // storage object that's already gone shouldn't block removing it.
  Future<void> deleteFileByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      if (e.code != "object-not-found") rethrow;
    }
  }
}
