import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For storing/retrieving JWT token

class ProjectsListViewPage extends StatefulWidget {
  @override
  _ProjectsListViewPageState createState() => _ProjectsListViewPageState();
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}

class _ProjectsListViewPageState extends State<ProjectsListViewPage> {
  late Future<List<Project>> _projectsFuture; // Future to store project data
  late Future<List<Project>>
      _favoritesFuture; // Future to store favorite projects
  List<Project> _projects = []; // Store all projects
  List<Project> _filteredProjects = []; // Filtered projects list
  List<Project> _favoriteProjects = []; // Store favorite projects
  String _searchQuery = ''; // Track search query
  String _selectedFilter = 'Title'; // Track selected filter
  bool _isSearchBarVisible = false; // Toggle search bar visibility

  @override
  void initState() {
    super.initState();
    _projectsFuture = fetchProjects();
    _favoritesFuture = fetchFavoriteProjects(); // Fetch favorites at init
  }

  // Fetch all projects
  Future<List<Project>> fetchProjects() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('http://192.168.88.6:3000/GP/v1/projects'),
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
        _filteredProjects = projects;
      });
      return projects;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<List<Project>> fetchFavoriteProjects() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('http://192.168.88.6:3000/GP/v1/projects/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include JWT token in the headers
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> favProjectsData = jsonResponse['data']['favProjects'];

      List<Project> favorites = favProjectsData.map((favProject) {
        return Project.fromJson(favProject['graduationProject']);
      }).toList();

      setState(() {
        _favoriteProjects = favorites;
      });
      return favorites;
    } else {
      throw Exception('Failed to load favorite projects');
    }
  }

  // Filter projects based on search and filter criteria
  void _filterProjects(String query, String filter) {
    setState(() {
      _searchQuery = query;

      // Choose between filtering all projects or favorite projects
      List<Project> projectsToFilter =
          (filter == 'Favorites') ? _favoriteProjects : _projects;

      _filteredProjects = projectsToFilter.where((project) {
        final matchesTitle = project.title
            .toLowerCase()
            .contains(query.toLowerCase()); // Filter by title
        final matchesFilter = (() {
          switch (filter) {
            case 'Year':
              return project.year.toString().contains(query);
            case 'Project Type':
              return project.projectType
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Supervisor':
              return project.supervisor
                  .toLowerCase()
                  .contains(query.toLowerCase());
            case 'Title':
              return project.title.toLowerCase().contains(query.toLowerCase());
            case 'Favorites':
              return _favoriteProjects
                  .contains(project); // Check if the project is in favorites
            default:
              return false;
          }
        })();

        return matchesTitle || matchesFilter; // Match title or other filters
      }).toList();

      // Reset filtered projects if query is empty
      if (query.isEmpty) {
        _filteredProjects = projectsToFilter;
      }
    });
  }

  // Toggle the visibility of the search bar
  void _toggleSearchBar() {
    setState(() {
      _isSearchBarVisible =
          !_isSearchBarVisible; // Toggle search bar visibility
    });
  }

  // Toggle a project as favorite or unfavorite
  Future<void> _toggleFavorite(Project project) async {
    final token = await getToken();
    bool isFavorite =
        _favoriteProjects.any((favProject) => favProject.gpId == project.gpId);

    if (isFavorite) {
      // Unfavorite the project (delete from favorites table)
      final response = await http.delete(
        Uri.parse(
            'http://192.168.88.6:3000/GP/v1/projects/favorites/${project.gpId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        setState(() {
          _favoriteProjects.removeWhere((favProject) =>
              favProject.gpId == project.gpId); // Remove from favorite list
        });
      } else {
        throw Exception('Failed to remove from favorites');
      }
    } else {
      // Favorite the project (insert into favorites table)
      final response = await http.post(
        Uri.parse('http://192.168.88.6:3000/GP/v1/projects/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': project.gpId, // Use GP_ID as the unique project ID
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _favoriteProjects.add(project); // Add to favorite list
        });
      } else {
        throw Exception('Failed to add to favorites');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (_isSearchBarVisible) // Search bar and filter section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Styled Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Projects...',
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.blueGrey),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onChanged: (value) {
                            _filterProjects(value, _selectedFilter);
                          },
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Styled Dropdown Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          items: [
                            'Title',
                            'Project Type',
                            'Supervisor',
                            'Year',
                            'Favorites'
                          ].map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(filter),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newFilter) {
                            if (newFilter != null) {
                              _filterProjects(_searchQuery, newFilter);
                              setState(() {
                                _selectedFilter = newFilter;
                              });
                            }
                          },
                          isExpanded: true,
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: FutureBuilder<List<Project>>(
                  future: _selectedFilter == 'Favorites'
                      ? _favoritesFuture
                      : _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.black)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No projects found',
                              style: TextStyle(color: Colors.black)));
                    }

                    return ListView.builder(
                      itemCount: _filteredProjects.length,
                      itemBuilder: (context, index) {
                        Project project = _filteredProjects[index];

                        // Check if the current project is in the favorites list
                        bool isFavorite = _favoriteProjects
                            .any((favorite) => favorite.gpId == project.gpId);

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SecondPage(
                                heroTag: index,
                              ),
                            ));
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
                                          'https://via.placeholder.com/200',
                                      width: 200,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.network(
                                            'https://via.placeholder.com/200',
                                            width: 200);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                                color: const Color(0xFF17203A)),
                                      ),
                                      Text(
                                        project.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                      Text('Year: ${project.year}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      Text(
                                          'Project Type: ${project.projectType}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      Text('Supervisor: ${project.supervisor}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ),
                                // Display the heart icon here, red if favorite, otherwise outlined
                                IconButton(
                                  icon: Icon(isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border),
                                  color: isFavorite ? Colors.red : null,
                                  onPressed: () => _toggleFavorite(
                                      project), // Toggle favorite status
                                ),
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
          ),
          // Fixed floating search button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF3B4280),
              onPressed: _toggleSearchBar, // Toggle search bar visibility
              child: const Icon(Icons.search, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final int heroTag;

  const SecondPage({
    Key? key,
    required this.heroTag,
  }) : super(key: key);

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
  final int gpId; // Ensure this is an integer for GP_ID
  final String title;
  final String description;
  final String? imageUrl; // Nullable
  final String projectType;
  final int year;
  final String supervisor;

  Project({
    required this.gpId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.projectType,
    required this.year,
    required this.supervisor,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      gpId: json['GP_ID'], // Ensure correct type for gpId (integer)
      title: json['GP_Title'], // Check your API response keys
      description: json['GP_Description'], // Check your API response keys
      imageUrl: json['imageUrl'], // Nullable field
      projectType: json['GP_Type'] ?? 'Unknown', // Default value if null
      year: json['year'] ?? 0, // Default to 0 if not provided
      supervisor: json['Supervisor_1'] ?? 'Unknown', // Default value if null
    );
  }
}
