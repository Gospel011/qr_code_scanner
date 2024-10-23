import 'package:flutter/material.dart';

mixin UiInfoMixin {
  showSnackMessage(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 1000)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: duration,
    ));
  }
}
