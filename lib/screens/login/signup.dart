import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_project/screens/login/signin_screen.dart';
import 'package:flutter_project/theme/theme.dart';
import 'package:flutter_project/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'dart:typed_data'; // For Uint8List

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void dispose() {
    ageController.dispose();
    cityController.dispose();
    super.dispose();
  }

  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  String? selectedRole;
  String? registrationNumber;
  String? phoneNumber;
  String? shopName;
  String? fullName;
  String? email;
  String? username;
  String? password;
  File? _doctorImage;
  File? _studentImage;
  String? projectType;
  String? gender;
  String? backend;
  String? frontend;
  String? database;
  String? age;
  String? location;
  final List<String> palestineCities = [
    'Nablus',
    'Ramallah',
    'Gaza',
    'Hebron',
    'Jericho',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Salfit',
    'Tubas',
    'Rafah',
    'Khan Younis',
    'Deir al-Balah',
    'Beit Hanoun',
    'Beit Lahia',
    'Al-Bireh',
    'Halhul',
    'Dura',
    'Yatta',
    'Tarqumiyah',
    'Abu Dis',
  ];

  final List<String> ages =
      List.generate(43, (index) => (18 + index).toString());
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<String> encodeImageToBase64(File image) async {
    final bytes = await image.readAsBytes(); // Get the image as bytes
    String base64Image =
        base64Encode(bytes); // Convert the bytes to Base64 string
    return base64Image;
  }

  Future<Image> decodeBase64Image(String base64Image) async {
    Uint8List imageBytes =
        base64Decode(base64Image); // Decode Base64 string to bytes
    return Image.memory(imageBytes); // Convert bytes to image
  }

  Future<void> pickImage(String role) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          if (role == 'Doctor') {
            _doctorImage = File(pickedFile.path);
          } else if (role == 'Student') {
            _studentImage = File(pickedFile.path);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<bool> isUsernameOrEmailTaken(String username, String email) async {
    try {
      // Replace 'your_api_url' with the actual endpoint to check username/email availability
      final url = '${dotenv.env['API_BASE_URL']}/GP/v1/users/check';
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "email": email}),
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['isTaken'];
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> createUser() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      _formSignupKey.currentState!.save();

      // Check if username or email is already taken
      bool isTaken = await isUsernameOrEmailTaken(username!, email!);
      if (isTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username or email is already taken')),
        );
        return;
      }

      // Initialize the image variable as null
      String? imageBase64;

      // Check if a doctor image was selected, then encode it
      if (selectedRole == 'Doctor' && _doctorImage != null) {
        imageBase64 = await encodeImageToBase64(_doctorImage!);
      }

      // Check if a student image was selected, then encode it
      if (selectedRole == 'Student' && _studentImage != null) {
        imageBase64 = await encodeImageToBase64(_studentImage!);
      }

      Map<String, dynamic> userData = {
        "FullName": fullName,
        "Email": email,
        "Username": username,
        "Password": password,
        "Role": selectedRole,
        if (selectedRole == "Student" || selectedRole == "Doctor")
          "registrationNumber": registrationNumber,
        // Add the image to the userData if an image was selected and encoded
        if (imageBase64 != null) "Degree": imageBase64,
        if (selectedRole == "Seller") "phoneNumber": phoneNumber,
        "shopName": shopName,
        if (selectedRole == "Student") "GP_Type": projectType, "BE": backend,
        "FE": frontend, "DB": database, "Gender": gender, "Age": age,
        "City": location,
      };

      try {
        // Send data to API (replace 'your_api_url' with the actual endpoint)
        final url = '${dotenv.env['API_BASE_URL']}/GP/v1/users/signup';
        final uri = Uri.parse(url);
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(userData),
        );

        if (response.statusCode == 201) {
          // If the API request is successful, navigate to the sign-in page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up successful!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        } else {
          // If the API request fails, show an error message
          var responseData = jsonDecode(response.body);
          print(responseData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } catch (e) {
        // Handle exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception occurred: $e')),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the processing of personal data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
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
                // get started form
                child: Form(
                  key: _formSignupKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        onSaved: (value) {
                          fullName = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Focus border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Red border for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        onSaved: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          } else if (!RegExp(
                                  r"^[a-zA-Z0-9.+\-_]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
                              .hasMatch(value)) {
                            return 'Please enter a valid Email';
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
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Focus border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Red border for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      TextFormField(
                        onSaved: (value) {
                          username = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Username';
                          } else if (value.length < 4) {
                            return 'Username must be at least 4 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Username'),
                          hintText: 'Enter Username',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Focus border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Red border for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      // password
                      TextFormField(
                        onSaved: (value) {
                          password = value;
                        },
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
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
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Focus border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Red border for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          label: const Text('Role'),
                          hintText: 'Select Role',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lightColorScheme
                                  .primary, // Focus border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Red border for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: ['Doctor', 'User', 'Student', 'Seller']
                            .map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),

                      // Show Registration Number if Student or Doctor is selected
                      if (selectedRole == 'Student' || selectedRole == 'Doctor')
                        Column(
                          children: [
                            const SizedBox(height: 25.0),
                            TextFormField(
                              onSaved: (value) {
                                registrationNumber = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Registration Number';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Registration Number'),
                                hintText: 'Enter Registration Number',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Focus border color
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red, // Red border for errors
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Image picker for Doctor
                      if (selectedRole == 'Doctor')
                        Column(
                          children: [
                            const SizedBox(height: 25.0),
                            ElevatedButton.icon(
                              onPressed: () => pickImage('Doctor'),
                              icon: const Icon(Icons.image),
                              label: const Text('Upload Doctor Degree'),
                            ),
                            const SizedBox(height: 15.0),
                            _doctorImage != null
                                ? Image.file(
                                    _doctorImage!,
                                    height: 150,
                                    width: 150,
                                  )
                                : const Text('No image selected'),
                            if (_doctorImage == null)
                              const Text(
                                'Please upload your Doctor Degree',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),

                      // Image picker for Student
                      if (selectedRole == 'Student')
                        Column(
                          children: [
                            const SizedBox(height: 25.0),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                label: const Text('Project Type'),
                                hintText: 'Select Project Type',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Focus border color
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red, // Red border for errors
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items:
                                  ['Hardware', 'Software'].map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  projectType = newValue;

                                  // Clear all fields when project type changes
                                  ageController.clear();
                                  cityController.clear();
                                  backend = null;
                                  frontend = null;
                                  database = null;
                                  gender = null;
                                  location = null;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a project type';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 16,
                            ),
// Dynamically display fields based on Project Type
                            if (projectType == 'Hardware') ...[
                              // Age
                              _buildSearchableField(
                                label: 'Age',
                                controller: ageController,
                                suggestions: ages,
                                onSuggestionSelected: (selectedAge) {
                                  setState(() {
                                    age = selectedAge;
                                    ageController.text = selectedAge;
                                  });
                                },
                              ),

                              const SizedBox(height: 16.0),

                              // City
                              _buildSearchableField(
                                label: 'City',
                                controller: cityController,
                                suggestions: palestineCities,
                                onSuggestionSelected: (selectedCity) {
                                  setState(() {
                                    location = selectedCity;
                                    cityController.text = selectedCity;
                                  });
                                },
                              ),
                              const SizedBox(height: 16.0),

                              // Gender
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: const Text('Gender'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: ['Male', 'Female'].map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                            ],

                            if (projectType == 'Software') ...[
                              // Backend Framework
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: const Text('Backend Framework'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: [
                                  'Node.js',
                                  'Laravel',
                                  'Spring Boot',
                                  'ASP.NET',
                                  'Other'
                                ].map((String backend) {
                                  return DropdownMenuItem<String>(
                                    value: backend,
                                    child: Text(backend),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    backend = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16.0),

                              // Frontend Framework
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: const Text('Frontend Framework'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: [
                                  'Flutter',
                                  'React',
                                  'Angular',
                                  'HTML/CSS',
                                  'Other'
                                ].map((String frontend) {
                                  return DropdownMenuItem<String>(
                                    value: frontend,
                                    child: Text(frontend),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    frontend = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16.0),

                              // Database
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: const Text('Preferred Database'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: [
                                  'MySQL',
                                  'Oracle',
                                  'MongoDB',
                                  'Django',
                                  'Other'
                                ].map((String db) {
                                  return DropdownMenuItem<String>(
                                    value: db,
                                    child: Text(db),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    database = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              _buildSearchableField(
                                label: 'Age',
                                controller: ageController,
                                suggestions: ages,
                                onSuggestionSelected: (selectedAge) {
                                  setState(() {
                                    age = selectedAge;
                                    ageController.text = selectedAge;
                                  });
                                },
                              ),
                              const SizedBox(height: 16.0),

                              // Gender
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: const Text('Gender'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: ['Male', 'Female'].map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                            ],
                            SizedBox(
                              height: 16,
                            ),
                            ElevatedButton.icon(
                              onPressed: () => pickImage('Student'),
                              icon: const Icon(Icons.image),
                              label: const Text('Upload Student Card'),
                            ),
                            const SizedBox(height: 15.0),
                            // Add a dropdown for Project Type

                            _studentImage != null
                                ? Image.file(
                                    _studentImage!,
                                    height: 150,
                                    width: 150,
                                  )
                                : const Text('No image selected'),
                            if (_studentImage == null)
                              const Text(
                                'Please upload your Student Card',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),

                      // Show Phone Number if Seller is selected
                      if (selectedRole == 'Seller')
                        Column(
                          children: [
                            const SizedBox(height: 25.0),
                            TextFormField(
                              onSaved: (value) {
                                phoneNumber = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Phone Number';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Phone Number'),
                                hintText: 'Enter Phone Number',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Focus border color
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red, // Red border for errors
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            TextFormField(
                              onSaved: (value) {
                                shopName = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Shop name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Shop Name'),
                                hintText: 'Enter Shop Name',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: lightColorScheme
                                        .primary, // Focus border color
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red, // Red border for errors
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 25.0),

                      // i agree to the processing
                      Row(
                        children: [],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _areAllFieldsFilled()
                              ? () {
                                  createUser(); // Proceed with user creation
                                }
                              : null, // Disable button if fields are not filled
                          child: const Text('Sign up'),
                        ),
                      ),

                      const SizedBox(
                        height: 30.0,
                      ),

                      // sign up divider
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
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up social media logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                      const SizedBox(height: 25.0),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
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

  Widget _buildSearchableField({
    required String label,
    required TextEditingController controller,
    required List<String> suggestions,
    required ValueChanged<String> onSuggestionSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              label: Text(label),
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Colors.black26),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: lightColorScheme.primary,
                  width: 2.0,
                ),
              ),
            ),
            onTap: () async {
              // Trigger the TypeAhead modal when field is tapped
              final selectedValue = await showModalBottomSheet<String>(
                context: context,
                builder: (context) {
                  return ListView(
                    children: suggestions.map((suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                        onTap: () {
                          Navigator.pop(context, suggestion);
                        },
                      );
                    }).toList(),
                  );
                },
              );
              if (selectedValue != null) {
                onSuggestionSelected(selectedValue);
              }
            },
          ),
        ],
      ),
    );
  }

  bool _areAllFieldsFilled() {
    if (projectType == 'Hardware') {
      return age != null && gender != null && location != null;
    } else if (projectType == 'Software') {
      return backend != null &&
          frontend != null &&
          database != null &&
          age != null &&
          gender != null;
    }
    return false;
  }
}
