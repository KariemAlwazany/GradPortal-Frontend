// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/api_service.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meetingApproval.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/projectApproval.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/studentApproval.dart';

const Color primaryColor = Color(0xFF3B4280);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: RequestsDashboardPage(),
    );
  }
}

// Main Requests Dashboard Page
class RequestsDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Requests Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            FutureBuilder<int>(
              future: ApiService.fetchStudentRequestCount(),
              builder: (context, snapshot) {
                int requestCount = snapshot.data ?? 0;
                return _buildRequestCard(
                  context,
                  icon: Icons.person_add,
                  title: 'Student Approval Requests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentApprovalPage(),
                    ),
                  ),
                  requestCount: requestCount,
                );
              },
            ),
            _buildRequestCard(
              context,
              icon: Icons.assignment,
              title: 'Project Approval Requests',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectApprovalPage(),
                ),
              ),
              requestCount: 2,
            ),
            _buildRequestCard(
              context,
              icon: Icons.video_call,
              title: 'Meeting Approval Requests',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeetingApprovalPage(),
                ),
              ),
              requestCount: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Function onTap,
      required int requestCount}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (requestCount > 0)
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$requestCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
