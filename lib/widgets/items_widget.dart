// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';

class ItemsWidget extends StatefulWidget {
  final VoidCallback onCartIconPressed;
  final VoidCallback onCartIconRemoved;

  const ItemsWidget({super.key, required this.onCartIconPressed, required this.onCartIconRemoved});

  @override
  _ItemsWidgetState createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  List<bool> isInCart = List<bool>.filled(7, false); // Track cart status
  List<bool> isFavorite = List<bool>.filled(7, false); // Track favorite status

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 0.68,
      physics: NeverScrollableScrollPhysics(), // Disables scrolling in GridView
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        for (int i = 1; i < 8; i++)
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B4280),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "-50%",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Favorite and Cart Icons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite[i - 1]
                                ? Icons.favorite // Filled favorite icon
                                : Icons.favorite_border, // Outlined favorite icon
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite[i - 1] = !isFavorite[i - 1];
                            });

                            // Show a snackbar message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFavorite[i - 1]
                                    ? 'Added to favorites'
                                    : 'Removed from favorites'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isInCart[i - 1]
                                ? Icons.shopping_cart // Filled cart icon if in cart
                                : Icons.shopping_cart_outlined, // Outlined cart icon otherwise
                            color: Color(0xFF3B4280),
                          ),
                          onPressed: () {
                            setState(() {
                              isInCart[i - 1] = !isInCart[i - 1];
                            });

                            // If added to cart, increment the cart count
                            if (isInCart[i - 1]) {
                              widget.onCartIconPressed();
                            } else {
                              // If removed from cart, decrement the cart count
                              widget.onCartIconRemoved();
                            }

                            // Show a snackbar message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isInCart[i - 1]
                                    ? 'Added to cart'
                                    : 'Removed from cart'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemScreen(),
                        ),
                      );                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/images/$i.png",
                        height: 70,
                        width: 70,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Product Title
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Product Title",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3B4280),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Product Description
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Product Description",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3B4280),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Adding space between text and price
                // Price and Cart Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$55",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B4280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
