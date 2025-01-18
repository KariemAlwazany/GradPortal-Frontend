// package:flutter_project/screens/Student/CompleteSign/ProjectStepper.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page1.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page2.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page4.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page5.dart';
import 'package:flutter_project/screens/Student/CompleteSign/questions_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color stepInactiveColor = Colors.white70;

class ProjectStepper extends StatefulWidget {
  final int initialStep;

  const ProjectStepper(
      {super.key, this.initialStep = 0, String? partnerUsername});

  @override
  _ProjectStepperState createState() => _ProjectStepperState();
}

class _ProjectStepperState extends State<ProjectStepper>
    with SingleTickerProviderStateMixin {
  late int _currentStep;
  final int _totalSteps = 5;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep; // Start at specified initial step
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Custom Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // Stepper with icons and dividers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_totalSteps, (index) {
                      return _buildStep(index);
                    }),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Content for each step
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _getStepPage(_currentStep),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    bool isActive = _currentStep == index;
    bool isCompleted = index < _currentStep;
    bool disableStepper = _currentStep >= _totalSteps;

    return GestureDetector(
      onTap: (disableStepper || _currentStep < index)
          ? null
          : () {
              setState(() {
                _animationController.forward(from: 0);
                _currentStep = index;
                _scrollToCurrentStep();
              });
            },
      child: Column(
        children: [
          Center(
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isCompleted
                          ? Colors.green
                          : (isActive ? Colors.white : stepInactiveColor),
                      child: isCompleted
                          ? const Icon(Icons.check, color: primaryColor)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isActive ? primaryColor : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
                if (index < _totalSteps - 1)
                  Container(
                    width: 42,
                    height: 2,
                    color: isCompleted ? Colors.green : stepInactiveColor,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Step ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : stepInactiveColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepPage(int step) {
    switch (step) {
      case 0:
        return ProjectTypePage(onNext: _nextStep, key: ValueKey(step));
      case 1:
        return QuestionsPage(
          projectType: typeGP, // Pass the project type to the QuestionsPage
          onNext: _nextStep,
          onPrevious: _previousStep,
          key: ValueKey(step),
        );
      case 2:
        return SecondPage(
          onNext: _nextStep,
          onPrevious: _previousStep,
          key: ValueKey(step),
        );
      case 3:
        return ThirdPage(
          onPrevious: _previousStep,
          onNext: _nextStep,
          key: ValueKey(step),
        );
      case 4:
        return FourthPage(
          onPrevious: _previousStep,
          key: ValueKey(step),
        );
      default:
        return ProjectTypePage(onNext: _nextStep, key: ValueKey(step));
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep += 1;
        _animationController.forward(from: 0);
        _scrollToCurrentStep();
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
        _animationController.forward(from: 0);
        _scrollToCurrentStep();
      });
    }
  }

  void _scrollToCurrentStep() {
    double offset = (_currentStep * 60.0) - 60;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

String typeGP = 'ProjectType';

// Variables to store user choices
bool hasPartner = false;
String? selectedPartner = '';
bool hasDoctor = false;
String? selectedDoctor = '';
List<String?> selectedDoctors = [null, null, null];

// Function to retrieve the JWT token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

// Function to send the data to the waiting list API
Future<void> addToWaitingList({
  required String partner1,
  String? partner2,
  required String projectType,
  required String projectStatus,
  required String partnerStatus,
  String? doctor1,
  String? doctor2,
  String? doctor3,
}) async {
  final String? token = await getToken();

  if (token == null) {
    throw Exception('JWT token not found');
  }

  final Map<String, dynamic> payload = {
    'Partner_2': partner2,
    'ProjectType': projectType,
    'ProjectStatus': projectStatus,
    'PartnerStatus': partnerStatus,
    'Doctor1': doctor1,
    'Doctor2': doctor2,
    'Doctor3': doctor3,
  };

  final response = await http.post(
    Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(payload),
  );

  if (response.statusCode == 200) {
    print('Successfully added to waiting list');
  } else {
    print('Failed to add to waiting list: ${response.statusCode}');
    throw Exception('Failed to add to waiting list');
  }
}

class ProjectTypePage extends StatelessWidget {
  final VoidCallback onNext;
  const ProjectTypePage({required this.onNext, super.key});
  void setType(String type) {
    typeGP = type;
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 160),
            const Text(
              'Choose Your Project Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () => setType("Software"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Software',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setType("Hardware"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Hardware',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to fetch students (partners) from the API
Future<List<String>> fetchStudents() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> students = json.decode(response.body);
    return students.map((student) => student['Username'].toString()).toList();
  } else {
    throw Exception('Failed to load students');
  }
}

// Function to fetch doctors from the API
Future<List<String>> fetchDoctors() async {
  final response = await http
      .get(Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/doctors/available'));

  if (response.statusCode == 200) {
    List<dynamic> doctors = json.decode(response.body);
    return doctors.map((doctor) => doctor['Username'].toString()).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}
