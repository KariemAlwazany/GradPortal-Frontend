import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/add_item_screen_student.dart';
import 'package:flutter_project/screens/Shop/shop_management_screen.dart';
import 'package:flutter_project/screens/Shop/update_seller_profile_screen.dart';
import 'package:flutter_project/screens/Shop/update_user_student_screen.dart';
import 'package:flutter_project/screens/Shop/view_items_screen.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/screens/Shop/add_item_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: use_key_in_widget_constructors
class SellerProfileScreen extends StatefulWidget {
  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  String userName = 'Loading...';
  String email = 'Loading...';
  String userRole = ''; // Add a field for the user's role

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Fetch the base URL from the .env file
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final roleUrl =
        Uri.parse('${baseUrl}/GP/v1/seller/role'); // Use the dynamic base URL

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          userName = "Not logged in";
          email = "Not logged in";
          userRole = "Unknown"; // Set default to "Unknown"
        });
        return;
      }

      // Fetch Role Data
      final response = await http.get(
        roleUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['Username'] ??
              "No name found"; // Assuming the response contains 'Username'
          email = data['Email'] ?? "No email found";
          userRole = data['Role'] ??
              "Unknown"; // Assuming the response contains 'Role'
        });
      } else {
        setState(() {
          userName = "Error loading user";
          email = "Error loading role";
          userRole = "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error loading user";
        email = "Error loading role";
        userRole = "Unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B4280),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B4280),
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Menu: Show these options based on the user role
              if (userRole == "Seller") ...[
                ProfileMenuWidget(
                    title: "Edit Profile",
                    icon: Icons.edit,
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateProfileScreen())
                              );
                    }),
              ] else if (userRole == "Student") ...[
                // Show only Edit Profile for Student or User
                ProfileMenuWidget(
                    title: "Edit Profile",
                    icon: Icons.edit,
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateUserSellerProfileScreen()));
                    }),
                ProfileMenuWidget(
                    title: "Add item to sale",
                    icon: Icons.add,
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddItemScreenStudents()));
                    }),
              ] else if (userRole == "User") ...[
                // Show only Edit Profile for Student or User
                ProfileMenuWidget(
                    title: "Edit Profile",
                    icon: Icons.edit,
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateUserSellerProfileScreen()));
                    }),
              ], 
              ProfileMenuWidget(
                title: "Logout",
                icon: Icons.logout,
                textColor: Colors.red,
                endIcon: false,
                onPress: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('jwt_token');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color? textColor;
  final bool endIcon;

  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.textColor,
    this.endIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black),
      ),
      trailing: endIcon ? const Icon(Icons.arrow_forward_ios) : null,
    );
  }
}
