import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemBottomNavBar extends StatelessWidget {
  final Map<String, dynamic> item; // Accept the whole item
  final int quantity; // Accept the selected quantity

  ItemBottomNavBar({Key? key, required this.item, required this.quantity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String price = item['Price'] != null ? "${item['Price']} NIS" : 'No price';

    return BottomAppBar(
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            price, // Display the item price
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B4280),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _addToCartAPI(context), // Call the API on button press
            icon: Icon(CupertinoIcons.cart_badge_plus),
            label: Text(
              "Add To Cart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF3B4280)),
              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13, horizontal: 15)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCartAPI(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final cartData = {
      'items': [
        {
          'item_id': item['Item_ID'],
          'quantity': quantity,
          'price': item['Price'],
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/cart/createOrUpdateCart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(cartData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added to cart successfully')),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: ${errorData['message']}')),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while adding to cart')),
      );
    }
  }
}
