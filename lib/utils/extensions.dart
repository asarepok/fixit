import 'package:flutter/material.dart';

// Adds context.showSnack("message") as a shortcut for the usual
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(...)) call, since
// most screens need to show a short message the same way.
extension SnackbarContext on BuildContext {
  void showSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
