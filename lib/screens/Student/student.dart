import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/navbarPages/deadline.dart';
import 'package:flutter_project/screens/Student/navbarPages/profile.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project/screens/Student/meeting/meeting.dart'; // Import MeetingRequestPage

const Color primaryColor = Color(0xFF3B4280);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentPage',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeContent(selectDateTime: _selectDateTime),
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

  HomeContent({required this.selectDateTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),

        // Categories
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
                onTap: () => selectDateTime(context),
                child: _buildCategoryItem(
                  'Request Meeting',
                  'Schedule a meeting',
                  Icons.video_call,
                ),
              ),
              _buildCategoryItem(
                'Store',
                'Browse resources',
                Icons.shopping_cart_outlined,
              ),
              _buildCategoryItem(
                'Files',
                'Manage your files',
                Icons.file_copy_outlined,
              ),
              _buildCategoryItem(
                'Product Design',
                'Learn design skills',
                Icons.design_services,
              ),
              _buildCategoryItem(
                'Community',
                'Connect with peers',
                Icons.people,
              ),
              _buildCategoryItem(
                'Discussion Table',
                'Join discussions',
                Icons.table_chart,
              ),
              _buildCategoryItem(
                'View All Projects',
                'Explore student projects',
                Icons.folder_special,
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
