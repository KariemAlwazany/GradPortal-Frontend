import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class MessagesPage extends StatelessWidget {
  final List<Map<String, String>> messages = [
    {
      'title': 'New Assignment Available',
      'message': 'Please check the new assignment in your course dashboard.',
      'date': '2023-11-10'
    },
    {
      'title': 'Class Rescheduled',
      'message': 'Your next class has been rescheduled to 2023-11-15.',
      'date': '2023-11-08'
    },
    {
      'title': 'Project Feedback',
      'message': 'Your project submission has been reviewed. Check comments.',
      'date': '2023-11-05'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Messages', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white), // Make back arrow white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.message, color: primaryColor),
                title: Text(
                  message['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${message['message']} \nReceived: ${message['date']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetailPage(
                        title: message['title']!,
                        message: message['message']!,
                        date: message['date']!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class MessageDetailPage extends StatelessWidget {
  final String title;
  final String message;
  final String date;

  MessageDetailPage({
    required this.title,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Message Details', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white), // Make back arrow white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 8),
            Text(
              'Received on: $date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Messages',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
