import 'package:flutter/material.dart';
import 'package:flutter_project/components/navbar/community_navabar.dart';
import 'package:flutter_project/resources/home_screen.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/postdeadlines.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/profile.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/Requests.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createMeeting.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/discussionTable.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/meetings.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/profile.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/receiveMessages.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/sendMessages.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/studentsproject.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/timeline.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/viewfiles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color primaryColor = Color(0xFF3B4280);

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const DoctorPage({super.key});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  int _selectedIndex = 0;
  final int _notificationCount = 3; // Example notification count

  final List<Widget> _pages = [
    DoctorHomePage(),
    ScrollableCalendarPage(),
    ReceivedMessagesPage(),
    HeadDoctorProfilePage(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
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

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  Future<String> fetchDoctorName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        return "Error fetching name";
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/doctors/current'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return "Dr. ${data['FullName']}";
      } else {
        return "Error fetching name";
      }
    } catch (e) {
      return "Error fetching name";
    }
  }

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
                      FutureBuilder<String>(
                        future: fetchDoctorName(),
                        initialData: 'Dr. Placeholder',
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Dr. Placeholder',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error fetching name',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }
                          return Text(
                            snapshot.data!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
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
                              leading: Icon(Icons.people, color: primaryColor),
                              title: Text("New Request from Student"),
                              subtitle: Text("5 minutes ago"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RequestsDashboardPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading:
                                  Icon(Icons.folder_open, color: primaryColor),
                              title: Text("New File Uploaded"),
                              subtitle: Text("10 minutes ago"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewFilesPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.message, color: primaryColor),
                              title: Text("New Message Received"),
                              subtitle: Text("1 hour ago"),
                              onTap: () {
                                // Navigate to the Messages page
                              },
                            ),
                          ),
                        ],
                      ),
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
                            '3',
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
                  title: 'Calender',
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
                  icon: Icons.people,
                  title: 'Community',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityNavbar()),
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
