// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/update_user_student_screen.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController(); // New field

  String username = 'Loading...';
  String fullName = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = 'Loading...';
  String role = 'Loading...';
  String shopName = 'Loading...'; // New field

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final roleUrl = Uri.parse('${baseUrl}/GP/v1/seller/role');
    final userUrl = Uri.parse('${baseUrl}/GP/v1/seller/profile');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          username = "Not logged in";
          email = "Not logged in";
          role = "Not logged in";
          phoneNumber = "Not logged in";
          fullName = "Not logged in";
          shopName = "Not logged in"; // New field
        });
        return;
      }

      // Fetch Role Data
      final roleResponse = await http.get(
        roleUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (roleResponse.statusCode == 200) {
        final data = json.decode(roleResponse.body);
        setState(() {
          username = data['Username'] ?? "No username found";
          email = data['Email'] ?? "No email found";
          role = data['Role'] ?? "No role found";
          fullName = data['FullName'] ?? "No name found";
        });
      } else {
        setState(() {
          username = "Error loading username";
          email = "Error loading email";
          role = "Error loading role";
          fullName = "Error loading name";
        });
      }

      // Fetch Profile Data
      final profileResponse = await http.get(
        userUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        setState(() {
          phoneNumber = profileData['Phone_number'] ?? "No phone number found";
          shopName = profileData['Shop_name'] ?? "No shop name found"; // New field
        });
      } else {
        setState(() {
          phoneNumber = "Error loading phone number";
          shopName = "Error loading shop name"; // New field
        });
      }
    } catch (e) {
      setState(() {
        phoneNumber = "Error loading data";
        shopName = "Error loading data"; // New field
      });
    }
  }

  Future<void> updateProfile() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final updateUrl = Uri.parse('${baseUrl}/GP/v1/seller/updateSeller');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Check password and confirm password match
    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Build the data object with non-empty fields
    Map<String, dynamic> updates = {};
    if (usernameController.text.isNotEmpty) updates['Username'] = usernameController.text;
    if (phoneNumberController.text.isNotEmpty) updates['Phone_number'] = phoneNumberController.text;
    if (fullNameController.text.isNotEmpty) updates['FullName'] = fullNameController.text;
    if (emailController.text.isNotEmpty) updates['Email'] = emailController.text;
    if (passwordController.text.isNotEmpty) updates['Password'] = passwordController.text;
    if (shopNameController.text.isNotEmpty) updates['Shop_name'] = shopNameController.text; // New field

    try {
      final response = await http.patch(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        fetchUserData(); // Refresh data after successful update
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = role != "Student" && role != "User"; // Only allow editing if the role is not "Student" or "User"

    // Navigate to UpdateUserSellerProfileScreen if role is User or Student
    if (role == "Student" || role == "User") {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UpdateUserSellerProfileScreen(),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B4280),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3B4280)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Role: $role',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B4280),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: fullNameController,
                      label: fullName,
                      hint: fullName,
                      icon: LineAwesomeIcons.user,
                      isEnabled: isEditable,
                    ),
                    _buildTextField(
                      controller: usernameController,
                      label: username,
                      hint: username,
                      icon: LineAwesomeIcons.user,
                      isEnabled: isEditable,
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: email,
                      hint: email,
                      icon: LineAwesomeIcons.envelope_1,
                      isEnabled: isEditable,
                    ),
                    _buildTextField(
                      controller: phoneNumberController,
                      label: phoneNumber,
                      hint: phoneNumber,
                      icon: LineAwesomeIcons.phone,
                      isEnabled: true, // Always editable for all users
                    ),
                    _buildTextField(
                      controller: shopNameController, // New field
                      label: shopName, // New field
                      hint: shopName, // New field
                      icon: LineAwesomeIcons.store, // New field
                      isEnabled: isEditable,
                    ),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter new password',
                      icon: LineAwesomeIcons.fingerprint,
                      isPassword: true,
                      isEnabled: isEditable,
                    ),
                    _buildTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter new password',
                      icon: LineAwesomeIcons.fingerprint,
                      isPassword: true,
                      isEnabled: isEditable,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B4280),
                        ),
                        child: const Text(
                          "Confirm Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isEnabled = true,
  }) {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          enabled: isEnabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(color: Color(0xFF3B4280), width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
