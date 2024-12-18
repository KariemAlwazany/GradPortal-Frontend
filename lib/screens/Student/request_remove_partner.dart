import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RemovePartnerRequestPage(),
  ));
}

class RemovePartnerRequestPage extends StatefulWidget {
  @override
  _RemovePartnerRequestPageState createState() =>
      _RemovePartnerRequestPageState();
}

class _RemovePartnerRequestPageState extends State<RemovePartnerRequestPage> {
  final TextEditingController _messageController = TextEditingController();
  String status = "No Request";
  String messageFromHeadDoctor = "No message available.";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatusAndMessage();
  }

  Future<void> _fetchStatusAndMessage() async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    try {
      // Fetch Status
      final statusResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner/status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (statusResponse.statusCode == 200) {
        final statusData = json.decode(statusResponse.body);
        status = statusData['status'] ?? 'Pending';
      } else {
        status = 'No Request';
      }

      // Fetch Message from Doctor
      final messageResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner/message'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (messageResponse.statusCode == 200) {
        final messageData = json.decode(messageResponse.body);
        messageFromHeadDoctor =
            messageData['message'] ?? 'No message available.';
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> _submitRequest() async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/remove-partner'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': _messageController.text}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully.')),
        );
        _fetchStatusAndMessage(); // Refresh status and message
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request to Remove Partner'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit a Request',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please provide a reason for requesting the removal of your partner. Your request will be reviewed.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Reason for Removal',
                      hintText: 'Explain your reason...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "Accepted"
                          ? Colors.green
                          : (status == "Declined" ? Colors.red : Colors.orange),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Message from Head Doctor:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    messageFromHeadDoctor,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text('Submit Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 30.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
