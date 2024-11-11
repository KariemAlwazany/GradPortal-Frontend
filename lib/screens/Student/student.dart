import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/discussionTable.dart';
import 'package:flutter_project/screens/Student/files.dart';

import 'package:flutter_project/screens/Student/meeting/meeting.dart';
import 'package:flutter_project/screens/Student/navbarPages/deadline.dart';
import 'package:flutter_project/screens/Student/navbarPages/profile.dart';
import 'package:flutter_project/screens/Student/meeting/meeting_options_page.dart'; // New options page import
import 'package:flutter_project/screens/Student/projectsPage.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int _selectedIndex = 0;
  int _notificationCount = 3;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeContent(
          selectDateTime: _selectDateTime,
          notificationCount: _notificationCount),
      DeadlinePage(),
      MessagesPage(),
      ProfilePage(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingRequestPage(
              initialDateTime: selectedDateTime,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Deadlines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
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

class HomeContent extends StatelessWidget {
  final Function(BuildContext) selectDateTime;
  final int notificationCount;

  HomeContent({required this.selectDateTime, required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar with greeting and notifications
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
                        'GradHub',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Yazan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Notification Icon with Dropdown
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PopupMenuButton(
                        icon: Icon(Icons.notifications,
                            color: Colors.white, size: 30),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.calendar_today,
                                  color: primaryColor),
                              title: Text("Upcoming Deadline"),
                              subtitle: Text("Due tomorrow"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeadlinePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.message, color: primaryColor),
                              title: Text("New Message"),
                              subtitle: Text("5 minutes ago"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessagesPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading:
                                  Icon(Icons.video_call, color: primaryColor),
                              title: Text("Meeting Scheduled"),
                              subtitle: Text("Today at 3:00 PM"),
                              onTap: () {
                                selectDateTime(context);
                              },
                            ),
                          ),
                        ],
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

        // Categories Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See All'),
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MeetingsOptionsPage()),
                ),
                child: _buildCategoryItem(
                  'Meetings',
                  'Manage meetings',
                  Icons.video_call,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MeetingsOptionsPage()),
                ),
                child: _buildCategoryItem(
                  'Store',
                  'Browse resources',
                  Icons.shopping_cart_outlined,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadFilesPage()),
                ),
                child: _buildCategoryItem(
                  'Files',
                  'Manage your files',
                  Icons.file_copy_outlined,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MeetingsOptionsPage()),
                ),
                child: _buildCategoryItem(
                  'Community',
                  'Connect with peers',
                  Icons.people,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DiscussionTablePage()),
                ),
                child: _buildCategoryItem(
                  'Discussion Table',
                  'Join discussions',
                  Icons.table_chart,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectsPage()),
                ),
                child: _buildCategoryItem(
                  'View All Projects',
                  'Explore student projects',
                  Icons.folder_special,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String subtitle, IconData icon) {
    return Container(
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
            Icon(
              icon,
              size: 40,
              color: primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Widgets for MessagesPage and ProfilePage
class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Messages Page"));
  }
}
