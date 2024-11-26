import 'package:flutter/material.dart';
import '../components/navbar/bottom_nav.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the User Dashboard!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'This is where you can see all the features available to normal users.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Add functionality for navigating or actions here
              },
              child: Text('Go to User Settings'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Example: navigate to another page or perform another action
              },
              child: Text('Explore Features'),
            ),
          ],
        ),
      ),
      //   bottomNavigationBar: BottomNav(),
    );
  }
}
