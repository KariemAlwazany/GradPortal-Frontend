// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/components/MenuSideBar/info_card.dart';
import 'package:flutter_project/components/MenuSideBar/side_menu_tile.dart';
import 'package:flutter_project/components/navbar/community_navabar.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:flutter_project/screens/Community/chat_screen.dart';
import 'package:flutter_project/screens/Community/main_screen.dart';
import 'package:flutter_project/screens/NormalUser/main_screen.dart';
import 'package:flutter_project/screens/Shop/favorite_items_screen.dart';
import 'package:flutter_project/screens/Shop/help_screen.dart';
import 'package:flutter_project/screens/Shop/profile_screen.dart';
import 'package:flutter_project/screens/Shop/shop_management_screen.dart';
import 'package:flutter_project/screens/Shop/store_shops_screen.dart';
import 'package:flutter_project/screens/Student/student.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/utils/rive_utils.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, void Function(int index, String newTitle)? onMenuItemClicked});

  @override
  State<SideMenu> createState() => _SideMenuState();
}
class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenus.first;
  Color activeTileColor = const Color(0xFF4C53A5);

  String userName = "Loading...";
  String userRole = "Loading...";
  bool showProjectsButton = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final roleUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/role');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          userName = "Not logged in";
          userRole = "Not logged in";
          isLoggedIn = false;
        });
        return;
      }
      setState(() {
        isLoggedIn = true;
      });
      final response = await http.get(
        roleUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['Username'] ?? "No name found";
          userRole = data['Role'] ?? "No role found";
        });

        if (userRole == "Seller") {
          showProjectsButton = false;
        } else if (userRole == "Student" || userRole == "User") {
          showProjectsButton = true;
        }
      } else {
        setState(() {
          userName = "Error loading user";
          userRole = "Error loading Role";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error loading user";
        userRole = "Error loading Role";
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
                InfoCard(
                  name: userName,
                  role: userRole,
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
                ..._getSideMenuItems().map((menu) => SideMenuTile(
                      menu: menu,
                      riveonInit: (artboard) {
                        final controller = RiveUtils.getRiveController(
                          artboard,
                          stateMachineName: menu.stateMachineName,
                        );
                        menu.input = controller.findSMI("active") as SMIBool?;
                      },
                      press: () {
                        setState(() {
                          selectedMenu = menu;
                          activeTileColor = const Color(0xFF4CAF50);
                        });
                        _navigateToScreen(menu.title);
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            activeTileColor = const Color(0xFF4C53A5);
                          });
                        });
                      },
                      isActive: selectedMenu == menu,
                    )),
                const Spacer(),

                Visibility(
                  visible: showProjectsButton,
                  child: Column(
                    children: [
                      const Divider(color: Colors.white24, height: 1),
                      SideMenuTile(
                        menu: RiveAsset(
                          'assets/RiveAssets/projects_icon.riv',
                          artboard: "PROJECTS",
                          stateMachineName: "PROJECTS_interactivity",
                          title: "Return to Projects",
                        ),
                        riveonInit: (artboard) {
                          final controller = RiveUtils.getRiveController(
                            artboard,
                            stateMachineName: "PROJECTS_interactivity",
                          );
                        },
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentPage(),
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
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('jwt_token');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        (Route<dynamic> route) => false, 
                      );
                    },
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

  List<RiveAsset> _getSideMenuItems() {
    if (isLoggedIn) {
      if (userRole == "Seller") {
        return [
          RiveAsset('assets/RiveAssets/profile_icon.riv', artboard: "PROFILE", stateMachineName: "PROFILE_interactivity", title: "Profile"),
          RiveAsset('assets/RiveAssets/shop_icon.riv', artboard: "SHOP", stateMachineName: "SHOP_interactivity", title: "Shop Management"),
          RiveAsset('assets/RiveAssets/favorites_icon.riv', artboard: "COMMUNITY", stateMachineName: "COMMUNITY_interactivity", title: "Community"),
          RiveAsset('assets/RiveAssets/help_icon.riv', artboard: "HELP", stateMachineName: "HELP_interactivity", title: "Help"),
        ];
      } else if (userRole == "Student" || userRole == "User") {
        return [
          RiveAsset('assets/RiveAssets/profile_icon.riv', artboard: "PROFILE", stateMachineName: "PROFILE_interactivity", title: "Profile"),
          RiveAsset('assets/RiveAssets/store_shops_icon.riv', artboard: "STORE_SHOPS", stateMachineName: "STORE_SHOPS_interactivity", title: "Store Shops"),
          RiveAsset('assets/RiveAssets/favorites_icon.riv', artboard: "FAVORITES", stateMachineName: "FAVORITES_interactivity", title: "Favorites"),
          RiveAsset('assets/RiveAssets/favorites_icon.riv', artboard: "COMMUNITY", stateMachineName: "COMMUNITY_interactivity", title: "Community"),
          RiveAsset('assets/RiveAssets/help_icon.riv', artboard: "HELP", stateMachineName: "HELP_interactivity", title: "Help"),
        ];
      }
      else if (userRole == "Delivery") {
        return [
          RiveAsset('assets/RiveAssets/profile_icon.riv', artboard: "PROFILE", stateMachineName: "PROFILE_interactivity", title: "Profile"),
          RiveAsset('assets/RiveAssets/favorites_icon.riv', artboard: "COMMUNITY", stateMachineName: "COMMUNITY_interactivity", title: "Community"),
          RiveAsset('assets/RiveAssets/help_icon.riv', artboard: "HELP", stateMachineName: "HELP_interactivity", title: "Help"),
        ];
      }
    } else {
      return [
        RiveAsset('assets/RiveAssets/help_icon.riv', artboard: "HELP", stateMachineName: "HELP_interactivity", title: "Help"),
      ];
    }
    return [];
  }

  void _navigateToScreen(String title) {
    switch (title) {
      case "Profile":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellerProfileScreen()),
        );
        break;
      case "Shop Management":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopManagementScreen()),
        );        
        break;
      case "Store Shops":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreShopsScreen()),
        );              
        break;
      case "Favorites":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoriteItemsScreen()),
        );                
        break;
      case "Community":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CommunityNavbar()),
        );                
        break;
      case "Help":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpScreen()),
        );     
        break;
    }
  }
}
