import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class ManageStudentRequestsPage extends StatefulWidget {
  const ManageStudentRequestsPage({super.key});

  @override
  _ManageStudentRequestsPageState createState() =>
      _ManageStudentRequestsPageState();
}

class _ManageStudentRequestsPageState extends State<ManageStudentRequestsPage> {
  List<Map<String, dynamic>> studentRequests = [];
  List<String> doctorOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorAndStudentData();
  }

  Future<void> fetchDoctorAndStudentData() async {
    try {
      // Retrieve the JWT token from SharedPreferences
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      // Fetch doctor and student name data
      final url =
          '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/doctors';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer $token', // Add the Bearer token to the headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final doctorData = data['data']['getThree'][0];

        // Extract doctor options
        doctorOptions = [
          doctorData['Doctor1'],
          doctorData['Doctor2'],
          doctorData['Doctor3'],
        ];

        // Extract student name from Partner_1
        final studentName = doctorData['Partner_1'];

        // Fetch student registration number using studentName
        final studentResponse = await http.get(
          Uri.parse(
              '${dotenv.env['API_BASE_URL']}/GP/v1/students/specific/$studentName'),
          headers: {
            'Authorization':
                'Bearer $token', // Add the Bearer token to the headers
            'Content-Type': 'application/json',
          },
        );

        if (studentResponse.statusCode == 200) {
          final studentData = json.decode(studentResponse.body);

          // Update studentRequests list with fetched data
          setState(() {
            studentRequests = [
              {
                'id': studentData['id'],
                'name': studentName, // Student name from Partner_1
                'studentId':
                    studentData['Registration_number'], // Registration number
                'selectedDoctor': null,
              }
            ];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch student details');
        }
      } else {
        throw Exception('Failed to load doctor data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<void> saveRequest(int index) async {
    final student = studentRequests[index]['name'];
    final doctor = studentRequests[index]['selectedDoctor'];
    final token = await getToken();
    if (doctor != null) {
      try {
        // Send POST request
        final url =
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/doctors';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization':
                'Bearer $token', // Add the Bearer token to the headers
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'student': student,
            'Doctor': doctor,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assigned $doctor to $student')),
          );

          // Remove the saved request from the list
          setState(() {
            studentRequests.removeAt(index);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save request')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving request: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a doctor for $student')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Manage Student Registration',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentRequests.isEmpty
              ? Center(
                  child: Text(
                    'No registration requests.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: studentRequests.length,
                    itemBuilder: (context, index) {
                      final request = studentRequests[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Name: ${request['name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Student ID: ${request['studentId']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Assign to Doctor',
                                  border: OutlineInputBorder(),
                                ),
                                value: request['selectedDoctor'],
                                items: doctorOptions.map((doctor) {
                                  return DropdownMenuItem(
                                    value: doctor,
                                    child: Text(doctor),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    request['selectedDoctor'] = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => saveRequest(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: Text('Save Request'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
