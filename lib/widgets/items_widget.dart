// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For base64 decoding if needed
import 'dart:typed_data';


class ItemsWidget extends StatefulWidget {
  const ItemsWidget({super.key});

  @override
  State<ItemsWidget> createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
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
    final response = await http.get(
      itemsUrl,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
        setState(() {
          items = List.from(data['items'] ?? []); // Convert 'items' to a list
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF2),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Items Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Your Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
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
                            fetchItemsCallback: fetchItems,
                          );
                        } else {
                          return const SizedBox(); // Return empty widget if item is not a map
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final BuildContext parentContext;
  final Function fetchItemsCallback;

  const ItemCard({super.key, required this.item, required this.parentContext, required this.fetchItemsCallback});

  @override
  Widget build(BuildContext context) {
    String itemName = item['item_name'] ?? 'No name';
    String description = item['Description'] ?? 'No description';
    String price = item['Price'] != null ? "${item['Price']} NIS" : 'No price';
    String category = item['Category'] ?? 'Motors'; // Assuming 'Motors' as default
    String type = item['Type'] ?? '';
    bool available = item['Available'] ?? false;
    int quantity = item['Quantity'] ?? 0;
    int itemId = item['Item_ID'] ?? 0;

    if (itemId == 0) {
      return const SizedBox();
    }

    // Handle Picture field if it's a Base64 string
    Uint8List? pictureBytes;
    if (item['Picture'] != null && item['Picture'] is String) {
      try {
        pictureBytes = base64Decode(item['Picture']);
      } catch (e) {
        print("Error decoding base64: $e");
      }
    }

    Widget imageWidget = pictureBytes != null && pictureBytes.isNotEmpty
        ? Image.memory(pictureBytes)
        : const Center(child: Text('No image available'));

    return Card(
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
    );
  }
}






















