import 'package:flutter/material.dart';
import 'package:flutter_project/components/info_card.dart';
import 'package:flutter_project/components/side_menu_tile.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/utils/rive_utils.dart';
import 'package:rive/rive.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;
  Color activeTileColor = const Color(0xFF4C53A5); // Default active color

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 288,
      child: Scaffold(
        body: Container(
          width: 288,
          height: double.infinity,
          color: const Color(0xFF3B4280), // Background color
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card at the top of the menu
                const InfoCard(
                  name: "Yazan", // Pull from the database
                  role: "Seller", // Pull role from the database
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
                
                // Iterate through the side menus
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
                            const Color(0xFF4CAF50); // Custom active color
                      });

                      // Optionally reset the color after a delay
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          activeTileColor = const Color(0xFF4C53A5); // Reset to default
                        });
                      });
                    },
                    isActive: selectedMenu == menu,
                  ),
                ),

                // This will push the logout button to the bottom of the screen
                const Spacer(), 

                // Add the Logout option aligned at the bottom of the drawer
                Align(
                  alignment: Alignment.bottomCenter, // Ensure it stays at the bottom
                  child: SideMenuTile(
                    menu: RiveAsset(
                      'assets/RiveAssets/logout_icon.riv', // Logout icon
                      artboard: "LOGOUT",
                      stateMachineName: "LOGOUT_interactivity",
                      title: "Logout",
                    ),
                    riveonInit: (artboard) {
                      final controller = RiveUtils.getRiveController(
                        artboard,
                        stateMachineName: "LOGOUT_interactivity",
                      );
                      if (controller != null) {
                        // Handle the active state for the logout button if needed
                      }
                    },
                    press: () {
                      // Navigate to the logout screen on press
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(), // Navigate to the LogoutScreen
                        ),
                      );
                    },
                    isActive: false, // Logout should not have active state
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
