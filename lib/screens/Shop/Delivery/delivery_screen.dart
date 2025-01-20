import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/components/MenuSideBar/side_bar_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';
  int? buyer_id;
  int? orderId;
  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');

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
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data['orders'];
          isLoading = false;

        });
              for (var order in orders) {
        fetchPhoneNumber(order['order_id']); // API call for each order
        orderId = order['order_id'];
      }
      } else {
        setState(() {
          errorMessage = 'There is no orders';
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

Future<void> _sendNotification(int receiverId) async {

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/GP/v1/notification/notifyUser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "userId": receiverId,
        "title": "Gradhub",
        "body": "Order Status: The delivery is on the way to you ",
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}

  void _showLocationDialog(BuildContext context, Map<String, dynamic> deliveryLocation) async {
    try {
      // Get the user's current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final deliveryLatitude = deliveryLocation['latitude'];
      final deliveryLongitude = deliveryLocation['longitude'];

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        deliveryLatitude,
        deliveryLongitude,
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delivery Location'),
            content: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(deliveryLatitude, deliveryLongitude),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('delivery_location'),
                          position: LatLng(deliveryLatitude, deliveryLongitude),
                          infoWindow: const InfoWindow(title: 'Delivery Location'),
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 16),
                  ),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendNotification(buyer_id!);
                  _delivering(deliveryLocation);
                  updateOrderStatusToDelivering(orderId!);
                },
                child: const Text('Deliver'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }


Future getBuyerId(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return null;
  }

  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final apiUrl = Uri.parse('$baseUrl/GP/v1/orders/getBuyerId?orderId=$orderId');

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
        buyer_id = data['buyer_id'] ;
      });
    } else {
      print('Failed to fetch buyer ID: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching buyer ID: $e');
    return null;
  }
}


  Future<void> fetchPhoneNumber(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');

      if (token == null) {
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/orders/getBuyerPhoneNumber?orderId=$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final phoneNumber = data['phone_number'];

        // Update the specific order with the phone number
        setState(() {
          orders = orders.map((order) {
            if (order['order_id'] == orderId) {
              return {
                ...order,
                'phone_number': phoneNumber,
              };
            }
            return order;
          }).toList();
        });
      }
    } catch (error) {
      print('Failed to fetch phone number for order $orderId: $error');
    }
  }


void _delivering(Map<String, dynamic> deliveryLocation) async {
  final double latitude = deliveryLocation['latitude'];
  final double longitude = deliveryLocation['longitude'];

  final String googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open Google Maps.'),
      ),
    );
  }
}


Future<void> updateOrderStatusToDelivering(int orderId) async {
  final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/orders/updateToDelivering';

  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Order status updated successfully: ${data['message']}');
    } else {
      print('Failed to update order status: ${response.body}');
    }
  } catch (error) {
    print('An error occurred while updating order status: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery',
        style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF3B4280),
      ),
      drawer: const SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (orders.isEmpty)
              const Center(
                child: Text('No completed delivery orders found'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final deliveryLocation = order['delivery_location'];
                    final phoneNumber = order['phone_number'] ?? 'Fetching...';
                    return Card(
                      color: const Color(0xFF3B4280), // Set the background color here
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
                                color: Colors.white, // Adjust text color for better visibility
                              ),
                            ),
                            Text(
                              'Coordinates: (${deliveryLocation['latitude']}, ${deliveryLocation['longitude']})',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70, // Adjust text color for better contrast
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Price: ${order['total_price']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white, // Adjust text color for better visibility
                              ),
                            ),
                            Text(
                              'Phone Number: $phoneNumber',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {_showLocationDialog(
                                context,
                                deliveryLocation,
                              );
                              getBuyerId(orderId!);} ,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5A6AC0),
                              ),
                              child: const Text('View Location'),
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
