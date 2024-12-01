import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
            _buildDropdown(
              label: 'Project Type',
              value: projectType,
              items: ['Software', 'Hardware'],
              onChanged: (value) {
                setState(() {
                  projectType = value;
                  _resetAllFields(); // Reset all fields when GP type changes
                });
              },
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
                items: ['Node.js', 'Laravel', '.NET', 'Spring Boot', 'Other'],
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
                items: ['Flutter', 'React', 'HTML/CSS', 'Other'],
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
                items: ['MySQL', 'Oracle', 'MongoDB', 'Other'],
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
                items: List.generate(43, (index) => (18 + index).toString()),
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
              onPressed: _onSubmit, // Ensure this calls the correct function
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
                shrinkWrap: true, // Allow ListView inside SingleChildScrollView
                physics: NeverScrollableScrollPhysics(),
                itemCount: matchedStudents.length,
                itemBuilder: (context, index) {
                  final student = matchedStudents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(student['Username'] ?? 'Unknown'),
                      subtitle: Text(
                          'Age: ${student['Age'] ?? 'N/A'}, Gender: ${student['Gender'] ?? 'N/A'}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          print('Selected Partner: ${student['Username']}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]
          ]),
        ),
      ),
    );
  }

  void _resetAllFields() {
    // Reset all fields and states
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

  // Helper to build toggle questions
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Switch(
          value: value ?? false,
          onChanged: onChanged,
          activeColor: primaryColor,
        ),
      ],
    );
  }

  // Helper to build dropdowns
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          DropdownButton<String>(
            value: value,
            hint: Text('Select $label'),
            isExpanded: true,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: const TextStyle(color: primaryColor),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    print('Find Partner button pressed'); // Debug log

    final token = await _getToken();
    if (token == null) {
      print('Authentication token not found'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); // Debug log
        final List<dynamic> students = json.decode(response.body);
        setState(() {
          matchedStudents = _filterStudents(students);
        });
      } else {
        print('Failed to fetch students: ${response.statusCode}'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch students')),
        );
      }
    } catch (e) {
      print('Error fetching students: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students')),
      );
    }
  }

  List<dynamic> _filterStudents(List<dynamic> students) {
    return students.where((student) {
      bool matches = true;
      if (projectType == 'Software') {
        if (askBackend == true && backend != null) {
          matches &= student['BE'] == backend;
        }
        if (askFrontend == true && frontend != null) {
          matches &= student['FE'] == frontend;
        }
        if (askDatabase == true && database != null) {
          matches &= student['DB'] == database;
        }
      }
      if (askAge == true && age != null) {
        matches &= student['Age'] == age;
      }
      if (askGender == true && gender != null) {
        matches &= student['Gender'] == gender;
      }
      if (projectType == 'Hardware' &&
          askLocation == true &&
          location != null) {
        matches &= student['City'] == location;
      }
      return matches;
    }).toList();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
