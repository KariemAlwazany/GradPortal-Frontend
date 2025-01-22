import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class MeetingRequestPage extends StatefulWidget {
  final DateTime initialDateTime;

  const MeetingRequestPage({super.key, required this.initialDateTime});

  @override
  _MeetingRequestPageState createState() => _MeetingRequestPageState();
}

class _MeetingRequestPageState extends State<MeetingRequestPage> {
  late DateTime selectedDateTime;
  String doctorName = "Loading..."; // Initial placeholder for the doctor's name

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
    _fetchDoctorName(); // Fetch doctor name from backend when page loads
  }

  // Placeholder function to simulate fetching the doctor's name from the backend
  Future<void> _fetchDoctorName() async {
    try {
      final token = await getToken(); // Retrieve the JWT token
      if (token == null) {
        throw Exception('No token found');
      }

      // Make a GET request to fetch the doctor's name
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students/getDoctor'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String doctorNameFromApi =
            data['Doctor']; // Extract the doctor's name

        // Update the state with the fetched doctor's name
        setState(() {
          doctorName = doctorNameFromApi;
        });
      } else {
        throw Exception('Failed to fetch doctor name: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors (e.g., network issues, invalid token, etc.)
      print('Error fetching doctor name: $error');
      setState(() {
        doctorName = 'Error loading doctor name';
      });
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
    String formattedTime = DateFormat('HH:mm').format(selectedDateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Meeting',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back arrow color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: primaryColor, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dr.' + doctorName, // Display the doctor's name here
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Icon(Icons.calendar_today,
                          color: primaryColor, size: 30),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Icon(Icons.access_time,
                          color: primaryColor, size: 30),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _submitMeetingRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitMeetingRequest(BuildContext context) async {
    final token = await getToken();
    final formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);

    try {
      // Step 1: Fetch project details
      final projectResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/projects/student'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (projectResponse.statusCode == 200) {
        final Map<String, dynamic> projectData =
            jsonDecode(projectResponse.body);
        final String projectTitle = projectData['GP_Title'];
        final String projectType = projectData['GP_Type'];

        final String student1 = projectData['Student_1'];
        final String student2 = projectData['Student_2'];
        final String studentNames =
            student2 != null ? '$student1 and $student2' : student1;

        // Step 2: Submit the meeting request
        final meetingResponse = await http.post(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'Date': formattedDate}),
        );

        if (meetingResponse.statusCode == 200) {
          // Step 3: Fetch the doctor's ID (assuming you have it or can fetch it)
          final doctorResponse = await http.get(
            Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students/getDoctor'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          if (doctorResponse.statusCode == 200) {
            final Map<String, dynamic> doctorData =
                jsonDecode(doctorResponse.body);
            final String doctorUsername = doctorData[
                'Doctor']; // Assuming the doctor's ID is in the response

            // Step 4: Send a notification to the doctor
            final notificationResponse = await http.post(
              Uri.parse(
                  '${dotenv.env['API_BASE_URL']}/GP/v1/notification/notifyUserByUsername'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'username': doctorUsername, // Doctor's username
                'title': 'New Meeting Request',
                'body':
                    'You have a new meeting request from $studentNames for the project "$projectTitle".',
                'additionalData': {
                  'meetingDate': formattedDate,
                  'studentNames': studentNames,
                  'projectTitle': projectTitle,
                  'projectType': projectType,
                },
              }),
            );

            if (notificationResponse.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Meeting request submitted! Await doctor's response."),
                  backgroundColor: primaryColor,
                ),
              );
              Navigator.pop(context);
            } else {
              throw Exception(
                  'Failed to send notification: ${notificationResponse.statusCode}');
            }
          } else {
            throw Exception(
                'Failed to fetch doctor details: ${doctorResponse.statusCode}');
          }
        } else {
          throw Exception(
              'Failed to submit meeting request: ${meetingResponse.statusCode}');
        }
      } else {
        throw Exception(
            'Failed to fetch project details: ${projectResponse.statusCode}');
      }
    } catch (error) {
      print('Error submitting meeting request: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Failed to submit meeting request: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
}
