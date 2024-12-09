// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OutOfStockScreen extends StatefulWidget {
  @override
  _OutOfStockScreenState createState() => _OutOfStockScreenState();
}

class _OutOfStockScreenState extends State<OutOfStockScreen> {
  List<Map<String, dynamic>> outOfStockItems = [];

  @override
  void initState() {
    super.initState();
    fetchOutOfStockItems();
  }

  // Fetch out-of-stock items from API
  Future<void> fetchOutOfStockItems() async {
    final outOfStockUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/outOfStockItemsForSeller');

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
        outOfStockUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            outOfStockItems = List<Map<String, dynamic>>.from(data['items']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('There is no out-of-stock items')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('There is no out-of-stock items')),
        );
      }
    } catch (e) {
      print("Error fetching out-of-stock items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching out-of-stock items')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B4280),
        title: const Text(
          'Out of Stock',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Check if there are any out-of-stock items
            if (outOfStockItems.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No items out of stock!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            if (outOfStockItems.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: outOfStockItems.length,
                  itemBuilder: (context, index) {
                    final item = outOfStockItems[index];
                    return _buildProductCard(item, context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method to build product card
  Widget _buildProductCard(Map<String, dynamic> item, BuildContext context) {
    // Decode the base64 image
    ImageProvider image;
    if (item['Picture'].isNotEmpty) {
      image = MemoryImage(base64Decode(item['Picture']));
    } else {
      image = const AssetImage('assets/placeholder_image.png');
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Add image (if any)
            Image(image: image, width: 50, height: 50, fit: BoxFit.cover),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item_name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['Description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item['Price']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Out of Stock',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Button to manage stock (opens dialog)
            ElevatedButton(
              onPressed: () {
                _openRestockDialog(context, item, fetchOutOfStockItems);
              },
              child: Text('Restock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B4280),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to open the dialog to restock the item
  void _openRestockDialog(BuildContext context, Map<String, dynamic> item, Function refreshCallback) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restock ${item['item_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Quantity to Restock',
                  hintText: 'Quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int quantityToRestock =
                    int.tryParse(quantityController.text) ?? 0;

                if (quantityToRestock > 0) {
                  // Make API call to update quantity
                  final success = await _restockItem(item['Item_ID'], quantityToRestock);
                  
                  if (success) {
                    setState(() {
                      item['Quantity'] += quantityToRestock;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['item_name']} restocked!')),
                    );

                    // Call the refresh callback to update the item list
                    refreshCallback();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error restocking item')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity')),
                  );
                }
              },
              child: Text('Restock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B4280),
              ),
            ),
          ],
        );
      },
    );
  }

  // API call to restock item
  Future<bool> _restockItem(int itemId, int quantity) async {
    final restockUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/updateItem/$itemId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      return false;
    }

    try {
      final response = await http.patch(
        restockUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',  // Set content type to JSON
        },
        body: json.encode({
          'Quantity': quantity,  // Send quantity in the request body
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error restocking item: $e");
      return false;
    }
  }
}
