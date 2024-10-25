import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ProjectApprovalPage extends StatelessWidget {
  final List<Map<String, String>> projectRequests = [
    {
      'student1': 'John Doe',
      'student2': 'Jane Smith',
      'title': 'AI Research Project',
      'description': 'An exploration into AI techniques for data analysis.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Project Approval Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: projectRequests.length,
          itemBuilder: (context, index) {
            final request = projectRequests[index];
            return _buildRequestCard(
              student1: request['student1']!,
              student2: request['student2']!,
              title: request['title']!,
              description: request['description']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String student1,
    required String student2,
    required String title,
    required String description,
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
              'Student: $student1',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Partner: $student2',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
                IconButton(
                  onPressed: () {},
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
