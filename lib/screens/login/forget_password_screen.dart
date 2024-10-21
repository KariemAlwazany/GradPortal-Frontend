import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math'; // For generating random OTPs

import 'verification_code.dart'; // Import the OTPPage
import 'signin_screen.dart'; // Import your SignInScreen

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonPressed = false; // For subtle animation
  late String _generatedOTP; // This will store the generated OTP

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Function to generate a random OTP
  String generateOTP(int length) {
    final random = Random();
    const availableChars = '0123456789';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
    return randomString;
  }

  // Function to send OTP using Gmail SMTP via the `mailer` package
  Future<void> sendOTP(String email) async {
    final String username = 'Yazan.mansour2003@gmail.com'; // Your Gmail
    final String password = 'btgv vhcc sizg wqcm'; // Your App Password

    final smtpServer = gmail(username, password);

    // Generate the OTP
    _generatedOTP = generateOTP(6);

    // Create the email message
    final message = Message()
      ..from = Address(username, 'Mail') // App name
      ..recipients.add(email) // The recipient email address
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $_generatedOTP'; // Send generated OTP

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());

      // Navigate to the OTP verification page if the email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            email: email,
            generatedOTP:
                _generatedOTP, // Pass the generated OTP to the OTPPage
          ),
        ),
      );
    } on MailerException catch (e) {
      // If sending fails, print the error and show a message to the user
      print('Message not sent. ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
        ),
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
                                  content: Text('Please enter an email'),
                                ),
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
