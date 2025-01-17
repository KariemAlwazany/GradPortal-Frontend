import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> initializeFCM(String jwtToken) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Request permission
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permissions.');

    // Get FCM token
    String? fcmToken = await messaging.getToken();
    print('FCM Token: $fcmToken');

    if (fcmToken != null) {
      // Send the FCM token to your backend
      final response = await http.post(
        Uri.parse('$baseUrl/GP/v1/users/updateToken'), // Update token endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({"token": fcmToken}),
      );

      if (response.statusCode == 200) {
        print('Token updated successfully on the backend.');
      } else {
        print('Failed to update token on the backend: ${response.body}');
      }
    }
  } else {
    print('User declined notification permissions.');
  }

  // Listen for token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('Token refreshed: $newToken');
    final response = await http.post(
      Uri.parse('$baseUrl/GP/v1/users/updateToken'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({"token": newToken}),
    );

    if (response.statusCode == 200) {
      print('Token updated successfully on the backend.');
    } else {
      print('Failed to update token on the backend: ${response.body}');
    }
  });
}
