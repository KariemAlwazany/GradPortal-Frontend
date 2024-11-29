import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class ViewCurrentProjectsPage extends StatefulWidget {
  const ViewCurrentProjectsPage({super.key});

  @override
  _ViewCurrentProjectsPageState createState() =>
      _ViewCurrentProjectsPageState();
}

class _ViewCurrentProjectsPageState extends State<ViewCurrentProjectsPage> {
  String selectedDoctor = '';
  String selectedProjectType = 'All';

  List<Map<String, dynamic>> doctorsWithProjects = [];

  @override
  void initState() {
    super.initState();
    fetchProjectsData();
  }

  Future<void> fetchProjectsData() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/projects/current'),
    );

    if (response.statusCode == 200) {
      final List projects = json.decode(response.body);
      setState(() {
        doctorsWithProjects = projects.map((project) {
          return {
            'doctorName': project['Supervisor_1'] ?? 'Unknown',
            'projects': [
              {
                'title': project['GP_Title'],
                'type': project['GP_Type'],
                'description': project['GP_Description'],
                'Student_1': project['Student_1'],
                'Student_2': project['Student_2'],
              }
            ],
          };
        }).toList();
      });
    } else {
      print("Failed to load projects");
    }
  }

  List<Map<String, dynamic>> get filteredDoctorsWithProjects {
    return doctorsWithProjects
        .where((doctor) =>
            selectedDoctor.isEmpty ||
            doctor['doctorName']
                .toLowerCase()
                .contains(selectedDoctor.toLowerCase()))
        .map((doctor) {
          final filteredProjects = doctor['projects'].where((project) {
            final matchesType = selectedProjectType == 'All' ||
                project['type'].toLowerCase() ==
                    selectedProjectType.toLowerCase();
            return matchesType;
          }).toList();

          return {
            'doctorName': doctor['doctorName'],
            'projects': filteredProjects,
          };
        })
        .where((doctor) => doctor['projects'].isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'View Current Projects',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filters Section with overflow fix
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 165, // Fixed width for TextField
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search Doctor',
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedDoctor = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 202, // Fixed width for dropdown
                      child: DropdownButtonFormField<String>(
                        value: selectedProjectType,
                        hint: Text("Select Project Type"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['All', 'Software', 'Hardware']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProjectType = value ?? 'All';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Display Filtered Projects by Doctor
            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctorsWithProjects.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctorsWithProjects[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ' + doctor['doctorName'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children:
                                  doctor['projects'].map<Widget>((project) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    tileColor: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      project['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(project['type']),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProjectDetailPage(
                                            project: project,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Project Detail Page with design enhancements
class ProjectDetailPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          project['title'] ?? 'Project Details',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title
                Text(
                  project['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 16),

                // Project Type
                Text(
                  'Type: ${project['type'] ?? 'Not specified'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Divider(height: 24, thickness: 1.5),

                // Students
                Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Student 1: ${project['Student_1'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Student 2: ${project['Student_2'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Divider(height: 24, thickness: 1.5),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  project['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
