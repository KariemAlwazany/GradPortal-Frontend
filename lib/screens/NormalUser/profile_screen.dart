import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}

TextEditingController _oldPasswordController = TextEditingController();
TextEditingController _newPasswordController = TextEditingController();

Future<Map<String, dynamic>?> getUser() async {
  final String? token = await getToken();
  final response = await http.get(
    Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get user');
  }
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  File? _image;
  bool _showPasswordFields = false;
  String fullName = "Loading...";
  String email = "Loading...";
  String role = "Loading...";
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _roleController = TextEditingController();

  String _joinedDate = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _saveProfile() async {
    final String? token = await getToken();
    final response;
    if (!_oldPasswordController.text.isEmpty) {
      response = await http.patch(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/updatePassword'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'passwordcurrent': _oldPasswordController.text,
            'password': _newPasswordController.text,
            'passwordconfirm': _oldPasswordController.text
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password Changed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password Failed to Change')),
        );
        throw Exception('Failed to update password');
      }
      if (!_fullNameController.text.isEmpty && _emailController.text.isEmpty) {
        final response2 = await http.patch(
            Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/updateMe'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'FirstName': _fullNameController.text,
              'Email': _emailController.text,
            }));
        if (response2.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Changes Saved')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Changes Failed to Save')),
          );
          throw Exception('Failed to update password');
        }
      }
    } else if (!_fullNameController.text.isEmpty) {
      response = await http.patch(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/updateMe'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'FullName': _fullNameController.text,
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Changes Saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Failed to Change')),
        );
        throw Exception('Failed to update password');
      }
    }

    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await getUser();
      if (userData != null) {
        setState(() {
          fullName = userData['data']['data']['FullName'] ?? 'Unknown User';
          _fullNameController = TextEditingController(text: fullName);
          email = userData['data']['data']['Email'] ?? 'Unknown Role';
          _emailController = TextEditingController(text: email);
          String createdAt =
              userData['data']['data']['createdAt'] ?? 'Unknown Date';
          role = userData['data']['data']['Role'] ?? 'Unknown Date';
          _roleController = TextEditingController(text: role);

          if (createdAt != 'Unknown Date') {
            DateTime parsedDate = DateTime.parse(createdAt);
            _joinedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          } else {
            _joinedDate = 'Unknown Date';
          }
        });
      }
    } catch (error) {
      print('Failed to load user data: $error');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.shade100,
                          Colors.purpleAccent.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : AssetImage('assets/profile_image.png')
                              as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pinkAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _roleController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // -- Password Fields
                    if (_showPasswordFields) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          obscureText: true,
                          controller: _oldPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          obscureText: true,
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // -- Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showPasswordFields = !_showPasswordFields;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          _showPasswordFields
                              ? 'Hide Password Fields'
                              : 'Change Password',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // -- Save Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // -- Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout, // Logout function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // -- Joined Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Joined at " + _joinedDate,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
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
}
