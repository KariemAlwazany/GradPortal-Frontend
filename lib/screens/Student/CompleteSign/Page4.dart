// package:flutter_project/screens/Student/CompleteSign/Page4.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page5.dart';

const Color primaryColor = Color(0xFF3B4280);

class FourthPage extends StatefulWidget {
  final VoidCallback onPrevious;

  const FourthPage({
    required this.onPrevious,
    Key? key,
  }) : super(key: key);

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  bool _isLoading = false;
  String? _status;
  String? _token;
  Timer? _statusCheckTimer; // Timer for polling the status

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchStatus(); // Load token and fetch student's status
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  // Function to retrieve the JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  // Load the token first, then fetch the student's current status
  Future<void> _loadTokenAndFetchStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await getToken(); // Retrieve token from SharedPreferences
      if (_token == null) {
        throw Exception('JWT token not found');
      }
      await _fetchStudentStatus(); // Fetch the student's status
      _startStatusPolling(); // Start polling for status changes
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Polling for status every 10 seconds
  void _startStatusPolling() {
    _statusCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkStatus();
    });
  }

  // Function to check if the student's status has changed to "completed"
  Future<void> _checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.6:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String newStatus = data['Status'];

        if (newStatus == 'completed') {
          _statusCheckTimer?.cancel(); // Stop polling
          _navigateToFifthPage(); // Navigate to FifthPage
        }
        if (newStatus == 'declineDoctor') {
          _statusCheckTimer?.cancel(); // Stop polling
          _navigateToThirdPage(); // Navigate to FifthPage
        }
      } else {
        print('Failed to check status');
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  // Navigate to FifthPage
  void _navigateToFifthPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => FifthPage()), // Replace with FifthPage
    );
  }

  void _navigateToThirdPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ProjectStepper(
                initialStep: 2,
              )), // Replace with FifthPage
    );
  }

  // Fetch the student's current status
  Future<void> _fetchStudentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.6:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _status = data['Status'];

        // If status is "waiting", stay on this page and start polling
        if (_status == 'waiting') {
          _startStatusPolling(); // Start polling if still waiting
        }
      } else {
        print('Failed to fetch student status');
      }
    } catch (e) {
      print('Error fetching student status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Wait for approval from your doctor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    _logout(context); // Call the logout function
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Logout button styled in red
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logout functionality
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SignInScreen()), // Assuming SignInScreen exists
    );
  }
}
