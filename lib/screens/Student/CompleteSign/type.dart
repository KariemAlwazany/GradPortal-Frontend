import 'package:flutter/material.dart';
import 'package:flutter_project/screens/NormalUser/project_screen.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';

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

    return GestureDetector(
      onTap: () {
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

class SecondPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const SecondPage({required this.onNext, required this.onPrevious, super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool hasMate = false;
  bool answered = false;
  String? selectedStudent;

  // List of students for the dropdown
  final List<String> students = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];

  void onAnswer(bool mateStatus) {
    setState(() {
      hasMate = mateStatus;
      answered = true;
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
              onPressed: () => onAnswer(true),
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
              onPressed: () => onAnswer(false),
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
                hasMate
                    ? 'Choose your Partner:'
                    : 'Choose one from the available students:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedStudent,
                hint: const Text('Select Student'),
                onChanged: (value) {
                  setState(() {
                    selectedStudent = value;
                  });
                },
                items: [
                  ...students.map((student) {
                    return DropdownMenuItem(
                      value: student,
                      child: Text(student),
                    );
                  }).toList(),
                  if (!hasMate)
                    const DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
                    shape: const CircleBorder(), backgroundColor: primaryColor,
                    padding: const EdgeInsets.all(
                        20), // Assuming primaryColor is blue
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
                if (selectedStudent != null)
                  ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.all(
                          20), // Assuming primaryColor is blue
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
  bool hasBookedDoctor = true;
  bool answered = false;
  String? selectedDoctor;
  List<String?> selectedDoctors = [null, null, null]; // For the 3 doctor lists

  // List of doctors for the dropdown
  final List<String> doctors = [
    'Dr. Smith',
    'Dr. Johnson',
    'Dr. Clark',
    'Dr. Taylor',
    'Dr. Lee'
  ];

  void onAnswer(bool booked) {
    setState(() {
      hasBookedDoctor = booked;
      answered = true;
    });
  }

  List<String> getAvailableDoctors(int currentDropdownIndex) {
    // Get the currently selected doctors from other dropdowns, excluding the current one
    Set<String> selected = selectedDoctors
        .where((doctor) =>
            doctor != null && doctor != selectedDoctors[currentDropdownIndex])
        .cast<String>()
        .toSet();

    // Filter out selected doctors from the list
    return doctors.where((doctor) => !selected.contains(doctor)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic SizedBox height based on selection
            SizedBox(height: hasBookedDoctor ? 160 : 68),
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
              onPressed: () => onAnswer(true),
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
              onPressed: () => onAnswer(false),
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
                hasBookedDoctor ? 'Choose your doctor:' : 'Choose 3 doctors:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (hasBookedDoctor)
                // Single Doctor Dropdown when "Yes" is selected
                DropdownButtonFormField<String>(
                  value: selectedDoctor,
                  hint: const Text('Select Doctor'),
                  onChanged: (value) {
                    setState(() {
                      selectedDoctor = value;
                    });
                  },
                  items: doctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text(doctor),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              else
                // Three Doctor Dropdowns when "No" is selected
                Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedDoctors[index],
                        hint: const Text('Select Doctor'),
                        onChanged: (value) {
                          setState(() {
                            selectedDoctors[index] = value;
                          });
                        },
                        items: getAvailableDoctors(index).map((doctor) {
                          return DropdownMenuItem(
                            value: doctor,
                            child: Text(doctor),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    );
                  }),
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
                // Next Button on the Right (only visible if a doctor or 3 doctors are selected)
                if ((hasBookedDoctor && selectedDoctor != null) ||
                    (!hasBookedDoctor &&
                        selectedDoctors
                                .where((doctor) => doctor != null)
                                .length ==
                            3))
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

class FourthPage extends StatelessWidget {
  final VoidCallback onPrevious;

  const FourthPage({
    required this.onPrevious,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            // Enhanced Logout Button with an icon
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
            // Previous Button with an arrow back icon
            ElevatedButton(
              onPressed: onPrevious,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white, // Styled as a regular button
                padding: const EdgeInsets.all(20),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logout function
  void _logout(BuildContext context) {
    // Clear user data or perform other logout operations here, if necessary

    // Forward to LoginPage (replace the current page)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}

// Define your LoginPage here
