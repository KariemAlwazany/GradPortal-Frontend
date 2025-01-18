import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // For decoding JSON response
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:flutter_project/components/MenuSideBar/side_bar_menu.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<dynamic> orders = []; // To store fetched orders
  bool isLoading = true; // To show a loading indicator
  String errorMessage = ''; // To display error messages

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when the screen initializes
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token'); // Retrieve the token from SharedPreferences

      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/orders/getCompletedOrdersForDelivery'),
        headers: {
          'Authorization': 'Bearer $token', // Use the token from SharedPreferences
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data['orders']; // Update orders with the API response
          isLoading = false; // Stop the loading indicator
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load orders';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery'),
        backgroundColor: const Color(0xFF3B4280),
      ),
      drawer: const SideMenu(), // Replace SideMenu with your actual drawer widget
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders with Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator()) // Show a loading indicator
            else if (errorMessage.isNotEmpty)
              Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ) // Show error message if any
            else if (orders.isEmpty)
              const Center(
                child: Text('No completed delivery orders found'),
              ) // Show a message when no orders are available
            else
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final deliveryLocation = order['delivery_location'];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order['order_id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'City: ${deliveryLocation['city']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Coordinates: (${deliveryLocation['latitude']}, ${deliveryLocation['longitude']})',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Price: ${order['total_price']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
