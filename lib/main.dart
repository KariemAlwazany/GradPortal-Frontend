import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/theme/theme.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Student's Hub",
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: lightMode,
      home: WelcomeScreen(),
    );
  }
}