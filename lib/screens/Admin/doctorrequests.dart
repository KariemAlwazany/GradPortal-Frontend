import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  _DoctorRequestsPageState createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  List<Map<String, dynamic>> doctorRequests = [];

  @override
  void initState() {
    super.initState();
    fetchDoctorRequests();
  }

  Future<void> fetchDoctorRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/admin/doctors'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          doctorRequests =
              List<Map<String, dynamic>>.from(data['data']['doctors']);
        });
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch doctor requests')),
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
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/admin/approve'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/admin/decline';

    // Optimistic update: temporarily remove the item from the list
    final removedRequest = doctorRequests[index];
    setState(() {
      doctorRequests.removeAt(index);
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
        doctorRequests.insert(index, removedRequest);
      });
      _showResponseSnackBar(context, 'Failed to $action $username');
    }
  }

  void _showResponseSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Doctor Approval Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: doctorRequests.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: doctorRequests.length,
                itemBuilder: (context, index) {
                  final request = doctorRequests[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorRequestDetailPage(
                            name: request['User']['FullName'] ?? 'Unknown',
                            email: request['User']['Email'] ?? 'No email',
                            details:
                                'Registration: ${request['Registration_number']}',
                            degreeBase64: request['Degree'],
                            onAccept: () {
                              handleResponse(
                                  request['Username'], 'accept', index);
                            },
                            onDecline: () {
                              handleResponse(
                                  request['Username'], 'decline', index);
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
}

class DoctorRequestDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String details;
  final String degreeBase64;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DoctorRequestDetailPage({super.key, 
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
