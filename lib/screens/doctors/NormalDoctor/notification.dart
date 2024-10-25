import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Meeting Request',
      'date': '2024-03-10',
      'message': 'John Doe has requested a meeting.'
    },
    {
      'title': 'Project Approval',
      'date': '2024-03-11',
      'message': 'Jane Smith has submitted a project for approval.'
    },
    {
      'title': 'New Message',
      'date': '2024-03-12',
      'message': 'You received a new message from Michael Johnson.'
    },
    {
      'title': 'Reminder',
      'date': '2024-03-15',
      'message': 'Don\'t forget to submit your final report!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(
              title: notification['title']!,
              date: notification['date']!,
              message: notification['message']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String date,
    required String message,
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
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
