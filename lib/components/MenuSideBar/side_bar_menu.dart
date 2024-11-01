import 'package:flutter/material.dart';
import 'package:flutter_project/components/MenuSideBar/info_card.dart';
import 'package:flutter_project/components/MenuSideBar/side_menu_tile.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:flutter_project/utils/rive_utils.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For storing/retrieving JWT token
import 'dart:convert';
import 'package:flutter_project/screens/login/signin_screen.dart';

class SideMenu extends StatefulWidget {
  final Function(int, String) onMenuItemClicked; // Callback function

  const SideMenu({super.key, required this.onMenuItemClicked});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
}

Future<Map<String, dynamic>?> getUser() async {
  final String? token = await getToken();
  final response = await http.get(
    Uri.parse('http://192.168.88.7:3000/GP/v1/users/me'),
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

class _SideMenuState extends State<SideMenu> {
  String fullName = "Loading...";
  String role = "Loading..."; // Default value before data is fetched
  RiveAsset selectedMenu = sideMenus.first;
  Color activeTileColor = const Color(0xFF6792F5); // Default active color

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget initializes
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await getUser();
      if (userData != null) {
        setState(() {
          fullName = userData['data']['data']['FullName'] ?? 'Unknown User';
          role = userData['data']['data']['Role'] ?? 'Unknown Role';
        });
      }
    } catch (error) {
      print('Failed to load user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 288,
      child: Scaffold(
        body: Container(
          width: 288,
          height: double.infinity,
          color: const Color(0xFF3B4280),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display user data dynamically
                InfoCard(
                  name: fullName, // Use the full name from the state
                  profession: role, // Use the role from the state
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                  child: Text(
                    "Browse".toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.white70),
                  ),
                ),
                // Iterate through each menu and display it
                ...sideMenus.map(
                  (menu) => SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      final controller = RiveUtils.getRiveController(
                        artboard,
                        stateMachineName: menu.stateMachineName,
                      );

                      if (controller != null) {
                        menu.input = controller.findSMI("active") as SMIBool?;
                        if (menu.input == null) {
                          print("Input 'active' not found in state machine.");
                        }
                      } else {
                        print(
                            "Controller not found for artboard: ${menu.artboard}");
                      }
                    },
                    press: () {
                      // Change the active background color manually
                      setState(() {
                        selectedMenu = menu;
                        activeTileColor =
                            const Color(0xFF4CAF50); // Custom color on press
                      });

                      // Navigate to different pages based on the menu selected
                      if (menu.title == "Projects") {
                        widget.onMenuItemClicked(0, "Projects ListView");
                      } else if (menu.title == "Profile") {
                        widget.onMenuItemClicked(3, "Profile Page");
                      } else if (menu.title == "Favorites") {
                        widget.onMenuItemClicked(1, "Favorites Page");
                      } else if (menu.title == "Store") {
                        widget.onMenuItemClicked(2, "Store Page");
                      }

                      // Optionally reset the color back after a short delay
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          activeTileColor =
                              const Color(0xFF6792F5); // Default color
                        });
                      });
                    },
                    isActive: selectedMenu == menu,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 24.0),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Handle logout action
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignInScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
