import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class TransferStudentPage extends StatefulWidget {
  const TransferStudentPage({super.key});

  @override
  _TransferStudentPageState createState() => _TransferStudentPageState();
}

class _TransferStudentPageState extends State<TransferStudentPage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> doctors = [];
  String? selectedStudent;
  String? selectedDoctor;
  TextEditingController studentController = TextEditingController();
  TextEditingController doctorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchDoctors();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env['API_BASE_URL']}/GP/v1/students/all"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          students = List<Map<String, dynamic>>.from(data['data']['students']);
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students: $e')),
      );
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env['API_BASE_URL']}/GP/v1/doctors"),
      );
      if (response.statusCode == 200) {
        setState(() {
          doctors = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctors: $e')),
      );
    }
  }

  Future<void> transferStudent() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse("${dotenv.env['API_BASE_URL']}/GP/v1/doctors/transfer"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "student": selectedStudent,
          "doctor": selectedDoctor,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer successful')),
        );
        setState(() {
          studentController.clear();
          doctorController.clear();
          selectedStudent = null;
          selectedDoctor = null;
        });
      } else {
        throw Exception('Failed to transfer student');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error transferring student: $e')),
      );
    }
  }

  void confirmTransfer() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Transfer'),
          content: Text(
            'Are you sure you want to transfer $selectedStudent to $selectedDoctor?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                Navigator.pop(context);
                transferStudent();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Transfer Students',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Student',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TypeAheadFormField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: studentController,
                          decoration: InputDecoration(
                            labelText: 'Search Student',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          return students
                              .where((student) =>
                                  student['Username'] != null &&
                                  student['Username']
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()))
                              .map<String>((student) => student['Username']!)
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            selectedStudent = suggestion;
                            studentController.text = suggestion;
                          });
                        },
                        noItemsFoundBuilder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No students found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                          Icon(Icons.swap_horiz, color: primaryColor, size: 32),
                    ),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: doctorController,
                          decoration: InputDecoration(
                            labelText: 'Search New Doctor',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          return doctors
                              .where((doctor) =>
                                  doctor['Username'] != null &&
                                  doctor['Username']
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()))
                              .map<String>((doctor) => doctor['Username']!)
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            selectedDoctor = suggestion;
                            doctorController.text = suggestion;
                          });
                        },
                        noItemsFoundBuilder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No doctors found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: selectedStudent != null && selectedDoctor != null
                        ? confirmTransfer
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Transfer Student',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
