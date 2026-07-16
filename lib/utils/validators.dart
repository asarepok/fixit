// Simple form field checks shared across screens with input forms, so the
// same check does not get retyped on every screen. Add new shared checks
// here rather than inline in a screen.
class Validators {
  Validators._();

  // True when a field is blank or only whitespace. Used before submitting a
  // form to show "please fill all fields" instead of sending an empty
  // value.
  static bool isEmpty(String value) => value.trim().isEmpty;

  // True when a value looks like a valid email address.
  static bool isValidEmail(String value) {
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value.trim());
  }

  static bool isValidGhanaPhone(String value) {
    return RegExp(
      r'^(?:0\d{9}|\+233\d{9})$',
    ).hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));
  }
}
