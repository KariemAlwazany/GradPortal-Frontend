import 'package:flutter/material.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class HeadDoctorProfilePage extends StatefulWidget {
  @override
  _HeadDoctorProfilePageState createState() => _HeadDoctorProfilePageState();
}

class _HeadDoctorProfilePageState extends State<HeadDoctorProfilePage> {
  bool isEditing = false;
  final TextEditingController nameController =
      TextEditingController(text: 'Dr. John Doe');
  final TextEditingController emailController =
      TextEditingController(text: 'johndoe@example.com');
  final TextEditingController phoneController =
      TextEditingController(text: '+123 456 7890');
  final TextEditingController officeController =
      TextEditingController(text: 'Room 201, Building A');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      _buildEditableField(
                        'Name',
                        nameController,
                        isEditing,
                      ),
                      SizedBox(height: 20),
                      _buildEditableField(
                        'Email',
                        emailController,
                        isEditing,
                      ),
                      SizedBox(height: 15),
                      _buildEditableField(
                        'Phone',
                        phoneController,
                        isEditing,
                      ),
                      SizedBox(height: 15),
                      _buildEditableField(
                        'Office',
                        officeController,
                        isEditing,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Action Buttons
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: Colors.white,
                  ),
                  label: Text(
                    isEditing ? 'Confirm' : 'Edit Profile',
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
                    setState(() {
                      isEditing = !isEditing;
                    });
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
                  onPressed: () {
                    _showLogoutConfirmation(
                        context); // Show confirmation dialog
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditable,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          label == 'Email'
              ? Icons.email
              : label == 'Phone'
                  ? Icons.phone
                  : label == 'Office'
                      ? Icons.location_on
                      : Icons.person,
          color: primaryColor,
          size: 28,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
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
              isEditable
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  : Text(
                      controller.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close the dialog
                await _logout(context); // Perform logout
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
