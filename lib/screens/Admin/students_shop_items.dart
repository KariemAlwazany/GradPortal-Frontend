import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoreItemsScreen extends StatefulWidget {
  final String shopName = "Students Shop";

  @override
  _StoreItemsScreenState createState() => _StoreItemsScreenState();
}

class _StoreItemsScreenState extends State<StoreItemsScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  Set<int> favoriteItems = {}; // Track favorited item IDs

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }

  Future<void> fetchAllItems() async {
    final itemsUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/getShopItems');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        itemsUrl.replace(queryParameters: {'shop_name': widget.shopName.toString()}),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            items = List.from(data['items'] ?? []);
            isLoading = false;
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
          SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
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

  void toggleFavorite(int itemId) {
    setState(() {
      if (favoriteItems.contains(itemId)) {
        favoriteItems.remove(itemId);
      } else {
        favoriteItems.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName ?? 'Items'),
        backgroundColor: Color(0xFF3B4280),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text(
                    'No items available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isFavorite = favoriteItems.contains(item['Item_ID']);
                    return ItemCard(
                      item: item,
                      isFavorite: isFavorite,
                      onFavoriteToggle: (itemId) {
                        toggleFavorite(itemId);
                      },
                    );
                  },
                ),
    );
  }
}
class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFavorite; // Pass favorite status
  final Function(int) onFavoriteToggle; // Callback for toggling favorite

  const ItemCard({
    Key? key,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  Future<void> addToFavorites(BuildContext context, int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/favoriteItems/addFavoriteItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"item_id": itemId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added to favorites successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item to favorites')),
        );
      }
    } catch (e) {
      print("Error adding to favorites: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String itemName = item['item_name'] ?? 'No name';
    String description = item['Description'] ?? 'No description';
    int price = item['Price'] is int ? item['Price'] : int.tryParse(item['Price'].toString()) ?? 0;
    int itemId = item['Item_ID'] ?? 0;
    String base64Image = item['Picture'] ?? '';

    Uint8List? imageBytes;
    if (base64Image.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64Image);
      } catch (e) {
        print("Error decoding Base64 image: $e");
      }
    }

    Widget imageWidget = imageBytes != null && imageBytes.isNotEmpty
        ? Image.memory(imageBytes, width: double.infinity, height: 160, fit: BoxFit.cover)
        : Center(child: Text('No image available', style: TextStyle(color: Colors.grey)));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemScreen(item: item),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageWidget,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B4280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 1, // Restrict description to one line
                    overflow: TextOverflow.ellipsis, // Add ellipsis if description overflows
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${price.toString()} NIS",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              addToFavorites(context, itemId);
                              onFavoriteToggle(itemId); // Trigger favorite toggle callback
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF3B4280), size: 20),
                            onPressed: () {
                              // Trigger add-to-cart functionality
                            },
                          ),
                        ],
                      ),
                    ],
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
