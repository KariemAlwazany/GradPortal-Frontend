import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentApprovalPage extends StatefulWidget {
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
    return prefs.getString('jwt_token');
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
          final List<dynamic> waitingList = responseData['data']['waitingList'];

          setState(() {
            studentRequests = waitingList.map<Map<String, dynamic>>((request) {
              return {
                'List_ID': request['List_ID'].toString(), // Convert to string
                'Partner_1': request['Partner_1'] ?? 'N/A',
                'Partner_2': request['Partner_2'] ?? 'N/A',
                'Registration_number_1':
                    request['Student1RegistrationNumber']?.toString() ?? 'N/A',
                'Registration_number_2':
                    request['Student2RegistrationNumber']?.toString() ?? 'N/A',
                'Username_1': request['Student1Username'] ?? 'N/A',
                'Username_2': request['Student2Username'] ?? 'N/A',
                'ProjectType': request['ProjectType'] ?? 'N/A',
                'ProjectStatus': request['ProjectStatus'] ?? 'N/A',
              };
            }).toList();
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

  Future<void> approveRequest(String listId, String username) async {
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
          'List_ID': listId,
          'Username': username, // Include Username in the body
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentRequests
              .removeWhere((request) => request['List_ID'] == listId);
        });
      } else {
        throw Exception('Failed to approve request');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> declineRequest(String listId, String username) async {
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
          'List_ID': listId,
          'Username': username, // Include Username in the body
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentRequests
              .removeWhere((request) => request['List_ID'] == listId);
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
                  listId: request['List_ID'],
                  partner1Name: request['Partner_1']!,
                  partner1RegistrationNumber: request['Registration_number_1']!,
                  partner1Email: request['Username_1']!,
                  partner2Name: request['Partner_2']!,
                  partner2RegistrationNumber: request['Registration_number_2']!,
                  partner2Email: request['Username_2']!,
                  username:
                      request['Username_1']!, // Pass the appropriate username
                );
              },
            )));
  }

  Widget _buildRequestCard({
    required String listId,
    required String partner1Name,
    required String partner1RegistrationNumber,
    required String partner1Email,
    required String partner2Name,
    required String partner2RegistrationNumber,
    required String partner2Email,
    required String username, // Add Username
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
              'Student: ${partner1Name.isNotEmpty ? partner1Name : 'N/A'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Registration Number: ${partner1RegistrationNumber.isNotEmpty ? partner1RegistrationNumber : 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Email: ${partner1Email.isNotEmpty ? partner1Email : 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Partner: ${partner2Name.isNotEmpty ? partner2Name : 'N/A'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Registration Number: ${partner2RegistrationNumber.isNotEmpty ? partner2RegistrationNumber : 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Email: ${partner2Email.isNotEmpty ? partner2Email : 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => approveRequest(listId, username),
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      declineRequest(listId, username), // Adjust if needed
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
