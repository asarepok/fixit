import 'package:cloud_functions/cloud_functions.dart';

// Thin wrapper around Firebase Cloud Functions. This is the only place
// that imports cloud_functions, repositories call a named function
// through here instead of importing FirebaseFunctions themselves. The
// actual MoMo/escrow/review logic behind these calls lives in
// functions/src, not in this app.
class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final callable = _functions.httpsCallable(name);
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data as Map);
  }
}
