import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentApprovalPage extends StatelessWidget {
  final List<Map<String, String>> studentRequests = [
    {
      'name': 'John Doe',
      'registrationNumber': '2023001',
      'email': 'johndoe@example.com',
    },
    {
      'name': 'Jane Smith',
      'registrationNumber': '2023002',
      'email': 'janesmith@example.com',
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
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: studentRequests.length,
          itemBuilder: (context, index) {
            final request = studentRequests[index];
            return _buildRequestCard(
              name: request['name']!,
              registrationNumber: request['registrationNumber']!,
              email: request['email']!,
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
              '$name',
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {},
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
