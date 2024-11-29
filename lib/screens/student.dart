// student_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/shop_home_page.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Student!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Here you can manage your graduation project, communicate with peers, and interact with your supervisor.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),

              // Section for managing project components
              Text(
                'Project Management',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to project management page
                },
                child: Text('View and Manage Your Project'),
              ),

              // Section for collaboration with peers
              SizedBox(height: 20.0),
              Text(
                'Collaboration with Peers',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to student community page
                },
                child: Text('Join the Student Community'),
              ),

              // Section for component marketplace
              SizedBox(height: 20.0),
              Text(
                'Project Components Marketplace',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to MarketplacePage when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopHomePage(),
                    ),
                  );
                },
                child: Text('Buy/Sell Project Components'),
              ),

              // Section for requesting supervisor meetings
              SizedBox(height: 20.0),
              Text(
                'Supervisor Meetings',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to meeting scheduling page
                },
                child: Text('Request Meeting with Supervisor'),
              ),

              // Section for notifications
              SizedBox(height: 20.0),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to notifications page
                },
                child: Text('View Important Deadlines & Events'),
              ),

              // Section for profile management
              SizedBox(height: 20.0),
              Text(
                'Profile Management',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to profile page
                },
                child: Text('Manage Your Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
