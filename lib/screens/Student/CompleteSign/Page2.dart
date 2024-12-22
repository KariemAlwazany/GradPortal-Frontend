import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Student/CompleteSign/Page3.dart';
import 'package:flutter_project/screens/Student/CompleteSign/matching.dart';
import 'package:flutter_project/screens/Student/CompleteSign/partner_request.dart';
import 'package:flutter_project/screens/Student/CompleteSign/send_message.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// Import the new MatchingPage

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

  // New fields for additional information
  String? age;
  String? gender;
  String? projectType;
  String? preferredFEFramework;
  String? preferredBEFramework;
  String? database;

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
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/students/getCurrentStudent'),
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
            '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/getCurrent'),
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
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/approve'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/decline';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectStepper(
              initialStep: 3,
              partnerUsername: partnerRequesting,
            ),
          ),
        );
      } else {
        setState(() {
          isWaitingForApproval = false;
          isLoadingScreen = false;
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
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/students/available'),
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

  // Update the `onAnswer` method to navigate to MatchingPage when "No" is pressed
  void onAnswer(bool hasPartner) {
    setState(() {
      answered = hasPartner;
      selectedPartner = null;
    });

    if (!hasPartner) {
      // Navigate to MatchingPage when "No" is pressed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchingPage(),
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
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList'),
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
      body: Stack(
        children: [
          // Main content of the page
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoadingScreen || isWaitingForApproval
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _declineRequest();
                          },
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text(
                            'Cancle Request',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .orange, // Button color for Decline Request
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 100),
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
                          ElevatedButton.icon(
                            onPressed: () => _logout(context),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (answered) ...[
                            const Text(
                              'Choose your partner:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TypeAheadFormField<String>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: TextEditingController(
                                    text: selectedPartner),
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
            // Positioned message icon at the top-right corner
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                // Add the logic to handle message icon tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendMessagePage(),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 16,
            left: 25,
            child: IconButton(
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
          ),
        ],
      ),
    );
  }

  Future<void> _declineRequest() async {
    try {
      final token = await getToken();
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
          isLoadingScreen = false; // Reset to normal page
          isWaitingForApproval = false;
        });
      } else {
        print('Failed to decline the request');
      }
    } catch (e) {
      print('Error while declining request: $e');
    }
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
