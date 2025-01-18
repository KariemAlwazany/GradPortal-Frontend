import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/meeting/schedule.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project/screens/Student/meeting/meeting.dart';

const Color primaryColor = Color(0xFF3B4280);

class MeetingsOptionsPage extends StatelessWidget {
  const MeetingsOptionsPage({super.key});

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
                  print("Joining conference with ID: $conferenceId");
                } else {
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

  Future<void> _selectDateAndTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate != null) {
      // Check if selected date is today to restrict time before the current time
      bool isToday = selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day;

      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: isToday
            ? TimeOfDay(hour: now.hour, minute: now.minute)
            : TimeOfDay(hour: 0, minute: 0),
      );

      // Ensure selected time is after the current time if today
      if (selectedTime != null &&
          (!isToday ||
              (selectedTime.hour > now.hour ||
                  (selectedTime.hour == now.hour &&
                      selectedTime.minute >= now.minute)))) {
        final selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingRequestPage(
              initialDateTime: selectedDateTime,
            ),
          ),
        );
      } else if (isToday) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Please select a time that is after the current time.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meetings Options',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'Request Meeting',
                onTap: () => _selectDateAndTime(context),
              ),
              SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.video_call,
                title: 'Join Meeting',
                onTap: () => _showJoinMeetingDialog(context),
              ),
              SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.schedule,
                title: 'Scheduled Meetings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduledMeetingsPage(),
                    ),
                  );

                  print("Navigating to Scheduled Meetings Page");
                },
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
        width: 200, // Fixed width to match example
        height: 200, // Fixed height to keep it square
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
}
