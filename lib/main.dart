// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/cart_screen.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'package:flutter_project/screens/Shop/seller_profile_screen.dart';
import 'package:flutter_project/screens/student.dart';
import 'package:flutter_project/screens/user_first_screen.dart';
import 'package:flutter_project/screens/user_page.dart';
import 'package:flutter_project/widgets/cart_item_samples.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/theme/theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_project/screens/Shop/shop_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

// Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      title: "GradHub",
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: lightMode,
      // initialRoute: '/', // Start with the Welcome Screen
      // routes: {
      //   '/': (context) => WelcomeScreen(),  // Welcome page with SignIn/SignUp
      //   '/signin': (context) => UserFirstScreen(username: null,),  // SignIn/SignUp screen
      //   '/student': (context) => StudentPage(),  // Student home screen
      //   '/shoptextColor':(context) => ShopHomePage(),  // Shop Home with HomeAppBar
      //   '/cart': (context) => CartScreen(),  // Cart screen for shopping
      // },
      home: WelcomeScreen(),
    );
  }
}
