import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createMeeting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class CreateMeetingForGroupPage extends StatefulWidget {
  @override
  _CreateMeetingForGroupPageState createState() =>
      _CreateMeetingForGroupPageState();
}

class _CreateMeetingForGroupPageState extends State<CreateMeetingForGroupPage> {
  String selectedCategory = 'All Projects';
  List<Map<String, dynamic>> allProjects = [];
  List<Map<String, dynamic>> filteredProjects = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchProjects() async {
    final token = await getToken();
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/students';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final projects = data['data']['allStudents'];

      setState(() {
        for (var project in projects) {
          final projectData = {
            'GP_ID': project['GP_ID'], // Group ID
            'GP_Title': project['GP_Title'],
            'GP_Type': project['GP_Type'],
            'Student1': project['Student1'],
            'Student2': project['Student2'],
          };

          allProjects.add(projectData);
        }
        _filterProjects();
      });
    }
  }

  Future<void> createMeetingForGroup(
      int id, DateTime date, TimeOfDay time) async {
    final token = await getToken();
    final apiUrl =
        '${dotenv.env['API_BASE_URL']}/GP/v1/meetings/createMeetingForGroup';

    try {
      final meetingDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ).toIso8601String();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": id,
          "Date": meetingDateTime,
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

  void _filterProjects() {
    setState(() {
      if (selectedCategory == 'All Projects') {
        filteredProjects = List.from(allProjects);
      } else {
        filteredProjects = allProjects
            .where((project) => project['GP_Type'] == selectedCategory)
            .toList();
      }
    });
  }

  void _showDateTimeDialog(Map<String, dynamic> project) {
    selectedDate = null;
    selectedTime = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Schedule Meeting',
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

                        // Automatically open time picker after selecting date
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
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
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton(
                  onPressed: selectedDate != null && selectedTime != null
                      ? () {
                          createMeetingForGroup(
                              project['GP_ID'], selectedDate!, selectedTime!);
                          Navigator.pop(context);
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Create Meeting for Groups',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('All Projects'),
                _buildFilterButton('Hardware'),
                _buildFilterButton('Software'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                return GestureDetector(
                  onTap: () => _showDateTimeDialog(project),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        project['GP_Title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Type: ${project['GP_Type']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Students: ${project['Student1']?['Username'] ?? 'N/A'}, ${project['Student2']?['Username'] ?? 'N/A'}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: primaryColor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
          _filterProjects();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedCategory == category ? primaryColor : Colors.grey[300],
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: selectedCategory == category ? Colors.white : primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
