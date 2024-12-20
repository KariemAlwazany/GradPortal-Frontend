import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class QuestionsPage extends StatefulWidget {
  final String projectType;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const QuestionsPage({
    required this.projectType,
    required this.onNext, // Ensure this is defined
    required this.onPrevious, // Ensure this is defined
    super.key,
  });

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  String? backend;
  String? frontend;
  String? database;
  String? age;
  String? gender;
  String? location;

  final List<String> palestineCities = [
    'Nablus',
    'Ramallah',
    'Gaza',
    'Hebron',
    'Jericho',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Salfit',
    'Tubas',
    'Rafah',
    'Khan Younis',
    'Deir al-Balah',
    'Beit Hanoun',
    'Beit Lahia',
    'Al-Bireh',
    'Halhul',
    'Dura',
    'Yatta',
    'Tarqumiyah',
    'Abu Dis',
  ];

  final List<String> ages =
      List.generate(43, (index) => (18 + index).toString());

  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void dispose() {
    ageController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> sendPatchRequest() async {
    final String? token = await getToken();

    if (token == null) {
      // Handle missing token
      print('JWT token not found');
      return;
    }

    final String url1 =
        '${dotenv.env['API_BASE_URL']}/GP/v1/students'; // First endpoint
    final String url2 =
        '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/informationEntered'; // Second endpoint

    // Common body for both requests
    final Map<String, dynamic> body = {
      'GP_Type': widget.projectType,
      'FE': frontend,
      'BE': backend,
      'DB': database,
      'City': widget.projectType == 'Hardware' ? location : null,
      'Gender': gender,
      'Age': age,
    };

    try {
      // First PATCH request
      final response1 = await http.patch(
        Uri.parse(url1),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response1.statusCode != 200) {
        throw Exception(
            'Failed to send PATCH request to $url1: ${response1.statusCode}');
      }

      // Second PATCH request
      final response2 = await http.patch(
        Uri.parse(url2),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response2.statusCode != 200) {
        throw Exception(
            'Failed to send PATCH request to $url2: ${response2.statusCode}');
      }

      print('Both PATCH requests were successful');
      widget.onNext(); // Move to the next step
    } catch (e) {
      print('Error sending PATCH requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              if (widget.projectType == "Software") ...[
                _buildDropdown(
                  label: 'Backend Framework',
                  value: backend,
                  items: ['Node.js', 'Laravel', 'Spring Boot', 'Other'],
                  onChanged: (value) {
                    setState(() {
                      backend = value;
                    });
                  },
                ),
                _buildDropdown(
                  label: 'Frontend Framework',
                  value: frontend,
                  items: ['Flutter', 'React', 'HTML/CSS', 'Other'],
                  onChanged: (value) {
                    setState(() {
                      frontend = value;
                    });
                  },
                ),
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
              ],
              _buildSearchableField(
                label: 'Age',
                controller: ageController,
                suggestions: ages,
                onSuggestionSelected: (selectedAge) {
                  setState(() {
                    age = selectedAge;
                    ageController.text = selectedAge;
                  });
                },
              ),
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
              if (widget.projectType == "Hardware")
                _buildSearchableField(
                  label: 'City',
                  controller: cityController,
                  suggestions: palestineCities,
                  onSuggestionSelected: (selectedCity) {
                    setState(() {
                      location = selectedCity;
                      cityController.text = selectedCity;
                    });
                  },
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.onPrevious,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.all(20),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  if (_areAllFieldsFilled())
                    ElevatedButton(
                      onPressed: () async {
                        await sendPatchRequest();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.all(20),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select $label',
                  style: const TextStyle(color: primaryColor),
                ),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(item),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
              dropdownColor: Colors.white,
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableField({
    required String label,
    required TextEditingController controller,
    required List<String> suggestions,
    required ValueChanged<String> onSuggestionSelected,
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search $label',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            suggestionsCallback: (pattern) {
              return suggestions
                  .where((item) =>
                      item.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: onSuggestionSelected,
          ),
        ],
      ),
    );
  }

  bool _areAllFieldsFilled() {
    if (widget.projectType == "Hardware") {
      return age != null && gender != null && location != null;
    } else if (widget.projectType == "Software") {
      return backend != null &&
          frontend != null &&
          database != null &&
          age != null &&
          gender != null;
    }
    return false;
  }
}
