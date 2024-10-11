import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Track the current index for the BottomNav

  // Define the pages corresponding to each BottomNav item
  final List<Widget> _pages = [
    ProjectsListViewPage(), // Existing page
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

// The main ListView page for Projects
class ProjectsListViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView.builder(
          itemCount: _images.length,
          itemBuilder: (BuildContext context, int index) {
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
                          _images[index],
                          width: 200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      'Title: $index',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// SecondPage for displaying project details
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
                  child: Image.network(_images[heroTag]),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          )
        ],
      ),
    );
  }
}

// Sample images list for testing
final List<String> _images = [
  'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  'https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/273935/pexels-photo-273935.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/1591373/pexels-photo-1591373.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/462024/pexels-photo-462024.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
];
