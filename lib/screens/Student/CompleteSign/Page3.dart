// package:flutter_project/screens/Student/CompleteSign/Page3.dart
// package:flutter_project/screens/Student/CompleteSign/Page3.dart
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page4.dart';
import 'package:flutter_project/screens/Student/CompleteSign/send_message.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';

const Color primaryColor = Color(0xFF3B4280);

class ThirdPage extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String? selectedPartner;

  const ThirdPage({
    required this.onNext,
    required this.onPrevious,
    this.selectedPartner,
    Key? key,
  }) : super(key: key);

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
        selectedDoctors = [null, null, null];
      } else {
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

  void _sendProjectToWaitingList() async {
    final String partner1 =
        'Partner_1_Name'; // Replace this with the actual partner1 value
    String? partner2 =
        widget.selectedPartner; // This will be null if "No" was selected
    String partnerStatus = 'waiting'; // Set partner status based on partner2

    try {
      await addToWaitingList(
        partner1: partner1,
        partner2: partner2, // This will be null if no partner was selected
        projectType: typeGP,
        projectStatus: 'waiting',
        partnerStatus: partnerStatus,
        doctor1: hasDoctor ? selectedDoctor : selectedDoctors[0],
        doctor2: hasDoctor ? null : selectedDoctors[1],
        doctor3: hasDoctor ? null : selectedDoctors[2],
      );
      print('Successfully added to the waiting list.');
    } catch (error) {
      print('Error adding to the waiting list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Main content of the page
          Center(
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
                  SizedBox(
                    height: 16,
                  ),
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
                          controller:
                              TextEditingController(text: selectedDoctor),
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
                            selectedDoctor = doctor;
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
                              onSaved: (value) =>
                                  selectedDoctors[index] = value,
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
                          onPressed: () async {
                            // Add to waiting list and navigate to FourthPage
                            _sendProjectToWaitingList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FourthPage(
                                  onPrevious: widget.onPrevious,
                                ),
                              ),
                            );
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
          // Positioned message icon at the top-right corner
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                // Logic to handle message icon tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendMessagePage(),
                  ),
                );
                // You can open a new screen, show a message dialog, or implement any action
              },
            ),
          ),
          Positioned(
            top: 16,
            left: 25,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
}
