import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class DeadlinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deadlines = [
      {'title': 'Project Proposal Submission', 'date': '2023-12-01'},
      {'title': 'Midterm Exam', 'date': '2023-12-15'},
      {'title': 'Final Project Submission', 'date': '2024-01-10'},
      {'title': 'Design Presentation', 'date': '2024-02-05'},
    ];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(),
          ),
          padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Deadlines',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: deadlines.length,
              itemBuilder: (context, index) {
                final deadline = deadlines[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: primaryColor),
                    title: Text(
                      deadline['title']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Due Date: ${deadline['date']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
