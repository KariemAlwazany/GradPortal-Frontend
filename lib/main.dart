import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/theme/theme.dart';
import 'screens/notifications/notifications_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_project/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  // NotificationService notificationService = NotificationService();
  // await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GradeHub",
      theme: lightMode,
      home: WelcomeScreen(),
    );
  }
}
