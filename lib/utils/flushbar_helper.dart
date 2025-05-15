import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showCustomSnackbar({
  required BuildContext context,
  required String message,
  bool isSuccess = true,
  Duration duration = const Duration(seconds: 3),
}) {
  Flushbar(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    borderRadius: BorderRadius.circular(8),
    backgroundColor: isSuccess ? Colors.greenAccent.shade700 : Colors.redAccent.shade700,
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      isSuccess ? Icons.check_circle : Icons.error,
      color: Colors.white,
    ),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    duration: duration,
    animationDuration: const Duration(milliseconds: 500),
  ).show(context);
}