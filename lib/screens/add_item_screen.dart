import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String username = 'Loading...';
  String fullName = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final profileUrl = Uri.parse('http://192.168.0.131:3000/GP/v1/seller/profile');
    final userUrl = Uri.parse('http://192.168.0.131:3000/GP/v1/seller/role');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          username = "Not logged in";
          fullName = "Not logged in";
          email = "Not logged in";
          phoneNumber = "Not logged in";
        });
        return;
      }

      // Fetch Profile Information
      final userResponse = await http.get(
        userUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);

        setState(() {
          username = userData['Username'] ?? "No username found";
          fullName = userData['FullName'] ?? "No full name found";
          email = userData['Email'] ?? "No email found";
        });
      } else {
        setState(() {
          username = "Error loading username";
          fullName = "Error loading full name";
          email = "Error loading email";
        });
      }

      // Fetch Phone Number
      final sellerResponse = await http.get(
        profileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (sellerResponse.statusCode == 200) {
        final userData = json.decode(sellerResponse.body);
        setState(() {
          phoneNumber = userData['Phone_number'] ?? "No phone number found";
        });
      } else {
        setState(() {
          phoneNumber = "Error loading phone number";
        });
      }
    } catch (e) {
      setState(() {
        username = "Network error";
        fullName = "Network error";
        email = "Network error";
        phoneNumber = "Network error";
      });
      print(e);
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: const Color(0xFF3B4280),
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: fullName,
                        hintText: fullName,
                        prefixIcon: const Icon(LineAwesomeIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: username,
                        hintText: username,
                        prefixIcon: const Icon(LineAwesomeIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: email,
                        hintText: email,
                        prefixIcon: const Icon(LineAwesomeIcons.envelope_1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: phoneNumber,
                        hintText: phoneNumber,
                        prefixIcon: const Icon(LineAwesomeIcons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                    ),
                      const SizedBox(height: 20),
                      TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(LineAwesomeIcons.fingerprint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                      const SizedBox(height: 20),
                      TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Rewrite Password',
                        prefixIcon: const Icon(LineAwesomeIcons.fingerprint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(color: Color(0xFF3B4280), width: 2.0),
                        ),
                      ),
                      obscureText: true,
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
