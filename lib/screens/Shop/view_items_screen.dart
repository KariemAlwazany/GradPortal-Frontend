import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For base64 decoding if needed
import 'dart:typed_data';

class ViewItemsScreen extends StatefulWidget {
  const ViewItemsScreen({super.key});

  @override
  State<ViewItemsScreen> createState() => _ViewItemsScreenState();
}

class _ViewItemsScreenState extends State<ViewItemsScreen> {
  List<dynamic> items = [];
  bool isLoading = true;
  String searchQuery = '';  // Declare searchQuery variable

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }



  // Fetch items based on the current search query
  Future<void> fetchItemsBySearch(String query) async {
    final searchUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/searchItemsForSeller')
        .replace(queryParameters: {'item_name': query});  // Send the search query as a query parameter

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
        searchUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Search response data: $data');  // Log the entire response

        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            items = List.from(data['items'] ?? []);
            print('Loaded search results: $items');  // Log loaded items
            isLoading = false;
          });
        } else {
          setState(() {
            items = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items found for this search')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error searching for items')),
        );
      }
    } catch (e) {
      print("Error searching for items: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error searching for items')),
      );
    }
  }

  Future<void> fetchAllItems() async {
    final itemsUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/getSelleritems');
  
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
        print('Response data: $data');  // Log the entire response
  
        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            items = List.from(data['items'] ?? []);
            print('Loaded items: $items');  // Log loaded items
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
          const SnackBar(content: Text('No items found in this category')),
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
  final itemsUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/getSellerItemsByCategory')
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
    final response = await http.get(
      itemsUrl,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data by category: $data');  // Log the entire response

      if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
        setState(() {
          items = List.from(data['items'] ?? []);
          print('Loaded items by category: $items');  // Log loaded items
          isLoading = false;
        });
      } else {
        setState(() {
          items = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items found for this category')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items found for this category')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF2),
      appBar: AppBar(
        title: const Text(
          'My Items',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B4280),

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;  // Update the search query
                        });
                        fetchItemsBySearch(value);  // Call search API when the query changes
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChip(
                          label: 'All',
                          onCategorySelected: (category) {
                            fetchAllItems();
                        },
                      ),
                      CategoryChip(
                        label: 'Motors',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category);
                        },
                      ),
                      CategoryChip(
                        label: 'Drivers',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category);
                        },
                      ),
                      CategoryChip(
                        label: 'Microcontrollers',
                        onCategorySelected: (category) {
                          fetchItemsByCategory(category);
                        },
                      ),
                      CategoryChip(
                        label: 'Sensors',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category);
                        },
                      ),
                      CategoryChip(
                        label: '3D Printing',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category);
                        },
                      ),
                      CategoryChip(
                        label: 'Robotics',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category); 

                        },
                      ),
                      CategoryChip(
                        label: 'Others',
                        onCategorySelected: (category) {
                              fetchItemsByCategory(category);
                        },
                      ),
                    ],
                  ),
                ),
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
                            fetchItemsCallback: fetchAllItems,
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

class CategoryChip extends StatelessWidget {
  final String label;
  final Function(String) onCategorySelected; // Callback for when a category is selected

  const CategoryChip({super.key, required this.label, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          onCategorySelected(label); // Pass the selected category
        },
        child: Chip(
          label: Text(label),
          backgroundColor: const Color(0xFF3B4280),
          labelStyle: const TextStyle(color: Colors.white),
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
    String category = item['Category'] ?? 'Motors'; 
    String type = item['Type'] ?? '';
    bool available = item['Available'] ?? false;
    int quantity = item['Quantity'] ?? 0;
    int itemId = item['Item_ID'] ?? 0;

    print('Item: $item');  // Log the item data

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

    return GestureDetector(
      onTap: () {
        // Navigate to the item detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemScreen(item: item), // Pass item details
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
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3B4280)),
                onPressed: () {
                  _showEditDialog(parentContext, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    String itemName = item['item_name'] ?? '';
    String description = item['Description'] ?? '';
    String price = item['Price']?.toString() ?? '';
    String category = item['Category'] ?? 'Motors';
    String type = item['Type'] ?? '';
    bool available = item['Available'] ?? true;
    int quantity = item['Quantity'] ?? 0;
    int itemId = item['Item_ID'] ?? 0;

    if (itemId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid item ID.')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: itemName),
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  onChanged: (value) {
                    itemName = value;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: description),
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: price),
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    price = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Motors', child: Text('Motors')),
                    DropdownMenuItem(value: 'Drivers', child: Text('Drivers')),
                    DropdownMenuItem(value: 'Microcontrollers', child: Text('Microcontrollers')),
                    DropdownMenuItem(value: 'Sensors', child: Text('Sensors')),
                    DropdownMenuItem(value: '3D Printing', child: Text('3D Printing')),
                    DropdownMenuItem(value: 'Arms', child: Text('Arms')),
                    DropdownMenuItem(value: 'Robotics', child: Text('Robotics')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (value) {
                    category = value!;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: type),
                  decoration: const InputDecoration(labelText: 'Type'),
                  onChanged: (value) {
                    type = value;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: quantity.toString()),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 0;
                  },
                ),
                // Dropdown for Availability in the Dialog
                DropdownButtonFormField<String>(
                  value: available ? 'Yes' : 'No',
                  decoration: const InputDecoration(labelText: 'Available'),
                  items: const [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    available = value == 'Yes';
                  },
                ),
                // You can add more fields for picture upload if necessary
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateItem(context, itemId, itemName, description, price, category, type, available, quantity);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateItem(BuildContext context, int itemId, String itemName, String description, String price, String category, String type, bool available, int quantity) async {
    final updateUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/updateItem/$itemId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final Map<String, dynamic> updatedItem = {
      'item_name': itemName,
      'Description': description,
      'Price': double.tryParse(price) ?? 0.0,
      'Category': category,
      'Type': type,
      'Available': available,
      'Quantity': quantity,
    };

    try {
      final response = await http.patch(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedItem),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Item updated successfully')),
        );
        fetchItemsCallback();  // Refresh the items list
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Failed to update item')),
        );
      }
    } catch (error) {
      print('Error updating item: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating item')),
      );
    }
  }
}