import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_project/screens/Community/chat_screen.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:flutter_project/screens/Student/CompleteSign/partner_request.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class MatchingPage extends StatefulWidget {
  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  // Step 1: Select Project Type
  String? projectType;

  // Step 2: Questions based on Project Type
  bool? askBackend;
  bool? askFrontend;
  bool? askDatabase;
  bool? askAge;
  bool? askGender;
  bool? askLocation;

  // Step 3: Dynamic Fields
  String? backend;
  String? frontend;
  String? database;
  String? age;
  String? gender;
  String? location;
  String? selectedPartner;

  final List<String> palestineCities = [
    'Jerusalem',
    'Ramallah',
    'Nablus',
    'Hebron',
    'Gaza',
    'Jenin',
    'Tulkarm',
    'Bethlehem',
    'Qalqilya',
    'Salfit',
    'Jericho',
    'Rafah',
    'Khan Yunis',
  ];

  List<dynamic> matchedStudents = [];
  bool isWaitingForApproval = false;
  Timer? _statusCheckTimer;

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentGPType(); // Fetch the GP_Type when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find a Partner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PartnerRequestsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isWaitingForApproval
          ? _buildWaitingScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Matching Partner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Step 1: Project Type Selection
                    if (projectType != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Current Project Type: $projectType',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Step 2: Questions Based on Project Type
                    if (projectType == 'Software') ...[
                      _buildToggleQuestion(
                        question: 'Backend Framework',
                        value: askBackend,
                        onChanged: (value) {
                          setState(() {
                            askBackend = value;
                            if (value == false) backend = null; // Reset field
                          });
                        },
                      ),
                      _buildToggleQuestion(
                        question: 'Frontend Framework',
                        value: askFrontend,
                        onChanged: (value) {
                          setState(() {
                            askFrontend = value;
                            if (value == false) frontend = null; // Reset field
                          });
                        },
                      ),
                      _buildToggleQuestion(
                        question: 'Database',
                        value: askDatabase,
                        onChanged: (value) {
                          setState(() {
                            askDatabase = value;
                            if (value == false) database = null; // Reset field
                          });
                        },
                      ),
                    ],
                    if (projectType != null) ...[
                      _buildToggleQuestion(
                        question: 'Age',
                        value: askAge,
                        onChanged: (value) {
                          setState(() {
                            askAge = value;
                            if (value == false) age = null; // Reset field
                          });
                        },
                      ),
                      _buildToggleQuestion(
                        question: 'Gender',
                        value: askGender,
                        onChanged: (value) {
                          setState(() {
                            askGender = value;
                            if (value == false) gender = null; // Reset field
                          });
                        },
                      ),
                    ],
                    if (projectType == 'Hardware') ...[
                      _buildToggleQuestion(
                        question: 'City',
                        value: askLocation,
                        onChanged: (value) {
                          setState(() {
                            askLocation = value;
                            if (value == false) location = null; // Reset field
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Step 3: Dynamic Form Fields
                    if (askBackend == true)
                      _buildDropdown(
                        label: 'Preferred Backend Framework',
                        value: backend,
                        items: [
                          'Node.js',
                          'Laravel',
                          'Spring Boot',
                          'ASP.NET',
                          'Other'
                        ],
                        onChanged: (value) {
                          setState(() {
                            backend = value;
                          });
                        },
                      ),
                    if (askFrontend == true)
                      _buildDropdown(
                        label: 'Preferred Frontend Framework',
                        value: frontend,
                        items: [
                          'Flutter',
                          'React',
                          'Angular',
                          'HTML/CSS',
                          'Other'
                        ],
                        onChanged: (value) {
                          setState(() {
                            frontend = value;
                          });
                        },
                      ),
                    if (askDatabase == true)
                      _buildDropdown(
                        label: 'Preferred Database',
                        value: database,
                        items: [
                          'MySQL',
                          'Oracle',
                          'MongoDB',
                          'Django',
                          'Other'
                        ],
                        onChanged: (value) {
                          setState(() {
                            database = value;
                          });
                        },
                      ),
                    if (askAge == true)
                      _buildDropdown(
                        label: 'Age',
                        value: age,
                        items: List.generate(
                            43, (index) => (18 + index).toString()),
                        onChanged: (value) {
                          setState(() {
                            age = value;
                          });
                        },
                      ),
                    if (askGender == true)
                      _buildDropdown(
                        label: 'Gender',
                        value: gender,
                        items: ['Male', 'Female'],
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    if (askLocation == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: const TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search City',
                              ),
                            ),
                          ),
                          items: palestineCities,
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "City",
                              hintText: "Select a city",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              location = value;
                            });
                          },
                          selectedItem: location,
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Find Partner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Matched Students List
                    if (matchedStudents.isNotEmpty) ...[
                      const Text(
                        'Matched Students:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: matchedStudents.length,
                        itemBuilder: (context, index) {
                          final student = matchedStudents[index];
                          return GestureDetector(
                            onTap: () async {
                              // Show student info when the card is tapped
                              final studentInfo =
                                  await _fetchStudentInfo(student['Username']);
                              if (studentInfo != null) {
                                _showStudentInfoPopup(context, studentInfo);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to load student information.')),
                                );
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                title: Text(student['Username'] ?? 'Unknown'),
                                subtitle: Text(
                                  'Age: ${student['Age'] ?? 'N/A'}, Gender: ${student['Gender'] ?? 'N/A'}',
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedPartner = student['Username'];
                                      isWaitingForApproval = true;
                                    });
                                    _sendPartnerRequest(student['Username']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                  ),
                                  child: const Text(
                                    'Choose',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ]
                  ],
                ),
              ),
            ),
    );
  }

  Future<Map<String, dynamic>?> _fetchStudentInfo(String username) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/students/specific/$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch student information');
      }
    } catch (e) {
      print('Error fetching student info: $e');
      return null;
    }
  }

  Future<int?> _fetchUserId() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response for User ID: $data'); // Log the response

        // Check if the nested structure exists
        if (data != null &&
            data['data'] != null &&
            data['data']['data'] != null &&
            data['data']['data']['id'] != null) {
          return data['data']['data']['id']; // Extract the user ID
        } else {
          print('Invalid API response structure for /users/me');
          return null;
        }
      } else {
        print('Failed to fetch user ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }

  Future<int?> _fetchReceiverId(String username) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/users/username/$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response for Receiver ID: $data'); // Log the response

        // Check if the nested structure exists
        if (data != null &&
            data['data'] != null &&
            data['data']['user'] != null &&
            data['data']['user']['id'] != null) {
          return data['data']['user']['id']; // Extract the receiver ID
        } else {
          print('Invalid API response structure for /users/username/:Username');
          return null;
        }
      } else {
        print('Failed to fetch receiver ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching receiver ID: $e');
      return null;
    }
  }

  void _showStudentInfoPopup(
      BuildContext context, Map<String, dynamic> studentInfo) async {
    final username = studentInfo['Username'];
    final userid = await _fetchUserId();
    final receiverId = await _fetchReceiverId(username);

    if (userid != null && receiverId != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Student Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${studentInfo['Username'] ?? 'N/A'}'),
                Text(
                    'Registration Number: ${studentInfo['Registration_number'] ?? 'N/A'}'),
                Text('Status: ${studentInfo['Status'] ?? 'N/A'}'),
                Text('GP Type: ${studentInfo['GP_Type'] ?? 'N/A'}'),
                Text('Age: ${studentInfo['Age'] ?? 'N/A'}'),
                Text('Gender: ${studentInfo['Gender'] ?? 'N/A'}'),
                if (studentInfo['GP_Type'] == 'Software') ...[
                  Text('Backend: ${studentInfo['BE'] ?? 'N/A'}'),
                  Text('Frontend: ${studentInfo['FE'] ?? 'N/A'}'),
                  Text('Database: ${studentInfo['DB'] ?? 'N/A'}'),
                ],
                if (studentInfo['GP_Type'] == 'Hardware') ...[
                  Text('City: ${studentInfo['City'] ?? 'N/A'}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        senderId: userid,
                        receiverId: receiverId,
                        username: username,
                      ),
                    ),
                  );
                },
                child: const Text('Send Message'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user or receiver ID.')),
      );
    }
  }

  void _sendPartnerRequest(String username) async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList'),
        body: json.encode({'Partner_2': username}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _startStatusPolling();
    } catch (e) {
      print('Error sending partner request: $e');
    }
  }

  void _startStatusPolling() {
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final token = await _getToken();
        final response = await http.get(
          Uri.parse(
              '${dotenv.env['API_BASE_URL']}/GP/v1/students/getCurrentStudent'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Status'] == 'approvedpartner') {
            timer.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectStepper(
                  initialStep: 3,
                  partnerUsername: selectedPartner,
                ),
              ),
            );
          } else if (data['Status'] == 'declinedpartner') {
            timer.cancel();
            setState(() {
              isWaitingForApproval = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your partner request was declined.'),
              ),
            );
          }
        }
      } catch (e) {
        print('Error checking status: $e');
      }
    });
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Waiting for partner approval...',
            style: TextStyle(fontSize: 18, color: primaryColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 72),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _declineRequest, // Call the _declineRequest function
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              'Cancle Request',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Future<void> _onSubmit() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students/available'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> students = json.decode(response.body);
        setState(() {
          matchedStudents = _filterStudents(students);
        });
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  List<dynamic> _filterStudents(List<dynamic> students) {
    return students.where((student) {
      bool matches = true;

      // Ensure the Project Type is matched first
      if (projectType == 'Software') {
        matches &= student['GP_Type'] == 'Software';
        if (askBackend == true && backend != null) {
          matches &= student['BE'] == backend;
        }
        if (askFrontend == true && frontend != null) {
          matches &= student['FE'] == frontend;
        }
        if (askDatabase == true && database != null) {
          matches &= student['DB'] == database;
        }
      } else if (projectType == 'Hardware') {
        matches &= student['GP_Type'] == 'Hardware';
        if (askLocation == true && location != null) {
          matches &= student['City'] == location;
        }
      }

      // Match on Age and Gender (common for both types)
      if (askAge == true && age != null) {
        matches &= student['Age'] == age;
      }
      if (askGender == true && gender != null) {
        matches &= student['Gender'] == gender;
      }

      return matches;
    }).toList();
  }

  Future<void> _fetchStudentGPType() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          projectType = data['GP_Type']; // Automatically set projectType
        });
      } else {
        throw Exception('Failed to fetch GP_Type');
      }
    } catch (e) {
      print('Error fetching GP_Type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching project type.')),
      );
    }
  }

  void _resetAllFields() {
    askBackend = null;
    askFrontend = null;
    askDatabase = null;
    askAge = null;
    askGender = null;
    askLocation = null;
    backend = null;
    frontend = null;
    database = null;
    age = null;
    gender = null;
    location = null;
    matchedStudents = [];
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          DropdownButton<String>(
            value: value,
            hint: Text('Select $label'),
            isExpanded: true,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleQuestion({
    required String question,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          question,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        Switch(
          value: value ?? false, onChanged: onChanged,
          activeColor: primaryColor, // Switch color set to primaryColor
        ),
      ],
    );
  }

  Future<void> _declineRequest() async {
    try {
      final token = await _getToken(); // Retrieve the JWT token
      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/projects/waitinglist/partner/undo-request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _statusCheckTimer?.cancel(); // Stop polling
        setState(() {
          isWaitingForApproval = false; // Reset to normal page
        });
      } else {
        print('Failed to decline the request');
      }
    } catch (e) {
      print('Error while declining request: $e');
    }
  }
}
