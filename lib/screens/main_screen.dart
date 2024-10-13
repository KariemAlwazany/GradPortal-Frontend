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
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Blue as primary color
        title: const Text("Projects ListView",
            style: TextStyle(color: Colors.white)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white), // White icon
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Container(
          color: Theme.of(context).colorScheme.primary, // Blue background
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary, // Blue header
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text(
                  'Profile',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Navigate to the Profile page
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.white),
                title: Text(
                  'Favorites',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Navigate to the Favorites page
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Navigate to the Settings page
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Handle logout action
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
        child: _pages[_currentIndex], // Show the current page based on index
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Blue background
        currentIndex: _currentIndex, // Highlight the selected icon
        selectedItemColor: Colors.white, // White for selected items
        unselectedItemColor:
            Colors.white70, // White with some transparency for unselected items
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
  List<Project> _projects = []; // Store all projects
  List<Project> _filteredProjects = []; // Filtered projects list
  String _searchQuery = ''; // Track search query
  String _selectedFilter = 'All'; // Track selected filter
  bool _isSearchBarVisible = false; // Toggle search bar visibility

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
      Uri.parse('http://192.168.88.5:3000/GP/v1/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include JWT token in the headers
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Project> projects =
          jsonResponse.map((project) => Project.fromJson(project)).toList();
      setState(() {
        _projects = projects;
        _filteredProjects = projects; // Show all projects initially
      });
      return projects;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  void _filterProjects(String query, String filter) {
    setState(() {
      _searchQuery = query;

      _filteredProjects = _projects
          .where((project) =>
              project.title.toLowerCase().contains(query.toLowerCase()) &&
              (filter == 'All' || project.category == filter))
          .toList();

      // If search is cleared, show all projects
      if (query.isEmpty) {
        _filteredProjects = _projects;
      }
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchBarVisible =
          !_isSearchBarVisible; // Toggle search bar visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Icon to toggle search bar
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.blue),
            onPressed: _toggleSearchBar,
          ),
        ),
        // Search Bar (conditionally visible)
        if (_isSearchBarVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Projects...',
                filled: true,
                fillColor: Colors.grey[200], // Light grey background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Remove border lines
                ),
                prefixIcon: Icon(Icons.search,
                    color: Colors.blueGrey), // Change icon color
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0), // Adjust padding for better look
              ),
              onChanged: (value) {
                _filterProjects(value, _selectedFilter);
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _selectedFilter,
            items: ['All', 'Category1', 'Category2', 'Category3'].map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            onChanged: (String? newFilter) {
              if (newFilter != null) {
                _filterProjects(_searchQuery, newFilter);
              }
            },
            isExpanded: true,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Project>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context)
                            .colorScheme
                            .primary)); // Blue spinner
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style:
                            TextStyle(color: Colors.black))); // Error message
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No projects found',
                        style:
                            TextStyle(color: Colors.black))); // No data message
              }

              // Display the list of filtered projects
              return ListView.builder(
                itemCount: _filteredProjects.length,
                itemBuilder: (context, index) {
                  Project project = _filteredProjects[index];
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary), // Blue for text
                              ),
                              Text(
                                project
                                    .description, // Display project description
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors
                                            .black54), // Black for description
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
          ),
        ),
      ],
    );
  }
}

class SecondPage extends StatelessWidget {
  final int heroTag;

  const SecondPage({Key? key, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Blue as the app bar color
        title: const Text("Project Details"),
      ),
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.primary), // Blue for text
            ),
          )
        ],
      ),
    );
  }
}

class Project {
  final String title;
  final String description;
  final String? imageUrl; // Image URL is nullable
  final String category; // Added a category for filtering

  Project(
      {required this.title,
      required this.description,
      this.imageUrl,
      required this.category});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['GP_Title'],
      description: json['GP_Description'],
      imageUrl: json['imageUrl'], // imageUrl can be null
      category:
          json['category'] ?? 'All', // Set a default category if not provided
    );
  }
}
