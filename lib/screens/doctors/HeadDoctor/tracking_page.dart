import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/partnerlist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class StudentStatusPage extends StatefulWidget {
  @override
  _StudentStatusPageState createState() => _StudentStatusPageState();
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}

class _StudentStatusPageState extends State<StudentStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    'Joining',
    'Partner',
    'Doctor',
    'Abstract',
    'Final'
  ];

  List<Map<String, dynamic>> students = [];
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _fetchStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
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

    final url = '$baseUrl/GP/v1/students';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          students = data.map((studentData) {
            String status = studentData['Status'];

            Map<String, String> statuses = {
              'Joining': _getJoiningStatus(status),
              'Partner': _getPartnerStatus(status),
              'Doctor': _getDoctorStatus(status),
              'Abstract Submission': 'Not Started',
              'Final Submission': 'Not Started',
            };

            return {
              'name': studentData['Username'],
              'id': studentData['Registration_number'],
              'GP_Type': studentData['GP_Type'] ?? 'N/A',
              'age': studentData['Age']?.toString() ?? 'N/A',
              'gender': studentData['Gender'] ?? 'N/A',
              'city': studentData['City'] ?? 'N/A',
              'BE': studentData['BE'] ?? 'N/A',
              'FE': studentData['FE'] ?? 'N/A',
              'DB': studentData['DB'] ?? 'N/A',
              'statuses': statuses,
            };
          }).toList();
        });

        // Fetch the final and abstract submission statuses for each student
        for (var student in students) {
          final studentUsername = student['name'];
          await _fetchSubmissionStatus(studentUsername, token);
        }

// Trigger final UI rebuild
        setState(() {
          students = List.from(students);
        });
      } else {
        print('Failed to load students. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching students: $error');
    }
  }

  Future<void> _fetchSubmissionStatus(String username, String token) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      print('API base URL not found in .env');
      return;
    }

    final studentIndex =
        students.indexWhere((student) => student['name'] == username);

    if (studentIndex == -1) return; // Student not found

    Map<String, dynamic> updatedStudent = Map.from(students[studentIndex]);

    // Check Final Submission
    final finalUrl = '$baseUrl/GP/v1/submit/final/$username';
    try {
      final finalResponse = await http.get(
        Uri.parse(finalUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (finalResponse.statusCode == 200) {
        final jsonResponse = json.decode(finalResponse.body);
        final submissionData = jsonResponse['data']['findSubmit'];
        if (submissionData != null) {
          updatedStudent['statuses']['Final Submission'] = 'Completed';
        } else {
          updatedStudent['statuses']['Final Submission'] = 'Not Started';
        }
      } else {
        print(
            'Failed to fetch final submission status for $username: ${finalResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching final submission status for $username: $error');
    }

    // Check Abstract Submission
    final abstractUrl = '$baseUrl/GP/v1/submit/abstract/$username';
    try {
      final abstractResponse = await http.get(
        Uri.parse(abstractUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (abstractResponse.statusCode == 200) {
        final jsonResponse = json.decode(abstractResponse.body);
        final submissionData = jsonResponse['data']['findSubmit'];
        if (submissionData != null) {
          updatedStudent['statuses']['Abstract Submission'] = 'Completed';
        } else {
          updatedStudent['statuses']['Abstract Submission'] = 'Not Started';
        }
      } else {
        print(
            'Failed to fetch abstract submission status for $username: ${abstractResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching abstract submission status for $username: $error');
    }

    // Replace the old student entry with the updated one
    setState(() {
      students[studentIndex] = updatedStudent;
    });
  }

  String _getJoiningStatus(String status) {
    if (status == 'approved' ||
        status == 'waitapprove' ||
        status == 'start' ||
        status == 'waitpartner' ||
        status == 'declinedpartner' ||
        status == 'waiting') return 'Completed';
    return 'Pending';
  }

  String _getPartnerStatus(String status) {
    if (status == 'approved' || status == 'completed') return 'Completed';
    if (status == 'approvedpartner') return 'Completed';
    if (status == 'waitpartner') return 'Pending';
    if (status == 'declinedpartner') return 'Declined';
    if (status == 'waitapprove') return 'Completed';

    return 'Not Started';
  }

  String _getDoctorStatus(String status) {
    if (status == 'approved' ||
        status == 'completed' ||
        status == 'waitapprove') return 'Completed';
    if (status == 'waiting') return 'Pending';
    if (status == 'declineDoctor') return 'Declined';
    return 'Not Started';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Status', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs
              .map(
                (tab) => Tab(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          indicatorColor: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Filter Dropdown and Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                    items: [
                      'All',
                      'Completed',
                      'Pending',
                      'Not Started',
                    ].map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Students',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentName =
                        student['name'].toString().toLowerCase();
                    final status = student['statuses'][tab] ?? 'Not Started';

                    // Apply Search Filter
                    if (searchQuery.isNotEmpty &&
                        !studentName.contains(searchQuery)) {
                      return SizedBox.shrink();
                    }

                    // Apply Status Filter
                    if (selectedFilter != 'All' && status != selectedFilter) {
                      return SizedBox.shrink();
                    }

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(student['name']),
                        subtitle: Text('$status'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsPage(
                                student: student,
                                onRemove: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onRemove;

  StudentDetailsPage({required this.student, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student['name']} Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                _buildInfoRow('Name', student['name']),
                _buildInfoRow('ID', student['id']),
                _buildInfoRow('Project Type', student['GP_Type']),
                _buildInfoRow('Age', student['age']),
                _buildInfoRow('Gender', student['gender']),
                _buildInfoRow('City', student['city']),
                _buildInfoRow('Backend Framework', student['BE']),
                _buildInfoRow('Frontend Framework', student['FE']),
                _buildInfoRow('Database', student['DB']),
                Divider(),
                Text(
                  'Status Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                ...student['statuses'].entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 16,
                        color: entry.value == 'Completed'
                            ? Colors.green
                            : entry.value == 'Pending'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PartnerRequestsPage(studentId: student['name']),
                      ),
                    );
                  },
                  icon: Icon(Icons.group),
                  label: Text('Show Requests List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final token = await getToken(); // Fetch the token

                    if (token != null) {
                      // Call the removeStudent function
                      await removeStudent(student['name'], token);

                      // Call the onRemove callback to remove the student from the list
                      onRemove();
                    } else {
                      print('No token found!');
                    }
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Remove Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> removeStudent(String username, String token) async {
  final String apiUrl =
      '${dotenv.env['API_BASE_URL']}/GP/v1/users/username/$username'; // Dynamic API URL

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token', // Send token in the header
        'Content-Type':
            'application/json', // Optional, as per the API requirements
      },
    );

    if (response.statusCode == 204) {
      // Student was removed successfully
      print('Student removed successfully');
    } else {
      // Handle failure response
      print('Failed to remove student: ${response.statusCode}');
    }
  } catch (e) {
    // Handle error
    print('Error occurred: $e');
  }
}
