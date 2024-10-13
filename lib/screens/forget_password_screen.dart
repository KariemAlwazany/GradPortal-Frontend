import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/screens/verification_code.dart';
import 'package:flutter_project/screens/signin_screen.dart';
import 'dart:convert';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonPressed = false; // For subtle animation

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.88.11:3000/GP/v1/users/forgetPassword'), // Replace with your API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        // If the server sends a success response, navigate to the OTP verification page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code sent!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPPage(),
          ),
        );
      } else {
        // Show error if response is not successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPPage(),
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Set background image using BoxDecoration
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit
                    .cover, // Adjusts the image to cover the entire background
              ),
            ),
          ),
          // Back arrow at the top-left corner
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Add an animated container for subtle effect when the button is pressed
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: _isButtonPressed
                        ? EdgeInsets.all(40)
                        : EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Display "Enter your email" as normal text
                        Text(
                          'Enter your Email',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Email Input Field with an Icon
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blueAccent,
                            ),
                            hintText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Send Verification Code Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            backgroundColor:
                                Colors.blueAccent, // Button background color
                            elevation: 5,
                          ),
                          onPressed: () {
                            setState(() {
                              _isButtonPressed = !_isButtonPressed;
                            });
                            if (_emailController.text.isNotEmpty) {
                              // Call the sendOTP function when the email is entered
                              sendOTP(_emailController.text);
                            } else {
                              // Show a message if the email field is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Please enter an email')),
                              );
                            }
                          },
                          child: Text(
                            'Send Verification Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        ],
      ),
    );
  }
}
