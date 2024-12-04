import 'package:flutter/material.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class HeadDoctorProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Placeholder
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Dr. John Doe', // Example Name
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Head Doctor',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: 20),

                    // Contact Information
                    _buildInfoRow(Icons.email, 'Email', 'johndoe@example.com'),
                    SizedBox(height: 15),
                    _buildInfoRow(Icons.phone, 'Phone', '+123 456 7890'),
                    SizedBox(height: 15),
                    _buildInfoRow(
                        Icons.location_on, 'Office', 'Room 201, Building A'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Action Buttons
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  // Handle Edit Profile action
                },
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  await _logout(context); // Call the function with the context
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build each information row
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
}
