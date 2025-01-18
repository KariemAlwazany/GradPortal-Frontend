// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Admin/admin.dart';
import 'package:flutter_project/screens/Shop/Delivery/delivery_screen.dart';
import 'package:flutter_project/screens/Student/CompleteSign/forward.dart';

import 'package:flutter_project/screens/doctors/HeadDoctor/headdoctor.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/doctor.dart';
import 'package:flutter_project/screens/Shop/shop_home_page.dart';
import 'package:flutter_project/utils/notification_service.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing JWT token
import 'package:flutter_project/screens/login/signup.dart';
import 'package:flutter_project/theme/theme.dart';
import 'package:flutter_project/widgets/custom_scaffold.dart';
import 'package:flutter_project/screens/NormalUser/main_screen.dart';
import 'package:flutter_project/screens/login/forget_password_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> login(String email, String password) async {
  // Prepare the login data
  Map<String, dynamic> loginData = {
    "Email": email,
    "Password": password,
  };

  try {
    // Send data to API (replace 'your_api_url' with the actual endpoint)
    final url =
        '${dotenv.env['API_BASE_URL']}/GP/v1/users/login'; // Update this to your API URL
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginData),
    );

    if (response.statusCode == 200) {
      // If the API request is successful, return the response data
      return jsonDecode(response.body);
    } else {
      // If the login fails, return the error message
      var responseData = jsonDecode(response.body);
      return {"error": responseData['message']};
    }
  } catch (e) {
    // Handle exceptions
    return {"error": "Exception occurred: $e"};
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  // final AuthMethods _authMethods = AuthMethods();
  final formSignInKey = GlobalKey<FormState>();
  bool rememberMe = true;
  String? email;
  String? password;

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token); // Store JWT token
  }

Future<void> onUserLogin(String jwtToken) async {
  final prefs = await SharedPreferences.getInstance();

  // Save the JWT token
  await prefs.setString('jwt_token', jwtToken);

  // Retrieve the stored FCM token
  final fcmToken = prefs.getString('fcm_token');
  if (fcmToken != null) {
    // Send the token to the server
    NotificationService notificationService = NotificationService();
    await notificationService.updateTokenToServer(fcmToken);
  } else {
    print('No FCM token found to send to the server.');
  }
}




  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        onSaved: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onSaved: (value) {
                          password = value;
                        },
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordPage(),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formSignInKey.currentState!.validate()) {
                              formSignInKey.currentState!.save();
                              // Call the login function and handle the response
                              var result = await login(email!, password!);

                              if (result.containsKey('token')) {
                                String token =
                                    result['token']; // Capture JWT token
                                await _storeToken(
                                    token); // Store token for future use

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Login successful!'),
                                  ),
                                );
                                onUserLogin(result['token']);
                                String userRole =
                                    result['data']['user']['Role'];

                                if (userRole == 'User') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShopHomePage(),
                                    ),
                                  );
                                } else if (userRole == 'Doctor') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorPage(),
                                    ),
                                  );
                                } else if (userRole == 'Seller') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShopHomePage(),
                                    ),
                                  );
                                } else if (userRole == 'Admin') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminPage(),
                                    ),
                                  );
                                } else if (userRole == 'Student') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StatusCheckPage(), // Ensure Widget193 is correctly wrapped
                                    ),
                                  );
                                }
                                else if (userRole == 'Delivery') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeliveryScreen(), // Ensure Widget193 is correctly wrapped
                                    ),
                                  );
                                }
                                 else if (userRole == 'Head') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HeadDoctorPage(), // Ensure Widget193 is correctly wrapped
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['error']),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Sign up with',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Logo(Logos.facebook_f),
                          Logo(Logos.twitter),
                          Logo(Logos.apple),
                          GestureDetector(
                            onTap: () async {
                              bool res = false;
                              // await _authMethods.signInWithGoogle(context);
                              if (res) {
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //        // HomeScreen(), // Ensure Widget193 is correctly wrapped
                                //   ),
                                // );
                              }
                            }, // Call sign-in method
                            child: Logo(Logos.google),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up now',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
