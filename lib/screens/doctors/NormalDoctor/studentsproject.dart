import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class StudentsProjectsPage extends StatefulWidget {
  @override
  _StudentsProjectsPageState createState() => _StudentsProjectsPageState();
}

class _StudentsProjectsPageState extends State<StudentsProjectsPage> {
  String selectedTab = 'All';
  List<Map<String, dynamic>> allProjects = [];
  List<Map<String, dynamic>> hardwareProjects = [];
  List<Map<String, dynamic>> softwareProjects = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchProjects() async {
    final token = await getToken();
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/doctors/students';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final projects = data['data']['allStudents'];

      setState(() {
        for (var project in projects) {
          final projectData = {
            'GP_Title': project['GP_Title'],
            'GP_Type': project['GP_Type'],
            'GP_Description': project['GP_Description'],
            'Supervisor_1': project['Supervisor_1'],
            'Supervisor_2': project['Supervisor_2'],
            'Student1': project['Student1'],
            'Student2': project['Student2'],
          };

          allProjects.add(projectData);

          if (project['GP_Type'] == 'Hardware') {
            hardwareProjects.add(projectData);
          } else if (project['GP_Type'] == 'Software') {
            softwareProjects.add(projectData);
          }
        }
      });
    }
  }

  void _navigateToProjectDetails(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsPage(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Students & Projects', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('All', selectedTab == 'All', () {
                  setState(() {
                    selectedTab = 'All';
                  });
                }),
                _buildTabButton('Hardware', selectedTab == 'Hardware', () {
                  setState(() {
                    selectedTab = 'Hardware';
                  });
                }),
                _buildTabButton('Software', selectedTab == 'Software', () {
                  setState(() {
                    selectedTab = 'Software';
                  });
                }),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: selectedTab == 'All'
                    ? allProjects.length
                    : selectedTab == 'Hardware'
                        ? hardwareProjects.length
                        : softwareProjects.length,
                itemBuilder: (context, index) {
                  final project = selectedTab == 'All'
                      ? allProjects[index]
                      : selectedTab == 'Hardware'
                          ? hardwareProjects[index]
                          : softwareProjects[index];
                  return GestureDetector(
                    onTap: () => _navigateToProjectDetails(project),
                    child: _buildProjectCard(
                      title: project['GP_Title'] ?? 'No Title',
                      students: [
                        project['Student1']?['Username'] ?? 'N/A',
                        project['Student2']?['Username'] ?? 'N/A'
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String title,
    required List<String> students,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Students:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: students.map((student) => Text(student)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final Map<String, dynamic> project;

  ProjectDetailsPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          project['GP_Title'] ?? 'Project Details', // Null-safe title
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and GP Type
            Text(
              project['GP_Title'] ?? 'No Title',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Type: ${project['GP_Type'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[300]),

            // Project Description
            _buildSectionTitle('Description'),
            Text(
              project['GP_Description'] ?? 'No Description',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[300]),

            // Supervisors Section
            _buildSectionTitle('Supervisors'),
            if (project['Supervisor_1'] != null)
              _buildInfoRow('Supervisor 1:', project['Supervisor_1'] ?? 'N/A'),
            if (project['Supervisor_2'] != null)
              _buildInfoRow('Supervisor 2:', project['Supervisor_2'] ?? 'N/A'),
            SizedBox(height: 24),
            Divider(color: Colors.grey[300]),

            // Students Section with Registration Numbers
            _buildSectionTitle('Students'),
            if (project['Student1'] != null)
              _buildStudentInfo('Student 1', project['Student1']),
            if (project['Student2'] != null)
              _buildStudentInfo('Student 2', project['Student2']),
          ],
        ),
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  // Helper to build information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build student info with registration number
  Widget _buildStudentInfo(String label, Map<String, dynamic> student) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${student['Username'] ?? 'No Username'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Registration Number: ${student['Registration_number'] ?? 'No Registration Number'}',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
