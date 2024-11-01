import 'package:flutter/material.dart';
import 'package:flutter_project/components/info_card.dart';
import 'package:flutter_project/components/side_menu_tile.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:flutter_project/screens/main_screen.dart'; // Ensure this points to your actual main screen
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/utils/rive_utils.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;
  Color activeTileColor = const Color(0xFF4C53A5);

  String userName = "Loading...";
  String userRole = "Loading...";
  bool showProjectsButton = false; // Control visibility of "Return to Projects" button

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final profileUrl = Uri.parse('http://192.168.0.131:3000/GP/v1/seller/profile');
    final roleUrl = Uri.parse('http://192.168.0.131:3000/GP/v1/seller/role');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); 

      if (token == null) {
        setState(() {
          userName = "Not logged in";
          userRole = "";
        });
        return;
      }

      // First API
      final profileResponse = await http.get(
        profileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        setState(() {
          userName = profileData['Username'] ?? "No name found";
        });
      } else {
        setState(() {
          userName = "Error loading user";
        });
      }

      // Second API
      final roleResponse = await http.get(
        roleUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (roleResponse.statusCode == 200) {
        final roleData = json.decode(roleResponse.body);
        final role = roleData['Role'];
        setState(() {
          userRole = role ?? "No role found";
          // Show the button only if the role is not "Seller"
          showProjectsButton = (userRole != "Seller");
        });
      } else {
        setState(() {
          userRole = "Error loading role";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Network error";
        userRole = "Network error";
        print(e);
      });
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
                // Info Card displaying dynamic user data
                InfoCard(
                  name: userName,
                  role: userRole,
                ),
                // Rest of your SideMenu widgets
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
                ...sideMenus.map((menu) => SideMenuTile(
                      menu: menu,
                      riveonInit: (artboard) {
                        final controller = RiveUtils.getRiveController(
                          artboard,
                          stateMachineName: menu.stateMachineName,
                        );
                        if (controller != null) {
                          menu.input = controller.findSMI("active") as SMIBool?;
                        }
                      },
                      press: () {
                        setState(() {
                          selectedMenu = menu;
                          activeTileColor = const Color(0xFF4CAF50);
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            activeTileColor = const Color(0xFF4C53A5);
                          });
                        });
                      },
                      isActive: selectedMenu == menu,
                    )),
                const Spacer(),

                // Conditionally show the "Return to Projects" button and divider
                Visibility(
                  visible: showProjectsButton,
                  child: Column(
                    children: [
                      const Divider(color: Colors.white24, height: 1),
                      SideMenuTile(
                        menu: RiveAsset(
                          'assets/RiveAssets/projects_icon.riv', // Replace with your projects icon asset
                          artboard: "PROJECTS",
                          stateMachineName: "PROJECTS_interactivity",
                          title: "Return to Projects",
                        ),
                        riveonInit: (artboard) {
                          // Initialize Rive animations or state machine if required
                        },
                        press: () {
                          // Navigate to the ProjectScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainPage(), // Your project screen
                            ),
                          );
                        },
                        isActive: false,
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: SideMenuTile(
                    menu: RiveAsset(
                      'assets/RiveAssets/logout_icon.riv',
                      artboard: "LOGOUT",
                      stateMachineName: "LOGOUT_interactivity",
                      title: "Logout",
                    ),
                    riveonInit: (artboard) {
                      final controller = RiveUtils.getRiveController(
                        artboard,
                        stateMachineName: "LOGOUT_interactivity",
                      );
                    },
                    press: () async {
                      // Clear token and navigate to WelcomeScreen
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('jwt_token');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },////
                    ////
                    isActive: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
