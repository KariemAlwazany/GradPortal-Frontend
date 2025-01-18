import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String currentStatus = 'completed'; // Default to 'Completed'

  @override
  void initState() {
    super.initState();
    fetchOrders('completed'); // Fetch completed orders initially
  }

  Future<void> fetchOrders(String status) async {
    setState(() {
      isLoading = true;
      orders = []; // Clear orders when fetching new status
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      setState(() {
        isLoading = false;
        orders = [];
      });
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final endpoint = status == 'completed'
        ? '/GP/v1/orders/getCompletedOrdersForSeller'
        : '/GP/v1/orders/getRejectedOrdersForSeller';
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = data['orders'] ?? [];
          isLoading = false;
          currentStatus = status; // Update the current status
        });
      } else {
        setState(() {
          isLoading = false;
          orders = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load $status orders')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        orders = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget buildStatusButton(String status, String label) {
    return ElevatedButton(
      onPressed: () => fetchOrders(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B4280),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color(0xFF3B4280),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildStatusButton('completed', 'Completed'),
                buildStatusButton('rejected', 'Rejected'),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Text(
                          currentStatus == 'rejected'
                              ? "There's no rejected orders"
                              : "No $currentStatus orders found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderId = order['order_id'] ?? 'N/A';
                          final totalPrice = order['total_price'] ?? 'N/A';
                          final paymentMethod = order['payment_method'] ?? 'N/A';
                          final items = order['OrderItemsAlias'] ?? [];

                          return Card(
                            color: Color(0xFF3B4280), // Background color of the card
                            margin: EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID: $orderId',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total Price: $totalPrice NIS',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Payment Method: $paymentMethod',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Items:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...items.map<Widget>((item) {
                                    final itemDetails =
                                        item['ItemsAlias'] ?? {};
                                    final itemName =
                                        itemDetails['item_name'] ?? 'Unknown';
                                    final quantity = item['quantity'] ?? 0;
                                    final price = item['price'] ?? 0;
                                    return Text(
                                      '$itemName (Qty: $quantity, Price: $price NIS)',
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
