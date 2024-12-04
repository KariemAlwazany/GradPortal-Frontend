import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/doctor.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class DoctorProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DoctorPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_picture.png'),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 16),
            Text(
              'Dr. Raed Alqadi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              'Professor of Computer Science',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Divider(height: 40, thickness: 1, color: Colors.grey[300]),
            _buildSectionTitle('Academic Information'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.school, 'University', 'XYZ University'),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.business, 'Department', 'Computer Science'),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.star, 'Position', 'Head of Research Department'),
                  ],
                ),
              ),
            ),
            Divider(height: 40, thickness: 1, color: Colors.grey[300]),
            _buildSectionTitle('Contact Information'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        Icons.email, 'Email', 'raed.alqadi@xyzuniversity.edu'),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, 'Phone', '+123 456 7890'),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.location_city, 'Office', 'Room 304, CS Building'),
                  ],
                ),
              ),
            ),
            Divider(height: 40, thickness: 1, color: Colors.grey[300]),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _logout(context); // Call the function with the context
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String info) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              info,
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
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
