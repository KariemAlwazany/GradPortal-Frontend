import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_project/screens/Student/files.dart';
import 'resetPassword.dart'; // Import the ResetPasswordPage

class OTPPage extends StatelessWidget {
  final String email; // Accept email as a parameter
  final String generatedOTP; // Accept generatedOTP as a parameter

  const OTPPage(
      {super.key, required this.email,
      required this.generatedOTP}); // Add generatedOTP to constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover, // Ensures the image covers the whole screen
              ),
            ),
          ),
          // Back Arrow
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(
                      email: email,
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please enter the verification code sent to your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // Make text visible on the background
                    shadows: const [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                OtpTextField(
                  numberOfFields:
                      6, // Set it to 6 fields if your OTP length is 6
                  borderColor: primaryColor, //
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) async {
                    if (verificationCode == generatedOTP) {
                      // If OTP is correct, navigate to the ResetPasswordPage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordPage(email: email),
                        ),
                      );
                    } else {
                      // Show an error if OTP is incorrect
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid OTP, please try again.'),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Optionally add a button to submit the OTP
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor, // Set button color to primaryColor
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Verify'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
