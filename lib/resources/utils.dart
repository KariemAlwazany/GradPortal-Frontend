import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/meeting/meeting.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: primaryColor,
    ),
  );
}
