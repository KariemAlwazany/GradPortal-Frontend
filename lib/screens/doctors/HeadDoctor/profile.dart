import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ProfilePage extends StatelessWidget {
  // Sample user profile data
  final Map<String, String> userProfile = {
    'name': 'Dr. Raed Alqadi',
    'position': 'Professor of Computer Science',
    'email': 'raed.alqadi@example.com',
    'phone': '+123 456 7890',
    'office': 'Room 405, CS Department',
  };

  // Function to edit profile (Placeholder)
  void editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit profile functionality not yet implemented.')),
    );
  }

  // Function to logout (Placeholder)
  void logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout functionality not yet implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile header section
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userProfile['name']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userProfile['position']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Profile details section
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.email, color: primaryColor),
                    title: Text('Email'),
                    subtitle: Text(userProfile['email']!),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone, color: primaryColor),
                    title: Text('Phone'),
                    subtitle: Text(userProfile['phone']!),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.location_on, color: primaryColor),
                    title: Text('Office Location'),
                    subtitle: Text(userProfile['office']!),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Action buttons section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => editProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text('Edit Profile'),
                ),
                ElevatedButton(
                  onPressed: () => logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
