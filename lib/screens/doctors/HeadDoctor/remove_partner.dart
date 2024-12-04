import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RemovePartnerPage(),
  ));
}

class RemovePartnerPage extends StatefulWidget {
  @override
  _RemovePartnerPageState createState() => _RemovePartnerPageState();
}

class _RemovePartnerPageState extends State<RemovePartnerPage> {
  final List<Map<String, String>> requests = [
    {
      'studentName': 'John Doe',
      'studentID': '12345',
      'partnerName': 'Jane Smith',
      'partnerID': '67890',
      'requestDate': '2024-12-01',
      'message': 'I would like to remove my partner due to personal reasons.',
    },
  ];

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
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to the details page
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
                        request['studentName']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${request['studentID']}',
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

class RequestDetailsPage extends StatelessWidget {
  final Map<String, String> request;
  final VoidCallback onActionComplete;

  RequestDetailsPage({required this.request, required this.onActionComplete});

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
      body: Padding(
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
            _buildInfoRow(label: 'Name', value: request['studentName']!),
            _buildInfoRow(label: 'ID', value: request['studentID']!),
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
            _buildInfoRow(label: 'Name', value: request['partnerName']!),
            _buildInfoRow(label: 'ID', value: request['partnerID']!),
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
              request['message']!,
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
                          studentName: request['studentName']!,
                          studentID: request['studentID']!,
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
                    onActionComplete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request rejected')),
                    );
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Reject', style: TextStyle(color: primaryColor)),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onActionComplete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request accepted')),
                    );
                    Navigator.pop(context);
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
}

class SendMessage extends StatelessWidget {
  final String studentName;
  final String studentID;

  SendMessage({required this.studentName, required this.studentID});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message sent to $studentName')),
                    );
                    Navigator.pop(context);
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
