import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentApprovalPage extends StatefulWidget {
  const StudentApprovalPage({super.key});

  @override
  _StudentApprovalPageState createState() => _StudentApprovalPageState();
}

class _StudentApprovalPageState extends State<StudentApprovalPage> {
  List<Map<String, dynamic>> studentRequests = [];

  @override
  void initState() {
    super.initState();
    fetchStudentRequests();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<int> fetchStudentRequestCount() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/getCurrent/doctor-list'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final waitingList = responseData['data']['waitingList'];
          return waitingList
              .length; // Assuming waitingList is a list of requests
        } else {
          throw Exception('Failed to parse student requests');
        }
      } else {
        throw Exception('Failed to load student requests');
      }
    } catch (e) {
      print('Error: $e');
      return 0; // Return 0 in case of an error
    }
  }

  Future<void> fetchStudentRequests() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/getCurrent/doctor-list'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final waitingList = responseData['data']['waitingList'];
          setState(() {
            studentRequests = [
              {
                'Partner_1': waitingList['Partner_1'],
                'Registration_number': waitingList['Registration_number'],
                'Username': waitingList['StudentUsername'],
                'ProjectType': waitingList['ProjectType'],
                'ProjectStatus': waitingList['ProjectStatus'],
              }
            ];
          });
        } else {
          throw Exception('Failed to parse student requests');
        }
      } else {
        throw Exception('Failed to load student requests');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> approveRequest(
      String registrationNumber, String username) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/student/approve'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'Registration_number': registrationNumber,
          'Username': username,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentRequests.removeWhere((request) =>
              request['Registration_number'] == registrationNumber);
        });
      } else {
        throw Exception('Failed to approve request');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> declineRequest(
      String registrationNumber, String username) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/student/decline'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'Registration_number': registrationNumber,
          'Username': username,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentRequests.removeWhere((request) =>
              request['Registration_number'] == registrationNumber);
        });
      } else {
        throw Exception('Failed to decline request');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Student Approval Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: studentRequests.length,
          itemBuilder: (context, index) {
            final request = studentRequests[index];
            return _buildRequestCard(
              name: request['Partner_1']!,
              registrationNumber: request['Registration_number']!,
              email: request['Username']!,
              username: request['Username']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String registrationNumber,
    required String email,
    required String username,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Registration Number: $registrationNumber',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => approveRequest(registrationNumber, username),
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () => declineRequest(registrationNumber, username),
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
