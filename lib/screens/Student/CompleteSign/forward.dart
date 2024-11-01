import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page2.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page4.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page5.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/Student/student.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For JWT token storage

// Function to retrieve JWT token from SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}

class StatusCheckPage extends StatefulWidget {
  @override
  _StatusCheckPageState createState() => _StatusCheckPageState();
}

class _StatusCheckPageState extends State<StatusCheckPage> {
  // Function to check status with JWT token
  Future<String> checkStatus() async {
    final token = await getToken(); // Get JWT token

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(
          'http://192.168.88.7:3000/GP/v1/students/getCurrentStudent'), // Replace with your actual API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include JWT token in the headers
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['Status']; // Assuming the status field exists in the response
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  // Navigate to the respective page based on status
  void forwardBasedOnStatus(String status) {
    if (status == 'start') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectStepper(
                  initialStep: 0,
                )),
      );
    } else if (status == 'waitpartner' || status == 'declinedpartner') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectStepper(
                  initialStep: 1,
                )),
      );
    } else if (status == 'declineDoctor' || status == 'approvedpartner') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectStepper(
                  initialStep: 2,
                )),
      );
    } else if (status == 'waiting') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectStepper(
                  initialStep: 3,
                )),
      );
    } else if (status == 'completed' || status == 'waitapprove') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FifthPage()),
      );
    } else if (status == 'approved') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: FutureBuilder<String>(
          future: checkStatus(), // Fetch status from API
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading while fetching status
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Forward to the appropriate page based on status
              WidgetsBinding.instance.addPostFrameCallback((_) {
                forwardBasedOnStatus(snapshot.data!);
              });
              return Container(); // Empty container, as navigation will occur
            } else {
              return const Text('No status available');
            }
          },
        ),
      ),
    );
  }
}
