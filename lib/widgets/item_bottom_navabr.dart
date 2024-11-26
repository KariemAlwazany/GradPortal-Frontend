// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ItemBottomNavBar extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return BottomAppBar(
        height: 90,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$120",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B4280),
              ),
            ),
            ElevatedButton.icon(
              onPressed: (){},
              icon: Icon(CupertinoIcons.cart_badge_plus),
              label: Text(
                "Add To Cart",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Color(0xFF3B4280)),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 13, horizontal: 15)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
                ),
              ),
              ),
          ],
        ),
    );
  }
}