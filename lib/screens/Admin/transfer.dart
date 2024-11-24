import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class ManageDoctorsTransferPage extends StatefulWidget {
  @override
  _ManageDoctorsTransferPageState createState() =>
      _ManageDoctorsTransferPageState();
}

class _ManageDoctorsTransferPageState extends State<ManageDoctorsTransferPage> {
  List<Map<String, dynamic>> doctors = [];
  int? currentHeadDoctorId;
  String? currentHeadDoctorName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchDoctorsData() async {
    final token = await getToken();
    if (token == null) return;

    try {
      // Fetch current head doctor
      final headDoctorResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/headdoctor'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch all doctors
      final doctorsResponse = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/doctors'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (headDoctorResponse.statusCode == 200 &&
          doctorsResponse.statusCode == 200) {
        // Parse current head doctor
        final headDoctorData = jsonDecode(headDoctorResponse.body)['data']
            ['doctors'] as Map<String, dynamic>;

        // Parse all doctors
        final allDoctorsData = jsonDecode(doctorsResponse.body)['data']
            ['doctors'] as List<dynamic>;

        // Prepare the doctors list
        List<Map<String, dynamic>> updatedDoctors = allDoctorsData
            .map((doc) => {
                  'id': doc['id'],
                  'name': doc['FullName'],
                  'role': doc['id'] == headDoctorData['id']
                      ? 'Head Doctor'
                      : 'Assistant Doctor',
                  'isHeadDoctor': doc['id'] == headDoctorData['id'],
                })
            .toList();

        setState(() {
          doctors = updatedDoctors;
          currentHeadDoctorId = headDoctorData['id'];
          currentHeadDoctorName = headDoctorData['FullName'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching doctors data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changeHeadDoctor(
      int newHeadDoctorId, String newHeadDoctorName) async {
    final token = await getToken();
    if (token == null) return;

    final body = jsonEncode({
      'currentHead': currentHeadDoctorId,
      'newHead': newHeadDoctorId,
    });

    try {
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/change-head'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Reload the page by re-fetching doctors data
        await _fetchDoctorsData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Head Doctor role transferred to $newHeadDoctorName'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to transfer Head Doctor role.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error transferring head doctor role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmTransfer(int doctorId, String doctorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Transfer'),
        content:
            Text('Are you sure you want to make $doctorName the Head Doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _changeHeadDoctor(doctorId, doctorName);
            },
            child: Text('Confirm', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Manage Doctors Transfer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentHeadDoctorName != null) ...[
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$currentHeadDoctorName',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Role: Head Doctor',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
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
                                  'Dr. ' + doctor['name'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Role: ${doctor['role']}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                                if (!doctor['isHeadDoctor'])
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => confirmTransfer(
                                          doctor['id'], doctor['name']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Text('Make Head Doctor'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
