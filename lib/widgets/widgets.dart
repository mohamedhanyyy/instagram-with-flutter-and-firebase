import 'package:flutter/material.dart';

class CommonWidget {
  static void makeSnackBar(
      {required String title,
      required String message,
      required BuildContext context,
      Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
