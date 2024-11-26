import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createForGroup.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createMeeting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class CreateMeetingsPage extends StatelessWidget {
  const CreateMeetingsPage({Key? key}) : super(key: key);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<void> createMeeting({
    required String meetingType,
    required DateTime date,
    required BuildContext context,
  }) async {
    final token = await getToken();
    final apiUrl = '${dotenv.env['API_BASE_URL']}/GP/v1/meetings/createMeeting';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "Type": meetingType,
          "Date": date.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Meeting created successfully: ${data['data']['meeting']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting created successfully!')),
        );
      } else {
        print("Failed to create meeting: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create meeting.')),
        );
      }
    } catch (e) {
      print("Error creating meeting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating meeting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Meetings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.schedule, color: Colors.white),
            onPressed: () {
              // Navigate to scheduled meetings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewMeetingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true, // Ensures the grid is centered
            physics: NeverScrollableScrollPhysics(), // Prevents inner scrolling
            children: [
              _buildOptionCard(
                context,
                icon: Icons.people,
                title: 'All Students',
                onTap: () => _showDateTimeDialog(context, 'All'),
              ),
              _buildOptionCard(
                context,
                icon: Icons.memory,
                title: 'Hardware Projects',
                onTap: () => _showDateTimeDialog(context, 'Hardware'),
              ),
              _buildOptionCard(
                context,
                icon: Icons.code,
                title: 'Software Projects',
                onTap: () => _showDateTimeDialog(context, 'Software'),
              ),
              _buildOptionCard(
                context,
                icon: Icons.group_work,
                title: 'Specific Group',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateMeetingForGroupPage()),
                  );
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
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

  void _showDateTimeDialog(BuildContext context, String meetingType) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Select Date & Time for $meetingType',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });

                        // Automatically show time picker after date selection
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: Text(
                      'Select Date & Time',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (selectedDate != null && selectedTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Selected: ${selectedDate!.toLocal()} (${selectedTime!.format(context)})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedDate != null && selectedTime != null
                      ? () {
                          createMeeting(
                            meetingType: meetingType,
                            date: selectedDate!,
                            context: context,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
