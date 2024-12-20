import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class ProjectTypePage extends StatelessWidget {
  final VoidCallback onNext;

  const ProjectTypePage({required this.onNext, super.key});

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> sendProjectType(String type) async {
    try {
      // Load the token
      final token = await getToken();

      if (token == null) {
        print('Token not found');
        return;
      }

      // Construct the API URL
      final url =
          '${dotenv.env['API_BASE_URL']}/GP/v1/projects/WaitingList/projectSelected';
      print('Sending PATCH request to URL: $url with type: $type');

      // Make the PATCH request
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'ProjectType': type}),
      );

      // Log the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Project type updated successfully');
      } else {
        throw Exception(
            'Failed to update project type. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log errors
      print('Error sending project type: $e');
    }
  }

  void setType(BuildContext context, String type) async {
    await sendProjectType(type); // Send the project type to the API
    onNext(); // Trigger the next action
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 160),
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
              onPressed: () => setType(context, "Software"),
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
              onPressed: () => setType(context, "Hardware"),
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
