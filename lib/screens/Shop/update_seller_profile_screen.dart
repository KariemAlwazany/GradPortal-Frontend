import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/update_user_student_screen.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String location = 'Loading...';
  String username = 'Loading...';
  String fullName = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = 'Loading...';
  String role = 'Loading...';
  String shopName = 'Loading...';

  LatLng? userLocation;
  LatLng? selectedLocation;
  late GoogleMapController mapController;

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
          shopName = "Not logged in";
          location = "Not logged in";
        });
        return;
      }

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

      final profileResponse = await http.get(
        userUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        setState(() {
          phoneNumber = profileData['phone_number'] ?? "No phone number found";
          shopName = profileData['Shop_name'] ?? "No shop name found";
          location = "${profileData['city']} ${profileData['longitude']} ${profileData['latitude']}" ?? "Location not found";
        });
      } else {
        setState(() {
          phoneNumber = "Error loading phone number";
          shopName = "Error loading shop name";
          location = "Error loading location";
        });
      }
    } catch (e) {
      setState(() {
        phoneNumber = "Error loading data";
        shopName = "Error loading data";
        location = "Error loading location";
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

    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    Map<String, dynamic> updates = {};
    if (usernameController.text.isNotEmpty) updates['Username'] = usernameController.text;
    if (phoneNumberController.text.isNotEmpty) updates['phone_number'] = phoneNumberController.text;
    if (fullNameController.text.isNotEmpty) updates['FullName'] = fullNameController.text;
    if (emailController.text.isNotEmpty) updates['Email'] = emailController.text;
    if (passwordController.text.isNotEmpty) updates['Password'] = passwordController.text;
    if (shopNameController.text.isNotEmpty) updates['Shop_name'] = shopNameController.text;

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
        fetchUserData();
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
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied. We cannot access location.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      selectedLocation = userLocation;
    });
  }

  Future<void> _saveLocationToApi() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location.')),
      );
      return;
    }

    final latitude = selectedLocation!.latitude;
    final longitude = selectedLocation!.longitude;

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final locationUrl = Uri.parse('$baseUrl/GP/v1/users/updateUserLocation');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      final response = await http.patch(
        locationUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['data']['user']['city'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location updated successfully: $city')),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update location.')),
      );
    }
  }

  void _showMapDialog() async {
    await _getUserLocation();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Location'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: userLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: userLocation!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => mapController = controller,
                        myLocationEnabled: true,
                        markers: selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('selectedLocation'),
                                  position: selectedLocation!,
                                ),
                              }
                            : {},
                        onTap: (LatLng tappedPoint) {
                          setDialogState(() {
                            selectedLocation = tappedPoint;
                          });
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveLocationToApi();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B4280),
                  ),
                  child: const Text(
                    'Save Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = role != "Student" && role != "User";

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
        child: Column(
          children: [
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
                    icon: LineAwesomeIcons.mail_bulk,
                    isEnabled: isEditable,
                  ),
                  _buildTextField(
                    controller: phoneNumberController,
                    label: phoneNumber,
                    hint: phoneNumber,
                    icon: LineAwesomeIcons.phone,
                    isEnabled: true,
                  ),
                  _buildTextField(
                    controller: shopNameController,
                    label: shopName,
                    hint: shopName,
                    icon: LineAwesomeIcons.store,
                    isEnabled: isEditable,
                  ),
                  _buildTextField(
                    controller: locationController,
                    label: location,
                    hint: location,
                    icon: LineAwesomeIcons.map_pin,
                    isEnabled: true,
                  ),
                  // Password field
                  _buildTextField(
                    controller: passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    icon: LineAwesomeIcons.lock,
                    isPassword: true,
                    isEnabled: true,
                  ),
                  // Rewrite Password field
                  _buildTextField(
                    controller: confirmPasswordController,
                    label: "Rewrite Password",
                    hint: "Rewrite your password",
                    icon: LineAwesomeIcons.lock,
                    isPassword: true,
                    isEnabled: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showMapDialog,
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text(
                      "Open Map",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4280),
                    ),
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
