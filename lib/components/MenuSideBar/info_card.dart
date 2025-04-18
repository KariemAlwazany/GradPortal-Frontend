import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.name,
    required this.role,
  });
  final String name, role;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(CupertinoIcons.person, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        role,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
