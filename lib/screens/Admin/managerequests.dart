import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ManageRequestsPage extends StatefulWidget {
  @override
  _ManageRequestsPageState createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  // Sample list of student requests
  final List<Map<String, dynamic>> requests = [
    {
      'id': 1,
      'studentName': 'John Doe',
      'studentId': 'S12345',
      'requestedDoctor': 'Dr. Raed Alqadi',
      'status': 'Pending',
    },
    {
      'id': 2,
      'studentName': 'Jane Smith',
      'studentId': 'S67890',
      'requestedDoctor': 'Dr. Emily Williams',
      'status': 'Pending',
    },
  ];

  // Function to accept a request
  void acceptRequest(int index) {
    setState(() {
      requests[index]['status'] = 'Accepted';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Accepted request for ${requests[index]['studentName']}')),
    );
  }

  // Function to decline a request
  void declineRequest(int index) {
    setState(() {
      requests[index]['status'] = 'Declined';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Declined request for ${requests[index]['studentName']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Manage Requests',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: requests.isEmpty
            ? Center(
                child: Text(
                  'No requests available.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Name: ${request['studentName']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Student ID: ${request['studentId']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Requested Doctor: ${request['requestedDoctor']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => acceptRequest(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: Text('Accept'),
                                ),
                                ElevatedButton(
                                  onPressed: () => declineRequest(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: Text('Decline'),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Status: ${request['status']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: request['status'] == 'Accepted'
                                    ? Colors.green
                                    : request['status'] == 'Declined'
                                        ? Colors.red
                                        : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
