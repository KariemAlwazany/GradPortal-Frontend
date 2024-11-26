import 'package:flutter/material.dart';
import 'package:flutter_project/components/MenuSideBar/side_bar_menu.dart';
import 'package:flutter_project/screens/NormalUser/project_screen.dart';
// Import your extracted projects_screen.dart here
import 'profile_screen.dart'; // Import your UpdateProfileScreen here

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Track the current index for the BottomNav
  String _appBarTitle = "Projects"; // Initial AppBar title

  final List<Widget> _pages = [
    ProjectsListViewPage(), // Call the ProjectsListViewPage class from projects_screen.dart
    Center(
        child: Text(
            'Store Page')), // Placeholder for Store page // Placeholder for another page
    Center(child: UpdateProfileScreen()), // Navigate to UpdateProfileScreen
  ];

  void _updateTitle(String newTitle) {
    setState(() {
      _appBarTitle = newTitle; // Update the AppBar title
    });
  }

  void _updatePage(int index, String newTitle) {
    setState(() {
      _currentIndex = index;
      _appBarTitle = newTitle;
    });
    Navigator.of(context).pop(); // Close the drawer after navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B4280), // Blue as primary color
        title: Text(_appBarTitle, style: TextStyle(color: Colors.white)),
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
      drawer: SideMenu(onMenuItemClicked: _updatePage), // Pass callback here
      body: Container(
        color: Colors.white, // White background for the body
        child: _pages[_currentIndex], // Show the current page based on index
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF3B4280), // Blue background
        currentIndex: _currentIndex, // Highlight the selected icon
        selectedItemColor: Colors.white, // White for selected items
        unselectedItemColor:
            Colors.white70, // White with some transparency for unselected items
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            // Update the app bar title based on the selected index
            switch (index) {
              case 0:
                _appBarTitle = "Projects";
                break;

              case 1:
                _appBarTitle = "Store";
                break;
              case 2:
                _appBarTitle = "Profile"; // Set title for Profile tab
                break;
            }
          });
        },
        type: BottomNavigationBarType.fixed, // Ensures all icons are shown
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
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
