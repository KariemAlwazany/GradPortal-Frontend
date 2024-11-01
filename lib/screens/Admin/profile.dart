import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class AdminProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Admin Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Name
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/admin_avatar.png'), // Placeholder image
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 16),
            Text(
              'Admin Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'System Administrator',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Divider(height: 32, color: Colors.grey[300]),

            // Profile Information
            _buildProfileInfoRow(Icons.email, 'Email', 'admin@example.com'),
            _buildProfileInfoRow(Icons.phone, 'Phone', '+123 456 7890'),
            _buildProfileInfoRow(
                Icons.business, 'Department', 'Administration'),
            _buildProfileInfoRow(
                Icons.calendar_today, 'Joined', 'January 2021'),
            Divider(height: 32, color: Colors.grey[300]),

            // Action Buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.settings),
                    label: Text('Account Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: primaryColor,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Confirm logout
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Perform logout
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor),
                              child: Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.logout),
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          SizedBox(width: 16),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
