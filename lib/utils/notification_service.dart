import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Get the FCM token and store it locally
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      if (token != null) {
        await _storeTokenLocally(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        print('FCM Token refreshed: $newToken');
        await _storeTokenLocally(newToken);
      });
    } else {
      print('User declined or has not granted notification permissions');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id', // Channel ID
      'Default Channel', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformDetails,
      payload: message.data.toString(), // Pass data as payload
    );
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    print('Notification clicked with payload: ${notificationResponse.payload}');
    // Handle navigation or other actions based on payload
    if (notificationResponse.payload != null) {
      // Example: Navigate to a specific screen based on the payload
      // Navigator.pushNamed(context, '/specificRoute', arguments: notificationResponse.payload);
    }
  }

  Future<void> updateTokenToServer(String token) async {
    try {
      // Check if the user is signed in
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      if (jwtToken == null) {
        print('No user signed in. FCM token will not be sent to the server.');
        return;
      }

      if (baseUrl == null) {
        print('API base URL not found. Cannot update FCM token to server.');
        return;
      }

      // Send the FCM token to the backend
      final response = await http.post(
        Uri.parse('$baseUrl/GP/v1/users/updateToken'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        print('FCM token updated successfully on the server.');
      } else {
        print('Failed to update FCM token on the server: ${response.body}');
      }
    } catch (e) {
      print('Error updating FCM token to server: $e');
    }
  }

  Future<void> _storeTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('FCM token stored locally.');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.notification?.title}');
  // Handle background message logic here
}
