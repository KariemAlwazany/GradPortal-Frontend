import 'package:flutter/material.dart';
import 'package:flutter_project/screens/NormalUser/project_screen.dart';
import 'package:flutter_project/screens/Student/meeting/meeting.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            primaryColor, // Set the background color of the app bar
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back arrow
        ),
      ),
      body: ProjectsListViewPage(), // Use the existing ProjectsListViewPage
    );
  }
}
