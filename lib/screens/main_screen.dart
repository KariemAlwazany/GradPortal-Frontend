import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For storing/retrieving JWT token

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Track the current index for the BottomNav

  // Define the pages corresponding to each BottomNav item
  final List<Widget> _pages = [
    ProjectsListViewPage(), // Projects List page
    Center(child: Text('Favorites Page')), // Placeholder for another page
    Center(child: Text('Settings Page')), // Placeholder for another page
    Center(child: Text('Profile Page')), // Placeholder for another page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects ListView"),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Text(
              'Side Menu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex], // Show the current page based on index

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected icon
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        type: BottomNavigationBarType.fixed, // Ensures all icons are shown
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProjectsListViewPage extends StatefulWidget {
  @override
  _ProjectsListViewPageState createState() => _ProjectsListViewPageState();
}

class _ProjectsListViewPageState extends State<ProjectsListViewPage> {
  late Future<List<Project>> _projectsFuture; // Future to store project data

  @override
  void initState() {
    super.initState();
    _projectsFuture = fetchProjects(); // Fetch projects on page load
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  Future<List<Project>> fetchProjects() async {
    final token = await getToken(); // Get the JWT token

    final response = await http.get(
      Uri.parse('http://192.168.88.7:3000/GP/v1/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include JWT token in the headers
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((project) => Project.fromJson(project)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Show error message
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No projects found')); // No data found
        }

        // Display the list of projects
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Project project = snapshot.data![index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SecondPage(heroTag: index)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Hero(
                      tag: index,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          project.imageUrl ??
                              'https://via.placeholder.com/200', // Use default image if null
                          width: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://via.placeholder.com/200', // Fallback image if loading fails
                              width: 200,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title, // Display project title
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          project.description, // Display project description
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SecondPage extends StatelessWidget {
  final int heroTag;

  const SecondPage({Key? key, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                      'https://example.com/project-image'), // Placeholder image
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Project content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          )
        ],
      ),
    );
  }
}

// Project model to map JSON data
class Project {
  final String title;
  final String description;
  final String? imageUrl; // Image URL is nullable

  Project({required this.title, required this.description, this.imageUrl});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['GP_Title'],
      description: json['GP_Description'],
      imageUrl: json['imageUrl'], // imageUrl can be null
    );
  }
}
