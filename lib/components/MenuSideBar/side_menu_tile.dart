import 'package:flutter/material.dart';
import 'package:flutter_project/models/rive_asset.dart';
import 'package:rive/rive.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.menu,
    required this.press,
    required this.riveonInit,
    required this.isActive,
    this.activeTileColor = const Color.fromRGBO(89, 99, 194, 1), // Default active color
  });

  final RiveAsset menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveonInit; // This callback is required for Rive animations
  final bool isActive;
  final Color activeTileColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Divider(color: Colors.white24, height: 1),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              height: 56,
              width: isActive ? 288 : 0,
              left: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? activeTileColor
                      : Colors.transparent, // Dynamic color change
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ListTile(
              onTap: press,
              leading: SizedBox(
                height: 34,
                width: 34,
                child: RiveAnimation.asset(
                  menu.src,
                  artboard: menu.artboard,
                  onInit: riveonInit, // Pass the riveonInit to the RiveAnimation.asset
                ),
              ),
              title:
                  Text(menu.title, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
