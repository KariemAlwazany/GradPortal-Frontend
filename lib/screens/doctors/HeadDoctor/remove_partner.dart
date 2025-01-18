import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class RemovePartnerPage extends StatefulWidget {
  @override
  _RemovePartnerPageState createState() => _RemovePartnerPageState();
}

class _RemovePartnerPageState extends State<RemovePartnerPage> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          requests = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching requests: $e')),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  void _removeRequest(int index) {
    setState(() {
      requests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Partner Requests'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailsPage(
                            request: request,
                            onActionComplete: () => _removeRequest(index),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request['Student'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Request Date: ${request['createdAt'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Tap to view details',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RequestDetailsPage extends StatefulWidget {
  final Map<String, dynamic>
      request; // Change from Map<String, String> to Map<String, dynamic>
  final VoidCallback onActionComplete;

  RequestDetailsPage({required this.request, required this.onActionComplete});

  @override
  _RequestDetailsPageState createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  Map<String, dynamic>? studentInfo;
  Map<String, dynamic>? partnerInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    try {
      final studentResponse = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/students/specific/${widget.request['Student']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final partnerResponse = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner/${widget.request['id']}/partnerInfo'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (studentResponse.statusCode == 200 &&
          partnerResponse.statusCode == 200) {
        setState(() {
          studentInfo = json.decode(studentResponse.body);
          partnerInfo = json.decode(partnerResponse.body)['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch details.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  Future<void> _sendAction(String action, String message) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    final apiUrl =
        '${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner/${widget.request['id']}/$action';

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'DoctorMessage': message}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $action successfully')),
        );
        widget.onActionComplete();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to $action request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow(
                    label: 'Name',
                    value: studentInfo?['Username'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    label: 'ID',
                    value: studentInfo?['Registration_number'] ?? 'N/A',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Partner Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow(
                    label: 'Name',
                    value: partnerInfo?['Username'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    label: 'ID',
                    value: partnerInfo?['Registration_number'] ?? 'N/A',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Message from Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.request['StudentMessage'] ?? 'No message provided.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendMessage(
                                studentName:
                                    studentInfo?['Username'] ?? 'Unknown',
                                studentID:
                                    studentInfo?['Registration_number'] ??
                                        'Unknown',
                                requestID: widget.request[
                                    'id'], // Ensure requestID is passed
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.message),
                        label: Text('Send Message'),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _sendAction('decline', 'Request Declined.');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Reject',
                            style: TextStyle(color: primaryColor)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _sendAction('accept', 'Request Accepted.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: Size(100, 40),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(color: Colors.white, fontSize: 14),
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

class SendMessage extends StatelessWidget {
  final String studentName;
  final String studentID;
  final int requestID;

  SendMessage({
    required this.studentName,
    required this.studentID,
    required this.requestID,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

    Future<void> _sendMessage() async {
      final token = await getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        return;
      }

      try {
        final response = await http.post(
          Uri.parse(
              '${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner/doctor/message/$requestID'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'message': _messageController.text}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Message sent successfully to $studentName')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to send message. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }

    Future<String?> _getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To: $studentName (ID: $studentID)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a message.')),
                    );
                  }
                },
                icon: Icon(Icons.send),
                label: Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
