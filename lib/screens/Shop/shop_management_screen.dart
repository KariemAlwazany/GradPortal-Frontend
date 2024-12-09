// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Shop/add_item_screen.dart';
import 'package:flutter_project/screens/Shop/item_screen.dart';
import 'package:flutter_project/screens/Shop/limited_stock_screen.dart';
import 'package:flutter_project/screens/Shop/orders_request_screen.dart';
import 'package:flutter_project/screens/Shop/orders_screen.dart';
import 'package:flutter_project/screens/Shop/out_of_stock_screen.dart';
import 'package:flutter_project/screens/Shop/statistics_screen.dart';
import 'package:flutter_project/screens/Shop/view_items_screen.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/screens/Shop/sales_screen.dart';

class ShopManagementScreen extends StatefulWidget {
  ShopManagementScreen({super.key});
  @override
  _ShopManagementScreenState createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen> {
  String shopName = "Loading...";
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> fetchedItems = [];
  bool isLoading = false;
  int totalProducts = 0;
  int outOfStockCount = 0;
  int limitedStockCount = 0;

  Future<void> fetchAllItems(Function onSuccess) async {
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
        print('Response data: $data');
        if (data != null && data is Map<String, dynamic> && data.containsKey('items')) {
          setState(() {
            fetchedItems = List<Map<String, dynamic>>.from(data['items'] ?? []);
            print('Loaded items: $fetchedItems');
            isLoading = false;
          });
          onSuccess();
        } else {
          setState(() {
            fetchedItems = [];
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

  Future<void> countItems(Function onSuccess) async {
    final countUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/countItemsForSeller');
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
        countUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data != null && data is Map<String, dynamic> && data.containsKey('itemCount')) {
          setState(() {
            totalProducts = data['itemCount'];
            print('Total number of products: $totalProducts');
          });
          onSuccess();
        } else {
          setState(() {
            totalProducts = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items found')),
          );
        }
      } else {
        setState(() {
          totalProducts = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching item count')),
        );
      }
    } catch (e) {
      print("Error fetching item count: $e");
      setState(() {
        totalProducts = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching item count')),
      );
    }
  }

  Future<void> fetchLimitedStock(Function onSuccess) async {
    final limitedStockUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/countLimitedStock');
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
        limitedStockUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic> && data.containsKey('count')) {
          setState(() {
            limitedStockCount = data['count'];
          });
          onSuccess();
        } else {
          setState(() {
            limitedStockCount = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching limited stock count')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching limited stock count')),
        );
      }
    } catch (e) {
      print("Error fetching limited stock count: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching limited stock count')),
      );
    }
  }

  Future<void> fetchOutOfStock(Function onSuccess) async {
    final outOfStockUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/countOutOfStockItems');
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
        if (data != null && data is Map<String, dynamic> && data.containsKey('count')) {
          setState(() {
            outOfStockCount = data['count'];
          });
          onSuccess();
        } else {
          setState(() {
            outOfStockCount = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching out-of-stock count')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching out-of-stock count')),
        );
      }
    } catch (e) {
      print("Error fetching out-of-stock count: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching out-of-stock count')),
      );
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final userUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/profile');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');      
      final profileResponse = await http.get(
        userUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        print(profileData);
        setState(() {
          shopName = profileData['Shop_name'] ?? "No shop name found";
        });
      }
    } catch (e) {
      setState(() {
        shopName = "Error loading data";
      });
    }
  }

  // Close Shop Temporary Confirmation Dialog
  void _showCloseShopDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Your shop will be closed temporarily and your items will be marked as unavailable.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without closing shop
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                closeShopTemporary(); // Call the close shop function
              },
              child: const Text('Yes, Close Shop'),
            ),
          ],
        );
      },
    );
  }

  // Function to close shop temporarily
  Future<void> closeShopTemporary() async {
    final closeShopUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/closeShopTemporary');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.patch(
        closeShopUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        // Navigate to WelcomeScreen directly after closing the shop
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Error closing shop temporarily')),
        );
      }
    } catch (e) {
      print("Error closing shop temporarily: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error closing shop temporarily')),
      );
    }
  }

  // Delete Shop Confirmation Dialog
  void _showDeleteShopDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
              'Your shop will be deleted permanently and your role will be set to User.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                deleteShop(); // Call the delete function
              },
              child: const Text('Yes, Delete Shop'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteShop() async {
    final deleteShopUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/deleteShop');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.delete(
        deleteShopUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        // Log out the user after everything is done
        await _logout();

        // Navigate to WelcomeScreen directly
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Error deleting shop')),
        );
      }
    } catch (e) {
      print("Error deleting shop: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting shop')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    countItems(() {
      fetchAllItems(() {
        fetchLimitedStock(() {
          fetchOutOfStock(() {
            setState(() {});
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = []; 
    final orderRequests = []; 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B4280),
        title: const Text(
          'Shop Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shopName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Add Category Container Grid Here
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), 
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildCategoryContainer(
                      title: 'My Items', 
                      icon: Icons.shop, 
                      quantity: totalProducts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewItemsScreen()),
                        );
                      },
                    );
                  case 1:
                    return _buildCategoryContainer(
                      title: 'Out of Stock', 
                      icon: Icons.remove_shopping_cart, 
                      quantity: outOfStockCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OutOfStockScreen()),
                        );
                      },
                    );
                  case 2:
                    return _buildCategoryContainer(
                      title: 'Limited Stock', 
                      icon: Icons.warning, 
                      quantity: limitedStockCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LimitedStockScreen()),
                        );
                      },
                    );
                  case 3:
                    return _buildCategoryContainer(
                      title: 'Orders', 
                      icon: Icons.shopping_cart, 
                      quantity: orders.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrdersScreen()),
                        );
                      },
                    );
                  case 4:
                    return _buildCategoryContainer(
                      title: 'Orders Request', 
                      icon: Icons.pending, 
                      quantity: orderRequests.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrdersRequestScreen()),
                        );
                      },
                    );
                  case 5:
                    return _buildCategoryContainer(
                      title: 'Statistics', 
                      icon: Icons.stacked_line_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StatisticsScreen()),
                        );
                      },
                    );
                  default:
                    return Container();
                }
              },
            ),

            const SizedBox(height: 20),
            _buildStatisticsSection(totalProducts, orders.length, orderRequests.length),
            const SizedBox(height: 20),

            // Create Sale Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B4280),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Create a Sale",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Add Item Button
            Container(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddItemScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B4280),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_box_outlined,
                      color: Colors.white,  
                      size: 24,  
                    ),
                    const SizedBox(width: 10), 
                    Text(
                      "Add Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Close Shop Button
            Container(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: _showCloseShopDialog, // Show the close dialog
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.white,  
                      size: 24,  
                    ),
                    const SizedBox(width: 10), 
                    Text(
                      "Close Shop Temporary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Delete Shop Button
            Container(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: _showDeleteShopDialog, // Show the delete dialog
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.white,  
                      size: 24,  
                    ),
                    const SizedBox(width: 10), 
                    Text(
                      "Delete Shop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Container Widget
  Widget _buildCategoryContainer({
    required String title,
    required IconData icon,
    int? quantity,
    required VoidCallback onTap, 
  }) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF3B4280),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B4280), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (quantity != null)
              Text(
                '$quantity items',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Statistics Section Widget
  Widget _buildStatisticsSection(int totalProducts, int totalOrders, int totalRequests) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatisticCard('Total Products', totalProducts),
        _buildStatisticCard('Total Orders', totalOrders),
        _buildStatisticCard('Total Requests', totalRequests),
      ],
    );
  }

  // Statistic Card Widget
  Widget _buildStatisticCard(String title, int count) {
    return Card(
      color: Color(0xFF3B4280),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(13.5),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold,
              color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
