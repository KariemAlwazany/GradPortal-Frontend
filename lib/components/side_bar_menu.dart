import 'package:flutter/material.dart';
import 'package:flutter_project/components/info_card.dart';
import 'package:flutter_project/components/side_menu_tile.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:flutter_project/utils/rive_utils.dart';
import 'package:rive/rive.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;
  Color activeTileColor = const Color(0xFF6792F5); // Default active color

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 288,
      child: Scaffold(
        body: Container(
          width: 288,
          height: double.infinity,
          color: const Color(0xFF17203A),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InfoCard(
                  name: "Yazan",
                  profession: "Programmer",
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
                            Color(0xFF4CAF50); // Custom color on press
                      });

                      // Optionally reset the color back after a short delay
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          activeTileColor = Color(0xFF6792F5); // Default color
                        });
                      });
                    },
                    isActive: selectedMenu == menu,
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
