import 'package:flutter/material.dart';
import 'package:flutter_project/resources/home_screen.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/create.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createMeeting.dart';

const Color primaryColor = Color(0xFF3B4280);

class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meetings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionCard(
                context,
                icon: Icons.add_box_outlined,
                title: 'Create Meetings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateMeetingsPage()),
                ),
              ),
              SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.schedule,
                title: 'Scheduled Meetings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewMeetingsPage()),
                ),
              ),
              SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.video_call,
                title: 'Join Meeting',
                onTap: () => _showJoinMeetingDialog(context), // Open dialog
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: primaryColor),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the dialog for joining a meeting
  void _showJoinMeetingDialog(BuildContext context) {
    final TextEditingController conferenceIdController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Meeting'),
          content: TextField(
            controller: conferenceIdController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Enter Conference ID',
              hintText: 'Conference ID (10 digits)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Join'),
              onPressed: () {
                final conferenceId = conferenceIdController.text.trim();
                if (conferenceId.length == 10 &&
                    int.tryParse(conferenceId) != null) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(conferenceId: conferenceId),
                    ),
                  );
                } else {
                  // Show error if the conference ID is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please enter a valid 10-digit conference ID.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
