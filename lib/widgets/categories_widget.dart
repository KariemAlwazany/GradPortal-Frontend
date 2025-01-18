// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CategoriesWidget extends StatelessWidget {
  final Function(String) onCategorySelected; // Callback function to notify the selected category

  const CategoriesWidget({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryButton("All"),
          _categoryButton("Motors"),
          _categoryButton("Drivers"),
          _categoryButton("Microcontrollers"),
          _categoryButton("Sensors"),
          _categoryButton("3D Printing"),
          _categoryButton("Arms"),
          _categoryButton("Robotics"),
          _categoryButton("Others"),
        ],
      ),
    );
  }

  Widget _categoryButton(String category) {
    return GestureDetector(
      onTap: () {
        onCategorySelected(category); // Call the callback when category is tapped
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF3B4280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
