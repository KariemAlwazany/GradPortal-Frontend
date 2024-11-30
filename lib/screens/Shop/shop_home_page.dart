import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/cart_screen.dart';
import 'package:flutter_project/components/MenuSideBar/side_bar_menu.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_project/widgets/categories_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For base64 decoding if needed
import 'dart:typed_data';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  _ShopHomePageState createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // GlobalKey for Scaffold
  File? _image; // To store the image file
  int _cartItemCount = 0; // Track cart item count
  List<dynamic> items = []; // Store fetched items
  bool isLoading = false; // Loading state for items
  String selectedCategory = ''; // Store selected category

  // Function to open the camera
  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

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


  Future<void> fetchItems() async {
    final itemsUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/getAllItems');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true; // Start loading
      });

      final response = await http.get(
        itemsUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            items = List.from(data['items'] ?? []); // Update items list
            isLoading = false; // Stop loading when data is received
          });
        } else {
          setState(() {
            items = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items found')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load items')),
        );
      }
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching items')),
      );
    }
  }

Future<void> fetchItemsByCategory(String category) async {
  final itemsUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/getItemsByCategory')
      .replace(queryParameters: {'Category': category});  // Send category as a query parameter

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  try {
    setState(() {
      isLoading = true; // Start loading
      selectedCategory = category; // Set selected category
    });

    final response = await http.get(
      itemsUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("API Response (Category): $data");  // Log the API response

      if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
        setState(() {
          items = List.from(data['items'] ?? []); // Update items state with fetched data
          isLoading = false; // Stop loading when data is received
        });
      } else {
        setState(() {
          items = []; // No items found for the selected category
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items found in this category')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load items by category')),
      );
    }
  } catch (e) {
    print("Error fetching items by category: $e");
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error fetching items by category')),
    );
  }
}


  @override
  void initState() {
    super.initState();
    fetchItems(); // Fetch all items when the page loads
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
                    _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the GlobalKey reference
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

                CategoriesWidget(
                  onCategorySelected: (category) {
                    fetchItemsByCategory(category); // Fetch items based on the selected category
                  },
                ), // Categories widget

                // Items Section
                const SizedBox(height: 8),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true, // Use shrinkWrap to make it scrollable within the ListView
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item is Map<String, dynamic>) {
                            return ItemCard(
                              item: item,
                              parentContext: context,
                              // fetchItemsCallback: fetchItems,
                            );
                          } else {
                            return const SizedBox(); // Return empty widget if item is not a map
                          }
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final BuildContext parentContext;

  const ItemCard({
    Key? key,
    required this.item,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extracting data from the item map
    String itemName = item['item_name'] ?? 'No name';
    String description = item['Description'] ?? 'No description';
    String price = item['Price'] != null ? "${item['Price']} NIS" : 'No price';
    String category = item['Category'] ?? 'Motors'; // Assuming 'Motors' as default
    bool available = item['Available'] ?? false;
    int quantity = item['Quantity'] ?? 0;
    String base64Image = item['Picture'] ?? ''; // Base64 image string

    // Handle Base64 image decoding
    Uint8List? imageBytes;
    if (base64Image.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64Image); // Decode Base64 image
      } catch (e) {
        print("Error decoding Base64 image: $e");
      }
    }

    // Default fallback for missing or invalid image
    Widget imageWidget = imageBytes != null && imageBytes.isNotEmpty
        ? Image.memory(imageBytes)
        : const Center(child: Text('No image available'));

    return GestureDetector(
      onTap: () {
        // Navigate to ItemScreen and pass the item data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemScreen(item: item), // Pass the item data
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageWidget,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B4280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF3B4280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B4280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
