// package:flutter_project/screens/Student/CompleteSign/Page5.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/screens/Student/student.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';

const Color primaryColor = Color(0xFF3B4280);

class FifthPage extends StatefulWidget {
  final bool isStandalone;

  const FifthPage({this.isStandalone = false, super.key});

  @override
  _FifthPageState createState() => _FifthPageState();
}

class _FifthPageState extends State<FifthPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isDisabled = false; // To disable fields if status is 'waitapprove'
  String? _status;
  String? _token;
  Timer? _approvalTimer; // Timer for polling the status

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchStudentStatus(); // Load token and fetch student's status
  }

  @override
  void dispose() {
    _approvalTimer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  // Function to retrieve the JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  // Load the token first, then fetch the student's current status
  Future<void> _loadTokenAndFetchStudentStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await getToken(); // Retrieve token from SharedPreferences
      if (_token == null) {
        throw Exception('JWT token not found');
      }
      await _fetchStudentStatus(); // Fetch the student's status
      _startApprovalPolling(); // Start polling for approval
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Polling for approval status every 10 seconds
  void _startApprovalPolling() {
    _approvalTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkApprovalStatus();
    });
  }

  // Function to check if the student's status has changed to "approved"
  Future<void> _checkApprovalStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.10:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String newStatus = data['Status'];

        if (newStatus == 'approved') {
          _approvalTimer?.cancel(); // Stop polling
          _navigateToNextPage(); // Navigate to next page
        } else if (newStatus == 'completed') {
          _isDisabled = false;
          _isSubmitted = false;
          _fetchWaitingListDetails();
        }
      } else {
        print('Failed to check approval status');
      }
    } catch (e) {
      print('Error checking approval status: $e');
    }
  }

  // Navigate to the next page
  void _navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => StudentPage()), // Replace with the next page
    );
  }

  // Fetch the student's current status and waiting list details
  Future<void> _fetchStudentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.10:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _status = data['Status'];

        setState(() {
          // if (_status == 'waitapprove') {
          //   _isDisabled = true;
          //   _isSubmitted =
          //       true; // Show loading circle with message "Wait for approval..."
          //   _fetchWaitingListDetails();
          // }
          // else if (_status == 'completed') {
          //   // Enable fields for resubmission if status is 'completed'
          //   _isDisabled = false;
          //   _isSubmitted = false;
          //   _fetchWaitingListDetails(); // Fetch any updated details if needed
          // }
        });
      } else {
        print('Failed to fetch student status');
      }
    } catch (e) {
      print('Error fetching student status: $e');
    }
  }

  // Fetch the title and description from the waiting list
  Future<void> _fetchWaitingListDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.10:3000/GP/v1/projects/WaitingList/getCurrent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final waitingList = data['data']['waitingList'];
        setState(() {
          _titleController.text = waitingList['ProjectTitle'] ?? '';
          _descriptionController.text = waitingList['ProjectDescription'] ?? '';
        });
      } else {
        print('Failed to fetch waiting list details');
      }
    } catch (e) {
      print('Error fetching waiting list details: $e');
    }
  }

  // Submit the project details (PATCH request)
  Future<void> _submitProject() async {
    setState(() {
      _isLoading = true;
      _isSubmitted = true; // Disable fields immediately after submit is pressed
      _isDisabled = true; // Disable the fields directly
    });

    final Map<String, String> body = {
      'ProjectTitle': _titleController.text,
      'ProjectDescription': _descriptionController.text,
      'ProjectStatus': 'waiting'
    };

    try {
      final response = await http.patch(
        Uri.parse(
            'http://192.168.88.10:3000/GP/v1/projects/WaitingList/current'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Project updated successfully');
        setState(() {
          _isLoading = false; // Stop loading after successful submission
        });
      } else {
        print('Failed to update the project: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting project: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              children: [
                const SizedBox(height: 160),
                const Text(
                  'Submit Your Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 70),
                if (_isLoading || _isSubmitted)
                  Column(
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Wait for approval...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                if (!(_isLoading || _isSubmitted)) ...[
                  TextField(
                    controller: _titleController,
                    enabled: !_isDisabled, // Disable if status is 'waitapprove'
                    decoration: InputDecoration(
                      hintText: 'Enter Project Title',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    enabled: !_isDisabled, // Disable if status is 'waitapprove'
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter Project Description',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _isDisabled ? null : _submitProject,
                    icon: const Icon(Icons.send, color: primaryColor),
                    label: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
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
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}
