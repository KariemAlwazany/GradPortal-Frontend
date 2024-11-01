import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ViewCurrentProjectsPage extends StatefulWidget {
  @override
  _ViewCurrentProjectsPageState createState() =>
      _ViewCurrentProjectsPageState();
}

class _ViewCurrentProjectsPageState extends State<ViewCurrentProjectsPage> {
  String selectedDoctor = '';
  String selectedProjectType = 'All';

  final List<Map<String, dynamic>> doctorsWithProjects = [
    {
      'doctorName': 'Dr. Raed Alqadi',
      'projects': [
        {
          'title': 'Project A',
          'type': 'Software',
          'description': 'Description of Project A',
          'duration': '6 months'
        },
        {
          'title': 'Project B',
          'type': 'Hardware',
          'description': 'Description of Project B',
          'duration': '3 months'
        },
      ],
    },
    {
      'doctorName': 'Dr. Sarah Johnson',
      'projects': [
        {
          'title': 'Project C',
          'type': 'Hardware',
          'description': 'Description of Project C',
          'duration': '1 year'
        },
        {
          'title': 'Project D',
          'type': 'Software',
          'description': 'Description of Project D',
          'duration': '8 months'
        },
      ],
    },
    {
      'doctorName': 'Dr. Ahmed Ali',
      'projects': [
        {
          'title': 'Project E',
          'type': 'Software',
          'description': 'Description of Project E',
          'duration': '5 months'
        },
        {
          'title': 'Project F',
          'type': 'Hardware',
          'description': 'Description of Project F',
          'duration': '10 months'
        },
      ],
    },
  ];

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
      body: Column(
        children: [
          // Filters Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
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
                Expanded(
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
                            doctor['doctorName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: doctor['projects'].map<Widget>((project) {
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
                                        builder: (context) => ProjectDetailPage(
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
    );
  }
}

// Project Detail Page
class ProjectDetailPage extends StatelessWidget {
  final Map<String, dynamic> project;

  ProjectDetailPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          project['title'],
          style: TextStyle(color: Colors.white),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Title: ${project['title']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Project Type: ${project['type']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${project['duration']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              project['description'],
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
