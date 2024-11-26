import 'package:flutter/material.dart';
import 'package:flutter_project/components/MenuSideBar/side_bar_menu.dart';
import 'package:flutter_project/screens/cart_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For handling image files
import 'package:badges/badges.dart' as badges;
import 'package:flutter_project/widgets/categories_widget.dart';
import 'package:flutter_project/widgets/items_widget.dart';

class ShopHomePage extends StatefulWidget {
  @override
  _ShopHomePageState createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold
  File? _image; // To store the image file
  int _cartItemCount = 0; // Track cart item count

  // Function to open the camera
  Future<void> _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Convert the picked image to a File
      });
    }
  }

  // Function to increment the cart item count
  void _incrementCartItemCount() {
    setState(() {
      _cartItemCount++;
    });
  }

  // Function to decrement the cart item count
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
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      drawer: SideMenu(), // Add the SideBar as a drawer
      body: ListView(
        children: [
          // App Bar with cart icon and badge
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(25),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Open the drawer using the GlobalKey reference
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Icon(
                    Icons.sort,
                    size: 30,
                    color: Color(0xFF3B4280),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Components Shop",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B4280),
                    ),
                  ),
                ),
                Spacer(),
                badges.Badge(
                  showBadge:
                      _cartItemCount > 0, // Show badge only when count > 0
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 32,
                        color: Color(0xFF3B4280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              color: Color(0xFFEDECF2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                // Search Widget
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        height: 50,
                        width: 298,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search here...",
                          ),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 27,
                          color: Color(0xFF3B4280),
                        ),
                        onPressed: _openCamera, // Open the camera when pressed
                      ),
                    ],
                  ),
                ),

                // Categories
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B4280),
                    ),
                  ),
                ),

                // CATEGORIES WIDGET
                CategoriesWidget(),

                // Items
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(
                    "Best Selling",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B4280),
                    ),
                  ),
                ),

                // Items Widget - Passing the increment and decrement functions to update cart count
                ItemsWidget(
                  onCartIconPressed: _incrementCartItemCount,
                  onCartIconRemoved: _decrementCartItemCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
