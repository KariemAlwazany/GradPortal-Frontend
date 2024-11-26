import 'package:flutter/material.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5); // Light background color

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Top Section with Profile Picture and Name
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                      'assets/profile_pic.png'), // Replace with actual profile picture asset
                ),
                SizedBox(height: 16),
                Text(
                  'Yazan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Profile Information
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInfoItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'yazan@example.com',
                  ),
                  ProfileInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '+123 456 7890',
                  ),
                  ProfileInfoItem(
                    icon: Icons.school_outlined,
                    label: 'Major',
                    value: 'Computer Science',
                  ),
                  ProfileInfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year',
                    value: '3rd Year',
                  ),
                  Spacer(),
                  // Logout Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignInScreen()), // Directly passing the widget
                        );
                      },
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF4A5568), // Dark grayish-blue color
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 30.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Information Item Widget
class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  ProfileInfoItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          SizedBox(width: 20),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
