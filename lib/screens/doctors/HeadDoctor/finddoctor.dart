import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class FindDoctorPage extends StatefulWidget {
  final String studentId;

  FindDoctorPage({required this.studentId});

  @override
  _FindDoctorPageState createState() => _FindDoctorPageState();
}

class _FindDoctorPageState extends State<FindDoctorPage> {
  Map<String, dynamic>? suggestedDoctor;
  List<Map<String, dynamic>> otherDoctors = [];
  List<Map<String, dynamic>> unavailableDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<void> _fetchDoctors() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      // Fetch suggested doctor
      final suggestedDoctorResponse =
          await _fetchSuggestedDoctor(widget.studentId, token);
      final availableDoctorsResponse = await _fetchAvailableDoctors(token);
      final unavailableDoctorsResponse = await _fetchUnavailableDoctors(token);

      setState(() {
        suggestedDoctor = suggestedDoctorResponse;

        // Remove duplicates
        final suggestedDoctorId = suggestedDoctor?['id'];
        otherDoctors = availableDoctorsResponse
            .where((doctor) => doctor['id'] != suggestedDoctorId)
            .toList();

        unavailableDoctors = unavailableDoctorsResponse
            .where((doctor) => doctor['id'] != suggestedDoctorId)
            .toList();

        isLoading = false;
      });
    } catch (error) {
      print('Error fetching doctors: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchSuggestedDoctor(
      String username, String token) async {
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/partner/$username';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['doctorInfo'];
      return {
        'name': data['Username'],
        'id': data['id'],
        'registrationNumber': data['Registration_number'],
        'role': data['Role'],
        'studentNumber': data['StudentNumber'],
      };
    } else {
      throw Exception('Failed to load suggested doctor');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableDoctors(
      String token) async {
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/available';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((doctor) {
        return {
          'name': doctor['Username'],
          'id': doctor['id'],
          'registrationNumber': doctor['Registration_number'],
          'role': doctor['Role'],
          'studentNumber': doctor['StudentNumber'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load available doctors');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUnavailableDoctors(
      String token) async {
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/unavailable';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((doctor) {
        return {
          'name': doctor['Username'],
          'id': doctor['id'],
          'registrationNumber': doctor['Registration_number'],
          'role': doctor['Role'],
          'studentNumber': doctor['StudentNumber'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load unavailable doctors');
    }
  }

  Future<void> _chooseDoctor(String doctorUsername) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      final url =
          '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/headDoctor/choose-doctor';
      final body = json.encode({
        "doctor": doctorUsername,
        "username": widget.studentId,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor chosen successfully')),
        );
      } else {
        print('Failed to choose doctor: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to choose doctor')),
        );
      }
    } catch (error) {
      print('Error choosing doctor: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Doctor', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Suggested Doctor Section
                    Text(
                      'Suggested Doctor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    suggestedDoctor == null
                        ? Center(
                            child: Text(
                              'No Suggested Doctor Found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : _buildDoctorCard(context, suggestedDoctor!, true),
                    SizedBox(height: 20),

                    // Other Available Doctors Section
                    Text(
                      'Other Available Doctors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    otherDoctors.isEmpty
                        ? Center(
                            child: Text(
                              'No Other Doctors Found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: otherDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(
                                  context, otherDoctors[index]);
                            },
                          ),
                    SizedBox(height: 20),

                    // Unavailable Doctors Section
                    Text(
                      'Unavailable Doctors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    unavailableDoctors.isEmpty
                        ? Center(
                            child: Text(
                              'No Unavailable Doctors Found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: unavailableDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(
                                  context, unavailableDoctors[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor,
      [bool isSuggestion = false]) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          _showDoctorInfo(context, doctor);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    'Role: ${doctor['role']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _chooseDoctor(doctor['name']);
                },
                child: Text('Choose'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDoctorInfo(BuildContext context, Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(doctor['name'], style: TextStyle(color: primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${doctor['id']}'),
              Text('Role: ${doctor['role']}'),
              Text('Registration Number: ${doctor['registrationNumber']}'),
              Text('Student Number: ${doctor['studentNumber'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
