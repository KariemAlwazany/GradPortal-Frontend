import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Admin/doctorrequests.dart';
import 'package:flutter_project/screens/Admin/profile.dart';
import 'package:flutter_project/screens/Admin/sellerrequests.dart';
import 'package:flutter_project/screens/Admin/statistics.dart';
import 'package:flutter_project/screens/Admin/studentrequests.dart';
import 'package:flutter_project/screens/Admin/transfer.dart';
import 'package:flutter_project/screens/Admin/students_shop.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/profile.dart';

const Color primaryColor = Color(0xFF3B4280);

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final int _notificationCount = 7; // Example notification count

  final List<Widget> _pages = [
    AdminHomeTab(notificationCount: 7),
    AdminManageTab(),
    SchedulePage(),
    HeadDoctorProfilePage(),
    StudentsShop(),
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
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
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

class AdminHomeTab extends StatelessWidget {
  final int notificationCount;

  const AdminHomeTab({super.key, required this.notificationCount});

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
                children: const [
                  SizedBox(height: 12),
                  Text(
                    'Welcome,',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  Text(
                    'Admin',
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
                          leading: Icon(Icons.person, color: primaryColor),
                          title: Text("New Doctor Request"),
                          subtitle: Text("5 minutes ago"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorRequestsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.person_add, color: primaryColor),
                          title: Text("New Student Request"),
                          subtitle: Text("10 minutes ago"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentRequestsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.store, color: primaryColor),
                          title: Text("New Seller Request"),
                          subtitle: Text("1 hour ago"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerRequestsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0, // Moves the badge closer to the icon
                      top: -2, // Adjusts the vertical position
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
                _buildOptionCard(
                  context,
                  icon: Icons.store,
                  title: 'Seller Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerRequestsPage()),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StatisticsPage()),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.swap_horiz,
                  title: 'Manage Head Doctor',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageDoctorsTransferPage()),
                    );
                  },
                ),
                _buildOptionCard(
                  context,
                  icon: Icons.shop,
                  title: 'Manage Students Shop',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentsShop()),
                    );
                  },
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

class AdminManageTab extends StatelessWidget {
  const AdminManageTab({super.key});

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
            children: const [
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
                _buildOptionCard(context,
                    icon: Icons.person, title: 'Doctor Requests', onTap: () {}),
                _buildOptionCard(context,
                    icon: Icons.person_add,
                    title: 'Student Requests',
                    onTap: () {}),
                _buildOptionCard(context,
                    icon: Icons.store, title: 'Seller Requests', onTap: () {}),
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
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule'), backgroundColor: primaryColor),
      body: Center(child: Text('Schedule Page Content')),
    );
  }
}
