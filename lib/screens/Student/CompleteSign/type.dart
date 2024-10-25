import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/student.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_project/screens/NormalUser/project_screen.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'dart:async'; // For using Timer

const Color primaryColor = Color(0xFF3B4280);
const Color stepInactiveColor = Colors.white70;
const Color lineColorActive = Colors.white;
const Color lineColorInactive = Colors.white24;

class ProjectStepper extends StatefulWidget {
  const ProjectStepper({super.key});

  @override
  _ProjectStepperState createState() => _ProjectStepperState();
}

class _ProjectStepperState extends State<ProjectStepper>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = 4;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
            SizedBox(
              height: 20,
            ),
            // Custom Stepper
            Container(
              // Adjust height to fit stepper and progress bar
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
                  // Progress bar
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

    // Disable stepper interaction when the current step is 4
    bool disableStepper = _currentStep >= 3;

    return GestureDetector(
      onTap: (disableStepper || _currentStep < index)
          ? null
          : () {
              setState(() {
                _animationController.forward(from: 0); // Trigger animation
                _currentStep = index;
                _scrollToCurrentStep();
              });
            },
      child: Column(
        children: [
          // Wrapping the Row in a Center to ensure proper alignment
          Center(
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Step Circle
                    CircleAvatar(
                      radius: 20, // Larger circle for modern design
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
                    width: 76,
                    height: 2,
                    color: isCompleted ? Colors.green : stepInactiveColor,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Wrapping the Text in Center to align it under the Circle
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
        return SecondPage(
          onNext: _nextStep,
          onPrevious: _previousStep,
          key: ValueKey(step),
        );
      case 2:
        return ThirdPage(
          onPrevious: _previousStep,
          key: ValueKey(step),
          onNext: _nextStep,
        );
      case 3:
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
        _animationController.forward(
            from: 0); // Trigger animation on step change
        _scrollToCurrentStep();
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
        _animationController.forward(
            from: 0); // Trigger animation on step change
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
List<String?> selectedDoctors = [null, null, null]; // For the 3 doctor lists

// Function to retrieve the JWT token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
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
  final String? token = await getToken(); // Get the JWT token

  if (token == null) {
    throw Exception('JWT token not found');
  }

  // Prepare the payload
  final Map<String, dynamic> payload = {
    'Partner_2': partner2,
    'ProjectType': projectType,
    'ProjectStatus': projectStatus,
    'PartnerStatus': partnerStatus,
    'Doctor1': doctor1,
    'Doctor2': doctor2,
    'Doctor3': doctor3,
  };

  // Make the POST request
  final response = await http.post(
    Uri.parse('http://192.168.88.2:3000/GP/v1/projects/WaitingList'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Add JWT token in headers
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
            SizedBox(
              height: 160,
            ),
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
  final response =
      await http.get(Uri.parse('http://192.168.88.2:3000/GP/v1/students'));

  if (response.statusCode == 200) {
    List<dynamic> students = json.decode(response.body);
    return students.map((student) => student['Username'].toString()).toList();
  } else {
    throw Exception('Failed to load students');
  }
}

// Function to fetch doctors from the API
Future<List<String>> fetchDoctors() async {
  final response =
      await http.get(Uri.parse('http://192.168.88.2:3000/GP/v1/doctors'));

  if (response.statusCode == 200) {
    List<dynamic> doctors = json.decode(response.body);
    return doctors.map((doctor) => doctor['Username'].toString()).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}

class SecondPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const SecondPage({required this.onNext, required this.onPrevious, super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool answered = false;
  List<String> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    try {
      final studentList = await fetchStudents();
      setState(() {
        students = studentList;
      });
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  // This method clears fields based on the partner selection
  void onAnswer(bool mateStatus) {
    setState(() {
      hasPartner = mateStatus;
      answered = true;

      if (mateStatus) {
        // If "Yes" is selected, clear any "No Partner" selection
        selectedPartner = '';
      } else {
        // If "No" is selected, clear the selected partner
        selectedPartner = null;
      }
    });
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
              'Do You Have a Partner?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () =>
                  onAnswer(true), // "Yes" button clears "No Partner" selection
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
                'Yes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Assuming primaryColor is blue
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  onAnswer(false), // "No" button clears "Yes Partner" selection
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
                'No',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Assuming primaryColor is blue
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (answered) ...[
              Text(
                hasPartner
                    ? 'Choose your Partner:'
                    : 'Choose one from the available students:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: TextEditingController(text: selectedPartner),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'Search Student',
                  ),
                ),
                suggestionsCallback: (pattern) {
                  final allStudents = [...students, 'Other'];
                  return allStudents.where(
                    (student) =>
                        student.toLowerCase().contains(pattern.toLowerCase()),
                  );
                },
                itemBuilder: (context, String student) {
                  return ListTile(
                    title: Text(student),
                  );
                },
                onSuggestionSelected: (String student) {
                  setState(() {
                    selectedPartner = student;
                  });
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select a student';
                  }
                  return null;
                },
                onSaved: (value) => selectedPartner = value,
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 40),
            // Align "Previous" and "Next" buttons in a row
            Row(
              children: [
                // Previous Button on the Left
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
                const Spacer(), // Spacer to push the Next button to the right
                // Next Button on the Right (only visible if a student is selected)
                if (selectedPartner != null)
                  ElevatedButton(
                    onPressed: widget.onNext,
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
    );
  }
}

class ThirdPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const ThirdPage({required this.onNext, required this.onPrevious, super.key});

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  bool answered = false;
  List<String> doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() async {
    try {
      final doctorList = await fetchDoctors();
      setState(() {
        doctors = doctorList;
      });
    } catch (e) {
      print('Error loading doctors: $e');
    }
  }

  void onAnswer(bool booked) {
    setState(() {
      hasDoctor = booked;
      answered = true;

      if (booked) {
        // If "Yes" is selected, clear multi-doctor selection
        selectedDoctors = [null, null, null];
      } else {
        // If "No" is selected, clear the single doctor selection
        selectedDoctor = null;
      }
    });
  }

  List<String> getAvailableDoctors(int currentDropdownIndex) {
    Set<String> selected = selectedDoctors
        .where((doctor) =>
            doctor != null && doctor != selectedDoctors[currentDropdownIndex])
        .cast<String>()
        .toSet();

    return doctors.where((doctor) => !selected.contains(doctor)).toList();
  }

  // Function to handle adding project to waiting list
  void _sendProjectToWaitingList() async {
    final String partner1 =
        'Partner_1_Name'; // Replace with actual partner1 variable
    String? partner2 = selectedPartner;
    String partnerStatus = hasPartner ? 'waiting' : 'no_partner';

    try {
      await addToWaitingList(
        partner1: partner1,
        partner2: partner2,
        projectType: typeGP, // Either "Hardware" or "Software"
        projectStatus: 'waiting',
        partnerStatus: partnerStatus,
        doctor1: hasDoctor
            ? selectedDoctor // If "Yes" is selected, use the single doctor
            : selectedDoctors[
                0], // If "No" is selected, use the first doctor from the list
        doctor2: hasDoctor
            ? null
            : selectedDoctors[1], // Second doctor from the list if "No"
        doctor3: hasDoctor
            ? null
            : selectedDoctors[2], // Third doctor from the list if "No"
      );
      print('Successfully added to the waiting list.');
    } catch (error) {
      print('Error adding to the waiting list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: hasDoctor ? 160 : 68),
            const Text(
              'Have You Booked a Doctor?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () =>
                  onAnswer(true), // "Yes" button clears multi-doctor fields
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
                'Yes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  onAnswer(false), // "No" button clears single doctor field
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
                'No',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (answered) ...[
              Text(
                hasDoctor ? 'Choose your doctor:' : 'Choose 3 doctors:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (hasDoctor)
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: TextEditingController(text: selectedDoctor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      hintText: 'Search Doctor',
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return doctors.where(
                      (doctor) =>
                          doctor.toLowerCase().contains(pattern.toLowerCase()),
                    );
                  },
                  itemBuilder: (context, String doctor) {
                    return ListTile(
                      title: Text(doctor),
                    );
                  },
                  onSuggestionSelected: (String doctor) {
                    setState(() {
                      selectedDoctor = doctor;
                    });
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select a doctor';
                    }
                    return null;
                  },
                  onSaved: (value) => selectedDoctor = value,
                )
              else
                Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TypeAheadFormField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: TextEditingController(
                              text: selectedDoctors[index]),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: 'Search Doctor',
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return getAvailableDoctors(index).where(
                            (doctor) => doctor
                                .toLowerCase()
                                .contains(pattern.toLowerCase()),
                          );
                        },
                        itemBuilder: (context, String doctor) {
                          return ListTile(
                            title: Text(doctor),
                          );
                        },
                        onSuggestionSelected: (String doctor) {
                          setState(() {
                            selectedDoctors[index] = doctor;
                          });
                        },
                        transitionBuilder:
                            (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please select a doctor';
                          }
                          return null;
                        },
                        onSaved: (value) => selectedDoctors[index] = value,
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 40),
            Row(
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
                const Spacer(),
                if ((hasDoctor && selectedDoctor != null) ||
                    (!hasDoctor &&
                        selectedDoctors
                                .where((doctor) => doctor != null)
                                .length ==
                            3))
                  ElevatedButton(
                    onPressed: () {
                      _sendProjectToWaitingList(); // Trigger adding to waiting list
                      widget.onNext();
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
    );
  }
}

class FourthPage extends StatefulWidget {
  final VoidCallback onPrevious;

  const FourthPage({required this.onPrevious, super.key});

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  bool _isLoading = false;
  String? _status;
  String? _token;
  Timer? _statusCheckTimer; // Timer for polling the status

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchStatus(); // Load token and fetch student's status
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  // Function to retrieve the JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  // Load the token first, then fetch the student's current status
  Future<void> _loadTokenAndFetchStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await getToken(); // Retrieve token from SharedPreferences
      if (_token == null) {
        throw Exception('JWT token not found');
      }
      await _fetchStudentStatus(); // Fetch the student's status
      _startStatusPolling(); // Start polling for status changes
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Polling for status every 10 seconds
  void _startStatusPolling() {
    _statusCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkStatus();
    });
  }

  // Function to check if the student's status has changed to "completed"
  Future<void> _checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.2:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String newStatus = data['Status'];

        if (newStatus == 'completed') {
          _statusCheckTimer?.cancel(); // Stop polling
          _navigateToFifthPage(); // Navigate to FifthPage
        }
      } else {
        print('Failed to check status');
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  // Navigate to FifthPage
  void _navigateToFifthPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => FifthPage()), // Replace with FifthPage
    );
  }

  // Fetch the student's current status
  Future<void> _fetchStudentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.2:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _status = data['Status'];

        // If status is "waiting", stay on this page and start polling
        if (_status == 'waiting') {
          _startStatusPolling(); // Start polling if still waiting
        }
      } else {
        print('Failed to fetch student status');
      }
    } catch (e) {
      print('Error fetching student status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Wait for approval from your doctor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    _logout(context); // Call the logout function
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Logout button styled in red
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logout functionality
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SignInScreen()), // Assuming SignInScreen exists
    );
  }
}

class FifthPage extends StatefulWidget {
  final bool isStandalone;

  const FifthPage({this.isStandalone = false, super.key});

  @override
  _FifthPageState createState() => _FifthPageState();
}

class _FifthPageState extends State<FifthPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isDisabled = false; // To disable fields if status is 'waitapprove'
  String? _status;
  String? _token;
  Timer? _approvalTimer; // Timer for polling the status

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchStudentStatus(); // Load token and fetch student's status
  }

  @override
  void dispose() {
    _approvalTimer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  // Function to retrieve the JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  // Load the token first, then fetch the student's current status
  Future<void> _loadTokenAndFetchStudentStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await getToken(); // Retrieve token from SharedPreferences
      if (_token == null) {
        throw Exception('JWT token not found');
      }
      await _fetchStudentStatus(); // Fetch the student's status
      _startApprovalPolling(); // Start polling for approval
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Polling for approval status every 10 seconds
  void _startApprovalPolling() {
    _approvalTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkApprovalStatus();
    });
  }

  // Function to check if the student's status has changed to "approved"
  Future<void> _checkApprovalStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.2:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String newStatus = data['Status'];

        if (newStatus == 'approved') {
          _approvalTimer?.cancel(); // Stop polling
          _navigateToNextPage(); // Navigate to next page
        }
      } else {
        print('Failed to check approval status');
      }
    } catch (e) {
      print('Error checking approval status: $e');
    }
  }

  // Navigate to the next page
  void _navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => StudentPage()), // Replace with the next page
    );
  }

  // Fetch the student's current status and waiting list details
  Future<void> _fetchStudentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.2:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _status = data['Status'];

        if (_status == 'waitapprove') {
          // Fetch the current project details
          await _fetchWaitingListDetails();
          _isDisabled = true; // Disable fields if status is 'waitapprove'
          setState(() {
            _isSubmitted =
                true; // Show loading circle with message "Wait for approval..."
          });
        }
      } else {
        print('Failed to fetch student status');
      }
    } catch (e) {
      print('Error fetching student status: $e');
    }
  }

  // Fetch the title and description from the waiting list
  Future<void> _fetchWaitingListDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.2:3000/GP/v1/projects/WaitingList/getCurrent'),
        headers: {
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final waitingList = data['data']
            ['waitingList']; // Accessing the correct nested structure
        _titleController.text = waitingList['ProjectTitle'] ?? '';
        _descriptionController.text = waitingList['ProjectDescription'] ?? '';
      } else {
        print('Failed to fetch waiting list details');
      }
    } catch (e) {
      print('Error fetching waiting list details: $e');
    }
  }

  // Submit the project details (PATCH request)
  Future<void> _submitProject() async {
    setState(() {
      _isLoading = true;
      _isSubmitted = true; // Disable fields immediately after submit is pressed
      _isDisabled = true; // Disable the fields directly
    });

    final Map<String, String> body = {
      'Title': _titleController.text,
      'Description': _descriptionController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse(
            'http://192.168.88.2:3000/GP/v1/projects/WaitingList/current'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $_token', // Add the token to the Authorization header
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Project updated successfully');
        setState(() {
          _isLoading = false; // Stop loading after successful submission
        });
      } else {
        print('Failed to update the project: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting project: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 160),
                const Text(
                  'Submit Your Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 70),
                if (_isLoading || _isSubmitted)
                  Column(
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Wait for approval...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                if (!(_isLoading || _isSubmitted)) ...[
                  TextField(
                    controller: _titleController,
                    enabled: !_isDisabled, // Disable if status is waitapprove
                    decoration: InputDecoration(
                      hintText: 'Enter Project Title',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    enabled: !_isDisabled, // Disable if status is waitapprove
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter Project Description',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _isDisabled ? null : _submitProject,
                    icon: const Icon(Icons.send, color: primaryColor),
                    label: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Logout button styled in red
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}
