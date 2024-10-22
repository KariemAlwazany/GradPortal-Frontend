import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  late SMIBool? input;

  RiveAsset(this.src,
      {required this.artboard,
      required this.stateMachineName,
      required this.title,
      this.input});

  set setInput(SMIBool status) {
    input = status;
  }
}

// Bottom navigation menu
List<RiveAsset> bottomNavs = [
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "CHAT", stateMachineName: "CHAT_Interactivity", title: "Chat"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "SEARCH",
      stateMachineName: "SEARCH_Interactivity",
      title: "Search"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "TIMER",
      stateMachineName: "TIMER_Interactivity",
      title: "Chat"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "BELL",
      stateMachineName: "BELL_Interactivity",
      title: "Notifications"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
      title: "Profile"),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "LOGOUT",   // New logout icon
      stateMachineName: "LOGOUT_Interactivity",
      title: "Logout"),
];

// Side menu items
List<RiveAsset> sideMenus = [
  RiveAsset('assets/RiveAssets/profile_icon.riv',   // Update icon to profile icon
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
      title: "Profile"),  // Changed from "Projects" to "Profile"
  RiveAsset('assets/RiveAssets/shop_icon.riv',   // Update icon to shop icon
      artboard: "SHOP",
      stateMachineName: "SHOP_Interactivity",
      title: "Shop"),  // Changed from "Search" to "Shop"
  RiveAsset('assets/RiveAssets/icons.riv',
      artboard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
      title: "Favorites"),  // No change
  RiveAsset('assets/RiveAssets/icons.riv',
      artboard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
      title: "Help"),  // No change
];
