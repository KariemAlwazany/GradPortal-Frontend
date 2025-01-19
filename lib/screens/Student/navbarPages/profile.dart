import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Student/calendar.dart';
import 'package:flutter_project/screens/Student/request_remove_partner.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color primaryColor = Color(0xFF3B4280);

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isChangingPassword = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String role = ''; // To store the role fetched from the API

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  // Fetch user data from the API
  String storedHashedPassword =
      ''; // Store the hashed password fetched from the API

  Future<void> _fetchUserData() async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = data['data']['data'];

      setState(() {
        nameController.text = userData['FullName'];
        usernameController.text = userData['Username'];
        emailController.text = userData['Email'];
        phoneController.text = userData['phone_number'] ?? '';
        role = userData['Role']; // Fetch the role
        storedHashedPassword =
            userData['Password']; // Store the hashed password
      });
    } else {
      print('Failed to fetch user data: ${response.statusCode}');
    }
  }

  Future<void> _updatePassword() async {
    final token = await _getToken();
    if (token == null) return;

    // Prepare the request body
    final Map<String, String> body = {
      'passwordcurrent': oldPasswordController.text,
      'password': newPasswordController.text,
      'passwordconfirm': confirmPasswordController.text,
    };

    // Send the PATCH request
    final response = await http.patch(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/updatepassword'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      setState(() {
        isChangingPassword = false;
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password.')),
      );
    }
  }

  // Validate the old password
  Future<bool> _validateOldPassword(
      String enteredPassword, String storedHashedPassword) async {
    // Use bcrypt to compare the entered password with the stored hashed password
    return BCrypt.checkpw(enteredPassword, storedHashedPassword);
  }

  // Update user data
  Future<void> _updateUserData() async {
    final token = await _getToken();
    if (token == null) return;

    // Validate old password if changing password
    if (isChangingPassword) {
      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match.')),
        );
        return;
      }

      // Validate the old password locally
      final isOldPasswordValid = await _validateOldPassword(
        oldPasswordController.text,
        storedHashedPassword,
      );

      if (!isOldPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Old password is incorrect.')),
        );
        return;
      }

      // Update the password
      await _updatePassword();
      return; // Exit after updating the password
    }

    // Prepare the request body for updating profile data
    final Map<String, String> body = {
      'FullName': nameController.text,
      'Email': emailController.text,
      'phone_number': phoneController.text,
    };

    // Send the PATCH request to update profile data
    final response = await http.patch(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/updateme'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    // Log the response for debugging
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      setState(() {
        isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  // Get JWT token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Color backgroundColor = Color(0xFFF5F5F5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_remove, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RemovePartnerRequestPage()),
              );
            },
            tooltip: 'Remove Partner',
          ),
        ],
      ),
      backgroundColor: backgroundColor,
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
                          role, // Display the role fetched from the API
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
                        'Full Name',
                        nameController,
                        isEditing,
                      ),
                      SizedBox(height: 20),
                      _buildUneditableField(
                        'Username',
                        usernameController,
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
                      if (isChangingPassword) ...[
                        SizedBox(height: 20),
                        _buildPasswordField(
                          'Old Password',
                          oldPasswordController,
                        ),
                        SizedBox(height: 15),
                        _buildPasswordField(
                          'New Password',
                          newPasswordController,
                        ),
                        SizedBox(height: 15),
                        _buildPasswordField(
                          'Confirm New Password',
                          confirmPasswordController,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Action Buttons
              if (isChangingPassword)
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Confirm',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _updateUserData,
                  ),
                ),
              SizedBox(height: 15),
              if (!isChangingPassword)
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _updateUserData(); // Save changes
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
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
                    _showLogoutConfirmation(context);
                  },
                ),
              ),
              SizedBox(height: 15),
              if (!isChangingPassword)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isChangingPassword = true;
                      });
                    },
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
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

  Widget _buildUneditableField(
    String label,
    TextEditingController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person,
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
              Text(
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

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock,
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
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
