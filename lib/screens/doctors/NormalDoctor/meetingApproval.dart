import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class MeetingApprovalPage extends StatefulWidget {
  @override
  _MeetingApprovalPageState createState() => _MeetingApprovalPageState();
}

class _MeetingApprovalPageState extends State<MeetingApprovalPage> {
  List<Map<String, dynamic>> meetingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetingRequests();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchMeetingRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.88.10:3000/GP/v1/meetings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the data contains meetings
      if (responseData['status'] == 'success' && responseData['data'] != null) {
        final List<dynamic> meetings = responseData['data']['meetings'];

        setState(() {
          meetingRequests = meetings.map((meeting) {
            return {
              'id': meeting['id'],
              'GP_Type': meeting['GP_Type'],
              'GP_Title': meeting['GP_Title'],
              'Date': meeting['Date'],
              'Student_1': meeting['Student_1'],
              'Student_2': meeting['Student_2'],
            };
          }).toList();
        });
      } else {
        _showResponseSnackBar(context, 'No meeting requests available');
      }
    } else {
      _showResponseSnackBar(context, 'Failed to load meeting requests');
    }
  }

  Future<bool> _approveRequest(String id) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('http://192.168.88.10:3000/GP/v1/meetings/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'id': id}),
    );

    return response.statusCode == 200;
  }

  Future<bool> _declineRequest(String id) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('http://192.168.88.10:3000/GP/v1/meetings/decline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'id': id}), // Send ID in the body
    );

    return response.statusCode == 204;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Meeting Approval Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: meetingRequests.length,
          itemBuilder: (context, index) {
            final request = meetingRequests[index];
            return _buildRequestCard(
              name: '${request['Student_1']} & ${request['Student_2']}',
              details:
                  '${request['GP_Type']} - ${request['GP_Title']} on ${request['Date']}',
              onAccept: () async {
                // Remove request from list immediately and update UI
                setState(() {
                  meetingRequests.removeAt(index);
                });

                // Send accept request to server
                final result = await _approveRequest(request['id'].toString());

                // If request fails, re-add the item and show an error message
                if (!result) {
                  setState(() {
                    meetingRequests.insert(
                        index, request); // Reinsert at the original index
                  });
                  _showResponseSnackBar(context, 'Failed to approve meeting');
                } else {
                  _showResponseSnackBar(context, 'Meeting Approved');
                }
              },
              onDecline: () async {
                // Remove request from list immediately and update UI
                setState(() {
                  meetingRequests.removeAt(index);
                });

                // Send decline request to server
                final result = await _declineRequest(request['id'].toString());

                // If request fails, re-add the item and show an error message
                if (!result) {
                  setState(() {
                    meetingRequests.insert(
                        index, request); // Reinsert at the original index
                  });
                  _showResponseSnackBar(context, 'Failed to decline meeting');
                } else {
                  _showResponseSnackBar(context, 'Meeting Declined');
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
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
            )
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
