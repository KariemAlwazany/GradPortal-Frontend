import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentRequestsPage extends StatefulWidget {
  @override
  _StudentRequestsPageState createState() => _StudentRequestsPageState();
}

class _StudentRequestsPageState extends State<StudentRequestsPage> {
  List<Map<String, dynamic>> studentRequests = [];

  @override
  void initState() {
    super.initState();
    fetchStudentRequests();
  }

  Future<void> fetchStudentRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.88.7:3000/GP/v1/admin/students'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          studentRequests =
              List<Map<String, dynamic>>.from(data['data']['students']);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> handleResponse(String username, String action, int index) async {
    final token = await getToken();
    final url = action == 'accept'
        ? 'http://192.168.88.7:3000/GP/v1/admin/approve'
        : 'http://192.168.88.7:3000/GP/v1/admin/decline';

    // Optimistic update: remove the item from the list temporarily
    final removedRequest = studentRequests[index];
    setState(() {
      studentRequests.removeAt(index);
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'Username': username}),
    );

    if (response.statusCode == 200) {
      _showResponseSnackBar(
        context,
        '${action == 'accept' ? 'Accepted' : 'Declined'} $username',
      );
    } else {
      // If the request fails, reinsert the removed request
      setState(() {
        studentRequests.insert(index, removedRequest);
      });
      _showResponseSnackBar(context, 'Failed to $action $username');
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
        child: studentRequests.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: studentRequests.length,
                itemBuilder: (context, index) {
                  final request = studentRequests[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentRequestDetailPage(
                            name: request['User']['FullName'] ?? 'Unknown',
                            email: request['User']['Email'] ?? 'No email',
                            details:
                                'Registration: ${request['Registration_number']}',
                            degreeBase64: request['Degree'],
                            onAccept: () {
                              handleResponse(
                                  request['Username'], 'accept', index);
                              Navigator.pop(context);
                            },
                            onDecline: () {
                              handleResponse(
                                  request['Username'], 'decline', index);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: _buildRequestCard(
                      name: request['User']['FullName'] ?? 'Unknown',
                      email: request['User']['Email'] ?? 'No email',
                      details:
                          'Registration: ${request['Registration_number']}',
                      onAccept: () =>
                          handleResponse(request['Username'], 'accept', index),
                      onDecline: () =>
                          handleResponse(request['Username'], 'decline', index),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String email,
    required String details,
    required Function onAccept,
    required Function onDecline,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => onAccept(),
                  icon: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
                SizedBox(width: 16),
                IconButton(
                  onPressed: () => onDecline(),
                  icon: Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResponseSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }
}

class StudentRequestDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String details;
  final String degreeBase64;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  StudentRequestDetailPage({
    required this.name,
    required this.email,
    required this.details,
    required this.degreeBase64,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final degreeImage = base64Decode(degreeBase64);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Request Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Divider(height: 32, color: Colors.grey[300]),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  degreeImage,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Divider(height: 32, color: Colors.grey[300]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: Icon(Icons.check_circle),
                  label: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(120, 50),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onDecline,
                  icon: Icon(Icons.cancel),
                  label: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(120, 50),
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
