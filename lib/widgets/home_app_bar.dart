import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'items_widget.dart'; // Import the ItemsWidget class

class HomeAppBar extends StatefulWidget {
  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int _cartItemCount = 0; // Track the cart item count

  // Function to increment cart count
  void _incrementCartItemCount() {
    setState(() {
      _cartItemCount++;
    });
  }

  // Function to decrement cart count
  void _decrementCartItemCount() {
    setState(() {
      if (_cartItemCount > 0) {
        _cartItemCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(25),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  size: 30,
                  color: Color(0xFF4C53A5),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Components Shop",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C53A5),
                    ),
                  ),
                ),
                Spacer(),
                badges.Badge(
                  showBadge: _cartItemCount > 0, // Show badge only when count > 0
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red,
                    padding: EdgeInsets.all(7),
                  ),
                  badgeContent: Text(
                    _cartItemCount.toString(), // Display cart item count
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to CartScreen using named route
                        Navigator.pushNamed(context, '/cart');
                      },
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 32,
                        color: Color(0xFF4C53A5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ItemsWidget(
              onCartIconPressed: _incrementCartItemCount, // For adding to cart
              onCartIconRemoved: _decrementCartItemCount, // For removing from cart
            ),
          ),
        ],
      ),
    );
  }
}
