import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/Requests.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/discussionTable.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/profile.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/studentsproject.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/timeline.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/viewfiles.dart';

const Color primaryColor = Color(0xFF3B4280);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorPage',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: DoctorPage(),
    );
  }
}

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  int _selectedIndex = 0;
  int _notificationCount = 3; // Example notification count

  final List<Widget> _pages = [
    DoctorHomePage(notificationCount: 3),
    ScrollableCalendarPage(),
    Center(child: Text('Notifications Page')), // Replace with actual page
    DoctorProfilePage(), // Navigate to Profile Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications),
                if (_notificationCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DoctorHomePage extends StatelessWidget {
  final int notificationCount;

  DoctorHomePage({required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upper Section (Top bar with greeting and bell)
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Dr. Raed Alqadi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 30,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),

        // Main Options Section
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.people_outline,
                  title: 'Requests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestsDashboardPage()),
                  ),
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.timeline,
                  title: 'Timeline',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScrollableCalendarPage()),
                  ),
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.work_outline,
                  title: 'Students & Projects',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentsProjectsPage()),
                  ),
                ),
                _buildOptionCard(context,
                    icon: Icons.table_chart,
                    title: 'Discussion Table',
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DiscussionTablePage()),
                        )),
                _buildOptionCard(
                  context,
                  icon: Icons.folder_open,
                  title: 'View Files',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewFilesPage()),
                  ),
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.message_outlined,
                  title: 'Messages',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: primaryColor),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
