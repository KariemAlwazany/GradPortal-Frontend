import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class FindPartnerPage extends StatefulWidget {
  final String studentId;

  FindPartnerPage({required this.studentId});

  @override
  _FindPartnerPageState createState() => _FindPartnerPageState();
}

class _FindPartnerPageState extends State<FindPartnerPage> {
  Map<String, dynamic>? currentStudent;
  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> otherStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchData() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      // Fetch current student information
      final currentStudentResponse =
          await _fetchCurrentStudent(widget.studentId, token);
      final availableStudentsResponse = await _fetchAvailableStudents(
          currentStudentResponse['Username'], token);

      setState(() {
        currentStudent = currentStudentResponse;
        _matchStudents(currentStudentResponse, availableStudentsResponse);
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchCurrentStudent(
      String username, String token) async {
    final url =
        '${dotenv.env['API_BASE_URL']}/GP/v1/students/specific/$username';
    final response = await http.get(
      Uri.parse(url.trim()),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current student information');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableStudents(
      String username, String token) async {
    final url =
        '${dotenv.env['API_BASE_URL']}/GP/v1/students/available/$username';
    final response = await http.get(
      Uri.parse(url.trim()),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load available students');
    }
  }

  void _matchStudents(Map<String, dynamic> current,
      List<Map<String, dynamic>> availableStudents) {
    suggestions.clear();
    otherStudents.clear();

    for (var student in availableStudents) {
      int matchingScore = 0;
      int totalCriteria = 7;

      // Matching logic
      if (current['GP_Type'] != null &&
          current['GP_Type'] == student['GP_Type']) matchingScore++;
      if (current['Age'] != null && current['Age'] == student['Age'])
        matchingScore++;
      if (current['Gender'] != null && current['Gender'] == student['Gender'])
        matchingScore++;
      if (current['BE'] != null && current['BE'] == student['BE'])
        matchingScore++;
      if (current['FE'] != null && current['FE'] == student['FE'])
        matchingScore++;
      if (current['DB'] != null && current['DB'] == student['DB'])
        matchingScore++;
      if (current['City'] != null && current['City'] == student['City'])
        matchingScore++;

      double matchPercentage = (matchingScore / totalCriteria) * 100;

      // Categorize students
      if (matchPercentage >= 80) {
        student['matchPercentage'] = matchPercentage.toStringAsFixed(1) + '%';
        suggestions.add(student);
      } else {
        otherStudents.add(student);
      }
    }
  }

  Future<void> _choosePartner(String partner2Username) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      final url =
          '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/headDoctor/choose-partner';
      final body = json.encode({
        "Partner_1": currentStudent?['Username'],
        "Partner_2": partner2Username,
      });

      final response = await http.post(
        Uri.parse(url.trim()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Partner chosen successfully')),
        );
      } else {
        print('Failed to choose partner: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to choose partner')),
        );
      }
    } catch (error) {
      print('Error choosing partner: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Partner', style: TextStyle(color: Colors.white)),
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
                    // Suggested Partners Section
                    Text(
                      'Suggested Partners',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    suggestions.isEmpty
                        ? Center(
                            child: Text(
                              'No Suggestions Found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : _buildListView(context, suggestions,
                            isSuggestion: true),
                    SizedBox(height: 20),

                    // Other Available Students Section
                    Text(
                      'Other Available Students',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    otherStudents.isEmpty
                        ? Center(
                            child: Text(
                              'No Other Students Found',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : _buildListView(context, otherStudents),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildListView(
      BuildContext context, List<Map<String, dynamic>> students,
      {bool isSuggestion = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            onTap: () {
              _showStudentInfo(context, student);
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
                        student['Username'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (isSuggestion)
                        Text(
                          'Match: ${student['matchPercentage']}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                      _choosePartner(student['Username']);
                    },
                    child: Text('Choose'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStudentInfo(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(student['Username'], style: TextStyle(color: primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${student['id']}'),
              if (student.containsKey('matchPercentage'))
                Text('Match: ${student['matchPercentage']}'),
              Text('Age: ${student['Age'] ?? 'N/A'}'),
              Text('Gender: ${student['Gender'] ?? 'N/A'}'),
              Text('GP Type: ${student['GP_Type'] ?? 'N/A'}'),
              Text('City: ${student['City'] ?? 'N/A'}'),
              Text('BE: ${student['BE'] ?? 'N/A'}'),
              Text('FE: ${student['FE'] ?? 'N/A'}'),
              Text('DB: ${student['DB'] ?? 'N/A'}'),
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
