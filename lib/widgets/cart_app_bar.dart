import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/shop_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartAppBar extends StatelessWidget {
  final VoidCallback onCartUpdated; // Callback to refresh the cart

  const CartAppBar({super.key, required this.onCartUpdated});

  Future<bool> emptyCart() async {
    try {
      // Get the JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print('Error: No JWT token found');
        return false;
      }

      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final response = await http.delete(
        Uri.parse('$baseUrl/GP/v1/shop/cart/deleteFromCart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Cart emptied successfully: ${response.body}');
        return true;
      } else {
        print('Failed to empty cart: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error emptying cart: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopHomePage(),
                ),
              );
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Color(0xFF3B4280),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Cart",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B4280),
              ),
            ),
          ),
          Spacer(),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 30,
              color: Color(0xFF3B4280),
            ),
            onSelected: (value) async {
              if (value == 'empty_cart') {
                final success = await emptyCart(); // Call the API to empty the cart
                if (success) {
                  onCartUpdated(); // Refresh the cart after successful API call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cart has been emptied!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to empty the cart.')),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'empty_cart',
                child: Text('Empty Cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
