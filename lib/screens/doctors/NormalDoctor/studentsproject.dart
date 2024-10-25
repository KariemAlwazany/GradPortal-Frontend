import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentsProjectsPage extends StatefulWidget {
  @override
  _StudentsProjectsPageState createState() => _StudentsProjectsPageState();
}

class _StudentsProjectsPageState extends State<StudentsProjectsPage> {
  bool isHardwareSelected = true;

  final List<Map<String, dynamic>> hardwareProjects = [
    {
      'title': 'IoT in Smart Cities',
      'students': ['Evan Green', 'Fiona White']
    },
    {
      'title': 'Robotics in Medicine',
      'students': ['George Hall', 'Hannah Black']
    },
  ];

  final List<Map<String, dynamic>> softwareProjects = [
    {
      'title': 'AI Research Project',
      'students': ['John Doe', 'Jane Smith']
    },
    {
      'title': 'Data Science in Healthcare',
      'students': ['Alice Johnson', 'Bob Brown']
    },
    {
      'title': 'Blockchain Technology',
      'students': ['Charlie Davis', 'Diana Prince']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Students & Projects',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous page
          },
        ),
      ),
      body: Column(
        children: [
          // Top Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Hardware', isHardwareSelected, () {
                  setState(() {
                    isHardwareSelected = true;
                  });
                }),
                _buildTabButton('Software', !isHardwareSelected, () {
                  setState(() {
                    isHardwareSelected = false;
                  });
                }),
              ],
            ),
          ),
          // Project List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: isHardwareSelected
                    ? hardwareProjects.length
                    : softwareProjects.length,
                itemBuilder: (context, index) {
                  final project = isHardwareSelected
                      ? hardwareProjects[index]
                      : softwareProjects[index];
                  return _buildProjectCard(
                    title: project['title'],
                    students: project['students'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a single project card
  Widget _buildProjectCard({
    required String title,
    required List<String> students,
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

  // Helper to build each tab button at the top
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
