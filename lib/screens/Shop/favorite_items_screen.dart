import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'item_screen.dart';

class FavoriteItemsScreen extends StatefulWidget {
  @override
  _FavoriteItemsScreenState createState() => _FavoriteItemsScreenState();
}

class _FavoriteItemsScreenState extends State<FavoriteItemsScreen> {
  List<Map<String, dynamic>> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteItems();
  }

  Future<void> fetchFavoriteItems() async {
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

    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final apiUrl = Uri.parse('$baseUrl/GP/v1/shop/favoriteItems/getUserFavorites');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          favoriteItems = List<Map<String, dynamic>>.from(data['data'] ?? []);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch favorite items')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching favorite items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching favorite items')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites',
        style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B4280),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteItems.isEmpty
              ? const Center(child: Text('No favorite items found'))
              : ListView.builder(
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> item = favoriteItems[index]['Item'];

                    // Handle picture as Base64 string or Map with data field
                    Uint8List? pictureBytes;
                    if (item['Picture'] != null) {
                      if (item['Picture'] is String) {
                        try {
                          pictureBytes = base64Decode(item['Picture']);
                        } catch (e) {
                          print("Error decoding base64: $e");
                        }
                      } else if (item['Picture'] is Map && item['Picture']['data'] != null) {
                        try {
                          pictureBytes = Uint8List.fromList(List<int>.from(item['Picture']['data']));
                        } catch (e) {
                          print("Error decoding bytes from map: $e");
                        }
                      }
                    }

                    Widget imageWidget = pictureBytes != null && pictureBytes.isNotEmpty
                        ? Image.memory(
                            pictureBytes,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );

                    String itemName = item['item_name'] ?? 'No name';
                    String price = item['Price'] != null ? "${item['Price']} NIS" : 'No price';

                    return GestureDetector(
                      onTap: () {
                        // Check if the Picture field is a Map and convert it to a Base64 string
                        if (item['Picture'] != null && item['Picture'] is Map && item['Picture']['data'] != null) {
                          item['Picture'] = base64Encode(Uint8List.fromList(List<int>.from(item['Picture']['data'])));
                        }

                        // Navigate to ItemScreen when the item is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemScreen(item: item),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageWidget,
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Price: $price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeFromFavorites(favoriteItems[index]['item_id']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

Future<void> removeFromFavorites(int itemId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final apiUrl = Uri.parse('$baseUrl/GP/v1/shop/favoriteItems/removeFavoriteItem');

  try {
    print('Sending request to remove item with item_id: $itemId');

    final response = await http.delete(
      apiUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'item_id': itemId}), // Send the correct item_id
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from favorites')),
      );
      fetchFavoriteItems(); // Refresh the list
    } else {
      final errorData = json.decode(response.body);
      print('Error: ${errorData['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${errorData['message']}')),
      );
    }
  } catch (e) {
    print('Error removing favorite item: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to remove favorite item')),
    );
  }
}


}
