import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentRequestsPage extends StatelessWidget {
  final List<Map<String, String>> studentRequests = [
    {
      'name': 'Michael Anderson',
      'details': 'Project approval request',
      'image': 'assets/student_id1.png'
    },
    {
      'name': 'Sarah Parker',
      'details': 'New registration request',
      'image': 'assets/student_id2.png'
    },
  ];

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
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentRequestDetailPage(
                      name: request['name']!,
                      details: request['details']!,
                      imagePath: request['image']!,
                      onAccept: () {
                        _showResponseSnackBar(
                            context, 'Accepted ${request['name']}');
                        Navigator.pop(context);
                      },
                      onDecline: () {
                        _showResponseSnackBar(
                            context, 'Declined ${request['name']}');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: _buildRequestCard(
                name: request['name']!,
                details: request['details']!,
                onAccept: () {
                  _showResponseSnackBar(context, 'Accepted ${request['name']}');
                },
                onDecline: () {
                  _showResponseSnackBar(context, 'Declined ${request['name']}');
                },
              ),
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
  final String details;
  final String imagePath;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  StudentRequestDetailPage({
    required this.name,
    required this.details,
    required this.imagePath,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Divider(height: 32, color: Colors.grey[300]),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
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
