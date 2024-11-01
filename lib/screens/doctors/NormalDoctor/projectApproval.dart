import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class ProjectApprovalPage extends StatefulWidget {
  @override
  _ProjectApprovalPageState createState() => _ProjectApprovalPageState();
}

class _ProjectApprovalPageState extends State<ProjectApprovalPage> {
  List<Map<String, dynamic>> projectRequests = [];
  int projectCount = 0;

  @override
  void initState() {
    super.initState();
    fetchProjectRequests();
    fetchProjectRequestCount();
  }

  Future<void> fetchProjectRequests() async {
    List<Map<String, dynamic>> requests =
        await ApiService.fetchProjectRequests();
    setState(() {
      projectRequests = requests;
    });
  }

  Future<void> fetchProjectRequestCount() async {
    int count = await ApiService.fetchProjectRequestCount();
    setState(() {
      projectCount = count;
    });
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> approveProject(String studentUser) async {
    final token = await getToken();
    final url = Uri.parse(
        'http://192.168.88.7:3000/GP/v1/projects/WaitingList/project/approve');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Username': studentUser,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful approval response
        fetchProjectRequests(); // Refresh project requests
        fetchProjectRequestCount();
      } else {
        // Handle error response
        print('Failed to approve project: ${response.statusCode}');
      }
    } catch (error) {
      print('Error approving project: $error');
    }
  }

  Future<void> declineProject(String studentUser) async {
    final token = await getToken();
    final url = Uri.parse(
        'http://192.168.88.7:3000/GP/v1/projects/WaitingList/project/decline');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Username': studentUser,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful decline response
        fetchProjectRequests(); // Refresh project requests
        fetchProjectRequestCount();
      } else {
        // Handle error response
        print('Failed to decline project: ${response.statusCode}');
      }
    } catch (error) {
      print('Error declining project: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Project Approval Requests ($projectCount)',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: projectRequests.length,
          itemBuilder: (context, index) {
            final request = projectRequests[index];
            return _buildRequestCard(
              student1: request['student1']!,
              student2: request['student2']!,
              title: request['title']!,
              description: request['description']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String student1,
    required String student2,
    required String title,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student: $student1',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Partner: $student2',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => approveProject(student1),
                  icon: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
                IconButton(
                  onPressed: () => declineProject(student1),
                  icon: Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
