// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_project/screens/add_item_screen.dart';
import 'package:flutter_project/widgets/profile_menu_widget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SellerProfileScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B4280),
          ),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(isDark? LineAwesomeIcons.sun : LineAwesomeIcons.moon))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image(image: AssetImage("assets/images/logo.png"),)),
              ),
              const SizedBox(height: 10),
              Text(
                "Profile Header",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B4280),
                ),
              ),
              Text(
                "Profile subHeader",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B4280),
                ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200, // Set the width to 200
                  child: ElevatedButton(
                    onPressed: (){},
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B4280),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C53A5),
                      side: BorderSide.none,
                      shape: StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                //MENU
                ProfileMenuWidget(title: "Settings", icon: LineAwesomeIcons.cog, onPress: (){}),
                ProfileMenuWidget(title: "Components Selled", icon: LineAwesomeIcons.wallet, onPress: (){}),
                ProfileMenuWidget(title: "Add Items", icon: LineAwesomeIcons.plus, onPress: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen()));
                }),
                ProfileMenuWidget(title: "Account Information", icon: LineAwesomeIcons.info, onPress: (){}),
                ProfileMenuWidget(
                  title: "Logout",
                  icon: LineAwesomeIcons.alternate_sign_out,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: (){}
                  ),
            ],
          ),
        ),
      ),
    );
  }
}