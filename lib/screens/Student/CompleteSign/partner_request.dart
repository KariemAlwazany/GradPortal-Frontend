import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class PartnerRequestsPage extends StatefulWidget {
  const PartnerRequestsPage({Key? key}) : super(key: key);

  @override
  _PartnerRequestsPageState createState() => _PartnerRequestsPageState();
}

class _PartnerRequestsPageState extends State<PartnerRequestsPage> {
  List<String> partnerRequests = [];
  String? selectedPartnerRequest;
  Map<String, dynamic>? partnerInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final token = await _getToken();
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
            data['data'] != null &&
            data['data']['partnerRequest'] != null) {
          setState(() {
            partnerRequests = [
              data['data']['partnerRequest']['Partner_1']
            ]; // Assuming only one request is present
            isLoading = false;
          });
        } else {
          setState(() {
            partnerRequests = [];
            isLoading = false;
          });
        }
      } else {
        print('Error loading requests: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading partner requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _respondToPartnerRequest(
      String partnerUsername, bool accepted) async {
    final url = accepted
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/approve'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/decline';
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse(url),
        body: json.encode({'Partner_1': partnerUsername}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (accepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partner request accepted')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectStepper(
              initialStep: 3,
              partnerUsername: partnerUsername,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectStepper(
              initialStep: 2,
              partnerUsername: partnerUsername,
            ),
          ),
        );
        setState(() {
          partnerRequests.remove(partnerUsername); // Update the list
          selectedPartnerRequest = null;
        });
      }
    } catch (e) {
      print('Error responding to partner request: $e');
    }
  }

  Future<void> _viewPartnerInfo(String username) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/WaitingPartnerList/getParnterRequestedInfo/$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          partnerInfo = data;
        });
      } else {
        print('Error loading partner info: ${response.statusCode}');
        setState(() {
          partnerInfo = null;
        });
      }
    } catch (e) {
      print('Error loading partner info: $e');
      setState(() {
        partnerInfo = null;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Widget _buildPartnerInfoCard() {
    if (partnerInfo == null) {
      return const Center(
        child: Text(
          'No additional information available.',
          style: TextStyle(fontSize: 16, color: primaryColor),
        ),
      );
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Username: ${partnerInfo!['Username']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.badge, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Registration Number: ${partnerInfo!['Registration_number']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.info, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Status: ${partnerInfo!['Status']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.device_hub, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'GP Type: ${partnerInfo!['GP_Type']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.cake, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Age: ${partnerInfo!['Age']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.male, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Gender: ${partnerInfo!['Gender']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.code, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Backend Framework: ${partnerInfo!['BE']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.web, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Frontend Framework: ${partnerInfo!['FE']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.storage, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Database: ${partnerInfo!['DB']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (partnerInfo!['City'] != null)
              Row(
                children: [
                  const Icon(Icons.location_city, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'City: ${partnerInfo!['City']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _respondToPartnerRequest(partnerInfo!['Username'], false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: primaryColor, width: 1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () =>
                      _respondToPartnerRequest(partnerInfo!['Username'], true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Partner Requests',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : partnerRequests.isEmpty
              ? const Center(
                  child: Text(
                    'No partner requests available.',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select a Partner Request:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButton<String>(
                        value: selectedPartnerRequest,
                        hint: const Text('Select a partner request'),
                        isExpanded: true,
                        items: partnerRequests.map((request) {
                          return DropdownMenuItem<String>(
                            value: request,
                            child: Text(request),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPartnerRequest = value;
                            partnerInfo = null; // Clear previous info
                          });
                          if (value != null) _viewPartnerInfo(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (partnerInfo != null) _buildPartnerInfoCard(),
                    ],
                  ),
                ),
    );
  }
}
