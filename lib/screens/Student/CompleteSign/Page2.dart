// package:flutter_project/screens/Student/CompleteSign/Page2.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class SecondPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const SecondPage({required this.onNext, required this.onPrevious, Key? key})
      : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool isLoadingScreen = true;
  bool isWaitingForApproval = false;
  bool answered = false;
  bool hasRequest = false;
  String? partnerRequesting;
  List<String> students = [];
  String? selectedPartner;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialStatus();
      _checkForPartnerRequest();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Future<void> _checkInitialStatus() async {
    try {
      setState(() {
        isLoadingScreen = false;
      });
      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://192.168.88.7:3000/GP/v1/students/getCurrentStudent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Status'] == 'start') {
          setState(() {
            isLoadingScreen = false;
          });
          _loadStudents();
        } else if (data['Status'] == 'waitpartner') {
          setState(() {
            isLoadingScreen = true;
            isWaitingForApproval = true;
          });
          _checkForPartnerRequest();
        }
      } else {
        print('Failed to retrieve initial status.');
      }
    } catch (e) {
      print('Error checking initial status: $e');
    }
  }

  Future<void> _checkForPartnerRequest() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.7:3000/GP/v1/WaitingPartnerList/getCurrent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' &&
            data['data']['partnerRequest'] != null) {
          setState(() {
            hasRequest = true;
            partnerRequesting = data['data']['partnerRequest']['Partner_1'];
          });
          _showPartnerRequestDialog(partnerRequesting!);
        }
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching partner request: $e');
    }
  }

  void _showPartnerRequestDialog(String partnerUsername) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Partner Request'),
          content: Text('$partnerUsername wants to be your partner.'),
          actions: [
            TextButton(
              onPressed: () {
                // Pass the partnerUsername to the accept function
                _respondToPartnerRequest(partnerUsername, true);
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                _respondToPartnerRequest(partnerUsername, false);
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _respondToPartnerRequest(
      String partnerUsername, bool accepted) async {
    final url = accepted
        ? 'http://192.168.88.7:3000/GP/v1/WaitingPartnerList/approve'
        : 'http://192.168.88.7:3000/GP/v1/WaitingPartnerList/decline';
    try {
      final token = await getToken();
      await http.post(
        Uri.parse(url),
        body: json.encode({'Partner_1': partnerUsername}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (accepted) {
        // Navigate to ProjectStepper with the partner's username directly after approval
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectStepper(
              initialStep: 2,
              partnerUsername:
                  partnerRequesting, // Pass the partner's username shown in the dialog
            ),
          ),
        );
      } else {
        // Stay on SecondPage; update any state if needed
        setState(() {
          isLoadingScreen = false;
          hasRequest = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You declined the partner request.')),
        );
      }
    } catch (e) {
      print('Error responding to partner request: $e');
    }
  }

  Future<void> _loadStudents() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://192.168.88.7:3000/GP/v1/students'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          students =
              data.map((student) => student['Username'] as String).toList();
        });
      } else {
        print('Failed to load students');
      }
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  void onAnswer(bool hasPartner) {
    setState(() {
      answered = hasPartner;
      selectedPartner = null;
    });

    // If "No" is selected, directly navigate to ProjectStepper
    if (!hasPartner) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectStepper(
            initialStep: 2,
            partnerUsername: null,
          ),
        ),
      );
    }
  }

  void onNext() async {
    if (selectedPartner == null) {
      print('No partner selected');
      return;
    }
    setState(() {
      isWaitingForApproval = true;
    });
    try {
      final token = await getToken();
      await http.post(
        Uri.parse('http://192.168.88.7:3000/GP/v1/WaitingPartnerList'),
        body: json.encode({'Partner_2': selectedPartner}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _startStatusPolling();
    } catch (e) {
      print('Error sending partner selection: $e');
    }
  }

  void _startStatusPolling() {
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final token = await getToken();
        final response = await http.get(
          Uri.parse(
              'http://192.168.88.7:3000/GP/v1/students/getCurrentStudent'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Status'] == 'approvedpartner') {
            timer.cancel();
            // Navigate to ProjectStepper with the partner username when approved
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectStepper(
                  initialStep: 2,
                  partnerUsername: selectedPartner, // Pass the selected partner
                ),
              ),
            );
          } else if (data['Status'] == 'declinedpartner') {
            timer.cancel();
            setState(() {
              isWaitingForApproval = false;
              isLoadingScreen = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Your partner request was declined. Please choose a new partner.')),
            );
          }
        }
      } catch (e) {
        print('Error checking status: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoadingScreen || isWaitingForApproval
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Waiting for partner approval...',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
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
                        backgroundColor:
                            Colors.red, // Red background to match SecondPage
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded shape
                        ),
                        elevation: 10,
                        shadowColor:
                            Colors.black.withOpacity(0.3), // Shadow effect
                      ),
                    ),
                  ],
                )
              : Padding(
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
                        const Text(
                          'Choose one from the available students:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TypeAheadFormField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller:
                                TextEditingController(text: selectedPartner),
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
                            return students.where(
                              (student) => student
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()),
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
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
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
                          if (selectedPartner != null)
                            ElevatedButton(
                              onPressed: onNext,
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
      ),
    );
  }
}

void _logout(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
}
