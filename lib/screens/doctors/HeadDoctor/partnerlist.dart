import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/finddoctor.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/findpartner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for date formatting

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class PartnerRequestsPage extends StatefulWidget {
  final String studentId;

  PartnerRequestsPage({required this.studentId});

  @override
  _PartnerRequestsPageState createState() => _PartnerRequestsPageState();
}

class _PartnerRequestsPageState extends State<PartnerRequestsPage> {
  List<Map<String, dynamic>> partnerRequests = [];
  List<Map<String, dynamic>> doctorRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final token = await getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      print('API base URL not found in .env');
      return;
    }

    try {
      // Fetch Partner Requests
      final partnerUrl =
          '$baseUrl/GP/v1/WaitingPartnerList/declined-list/${widget.studentId}';
      final partnerResponse = await http.get(
        Uri.parse(partnerUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (partnerResponse.statusCode == 200) {
        final List<dynamic> partnerData = json.decode(partnerResponse.body);
        setState(() {
          partnerRequests = partnerData.map((request) {
            return {
              'id': request['id'],
              'partner1': request['Partner_1'],
              'partner2': request['Partner_2'],
              'status': request['PartnerStatus'],
              'createdAt': request['createdAt'],
              'updatedAt': request['updatedAt'],
            };
          }).toList();
        });
      }

      // Fetch Doctor Requests
      final doctorUrl =
          '$baseUrl/GP/v1/projects/WaitingList/declined-doctor-list/${widget.studentId}';
      final doctorResponse = await http.get(
        Uri.parse(doctorUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (doctorResponse.statusCode == 200) {
        final Map<String, dynamic> doctorData =
            json.decode(doctorResponse.body);
        if (doctorData['status'] == 'success') {
          final List<dynamic> declinedList = doctorData['data']['declinedList'];
          setState(() {
            doctorRequests = declinedList.map((request) {
              return {
                'doctor1': request['Doctor1'],
                'partner1': request['Partner_1'],
                'doctorStatus': request['DoctorStatus'],
                'createdAt': request['createdAt'],
                'updatedAt': request['updatedAt'],
              };
            }).toList();
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching requests: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _findPartner() async {
    final token = await getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      print('API base URL not found in .env');
      return;
    }

    final findPartnerUrl = '$baseUrl/GP/v1/find_partner/${widget.studentId}';

    try {
      final response = await http.post(
        Uri.parse(findPartnerUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Partner search initiated successfully')),
        );
      } else {
        print('Failed to initiate partner search');
      }
    } catch (error) {
      print('Error finding partner: $error');
    }
  }

  Future<void> _findDoctor() async {
    final token = await getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      print('API base URL not found in .env');
      return;
    }

    final findDoctorUrl = '$baseUrl/GP/v1/find_doctor/${widget.studentId}';

    try {
      final response = await http.post(
        Uri.parse(findDoctorUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor search initiated successfully')),
        );
      } else {
        print('Failed to initiate doctor search');
      }
    } catch (error) {
      print('Error finding doctor: $error');
    }
  }

  String _formatDate(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime; // Return the original date string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Partner Requests Section
                    Text(
                      'Partner Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    partnerRequests.isEmpty
                        ? Text('No Partner Requests Found')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: partnerRequests.length,
                            itemBuilder: (context, index) {
                              final request = partnerRequests[index];
                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0),
                                  title: Text(
                                    'From: ${request['partner1']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('To: ${request['partner2']}'),
                                      Text('Status: ${request['status']}'),
                                      Text(
                                        'Requested at: ${_formatDate(request['createdAt'])}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Declined at: ${_formatDate(request['updatedAt'])}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FindPartnerPage(studentId: widget.studentId),
                            ),
                          );
                        },
                        icon: Icon(Icons.search),
                        label: Text('Find Partner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Doctor Requests Section
                    Text(
                      'Doctor Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    doctorRequests.isEmpty
                        ? Text('No Doctor Requests Found')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: doctorRequests.length,
                            itemBuilder: (context, index) {
                              final request = doctorRequests[index];
                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0),
                                  title: Text(
                                    'Doctor: ${request['doctor1']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Requested by: ${request['partner1']}'),
                                      Text(
                                          'Doctor Status: ${request['doctorStatus']}'),
                                      Text(
                                        'Requested at: ${_formatDate(request['createdAt'])}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Updated at: ${_formatDate(request['updatedAt'])}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FindDoctorPage(studentId: widget.studentId),
                            ),
                          );
                        },
                        icon: Icon(Icons.search),
                        label: Text('Find Doctor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}
