// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/checkout_screen.dart';

class CarBottomNavBar extends StatelessWidget {
  final double totalPrice; // Added totalPrice to accept the value dynamically

  const CarBottomNavBar({required this.totalPrice}); // Constructor to accept totalPrice

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 110, // Further reduce the height
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(), // Add Spacer to push the content to the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Price",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF3B4280),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${totalPrice.toStringAsFixed(2)} NIS",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B4280),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10), // Add some space between total and button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(totalPrice: totalPrice),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF3B4280),
                ),
                child: Text(
                  "Check Out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
