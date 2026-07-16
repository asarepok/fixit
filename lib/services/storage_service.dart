import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Thin wrapper around Firebase Storage. Only used for the Become an
// Artisan ID/certificate upload right now. Takes an XFile (from
// image_picker) rather than dart:io's File, so this works on web too.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, XFile file) async {
    final ref = _storage.ref(path);
    final bytes = await file.readAsBytes();
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }
}
