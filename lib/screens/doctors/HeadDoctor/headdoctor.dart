import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Admin/doctorrequests.dart';
import 'package:flutter_project/screens/Admin/studentrequests.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/profile.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/createtable.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/managerequests.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/postdeadlines.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/remove_partner.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/time_management.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/transfer.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/viewcurrentprojects.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/Requests.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/discussionTable.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/meetings.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/receiveMessages.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/sendMessages.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/studentsproject.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/timeline.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/viewfiles.dart';

const Color primaryColor = Color(0xFF3B4280);

class HeadDoctorPage extends StatefulWidget {
  @override
  _HeadDoctorPageState createState() => _HeadDoctorPageState();
}

class _HeadDoctorPageState extends State<HeadDoctorPage> {
  int _selectedIndex = 0;
  int _notificationCount = 5;

  final List<Widget> _pages = [
    HeadDoctorHomeTab(notificationCount: 5), // Home tab with common fields
    HeadDoctorManageTab(), // Manage tab with new fields
    ReceivedMessagesPage(), // Schedule tab
    HeadDoctorProfilePage(), // Profile tab
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
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages', // Changed label to "Messages"
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

class HeadDoctorHomeTab extends StatelessWidget {
  final int notificationCount;

  HeadDoctorHomeTab({required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar with Notification Dropdown
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'Welcome,',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  Text(
                    'Head Doctor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Notification Icon with Dropdown Menu
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PopupMenuButton(
                    icon: Icon(Icons.notifications,
                        color: Colors.white, size: 30),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading:
                              Icon(Icons.request_page, color: primaryColor),
                          title: Text("New Request Received"),
                          subtitle: Text("5 minutes ago"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestsDashboardPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading:
                              Icon(Icons.calendar_month, color: primaryColor),
                          title: Text("New Event Added to Timeline"),
                          subtitle: Text("10 minutes ago"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScrollableCalendarPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.message, color: primaryColor),
                          title: Text("New Message"),
                          subtitle: Text("1 hour ago"),
                          onTap: () {
                            // Navigate to Messages page
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
                  icon: Icons.video_call,
                  title: 'Meetings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MeetingsPage()),
                  ),
                ),
                _buildOptionCard(context,
                    icon: Icons.post_add, title: 'Post Deadline', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostDeadlinesPage()),
                  );
                }),
                _buildOptionCard(
                  context,
                  icon: Icons.calendar_month,
                  title: 'Calendar',
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
                  icon: Icons.message_outlined,
                  title: 'Send Messages',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendMessagePage()),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.folder_open,
                  title: 'View Files',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewFilesPage()),
                  ),
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

class HeadDoctorManageTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar Similar to Home
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Manage',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),

        // Manage Options
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
                  icon: Icons.person,
                  title: 'Doctor Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorRequestsPage()),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.person_add,
                  title: 'Student Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentRequestsPage()),
                    );
                  },
                ),
                _buildOptionCard(context,
                    icon: Icons.folder_open,
                    title: 'View Current Projects', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewCurrentProjectsPage()),
                  );
                }),
                _buildOptionCard(context,
                    icon: Icons.table_chart,
                    title: 'Create Discussion Table', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateDiscussionTablePage()),
                  );
                }),
                _buildOptionCard(context,
                    icon: Icons.transfer_within_a_station,
                    title: 'Transfer Students', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransferStudentPage()),
                  );
                }),
                _buildOptionCard(context,
                    icon: Icons.manage_accounts,
                    title: 'Manage Requests', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageStudentRequestsPage()),
                  );
                }),
                _buildOptionCard(
                  context,
                  icon: Icons
                      .person_remove, // Suitable icon for removing a partner
                  title: 'Remove Partner', // Suitable title
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RemovePartnerPage(), // Navigate to the Remove Partner page
                      ),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.settings,
                  title: 'Manage', // New Card
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeadlineManagementPage()),
                  ),
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

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule'), backgroundColor: primaryColor),
      body: Center(child: Text('Schedule Page Content')),
    );
  }
}
