import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/widgets/cart_app_bar.dart';
import 'package:flutter_project/widgets/cart_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = []; // List to store cart items
  bool isLoading = true; // Loading state
  double totalPrice = 0.0; // Store total price of the cart

  @override
  void initState() {
    super.initState();
    fetchCartItems(); // Fetch cart items when the screen loads
  }

  // Fetch cart items and calculate total price
  Future<void> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/cart/getCart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartItems = data['cart']['ItemsInCart'] ?? [];
          totalPrice = calculateTotalPrice(cartItems); // Calculate total price
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch cart items')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cart items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cart items')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Calculate total price of the cart
  double calculateTotalPrice(List<dynamic> items) {
    double total = 0.0;
    for (var item in items) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = item['CartItems']?['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CartAppBar(),
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
                // Show loading indicator while fetching cart items
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (cartItems.isEmpty)
                  Center(child: Text('Your cart is empty'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return CartItemTile(cartItem: cartItem);
                    },
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  padding: EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ],
      ),
      // Pass totalPrice to the CarBottomNavBar
      bottomNavigationBar: CarBottomNavBar(totalPrice: totalPrice),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final Map<String, dynamic> cartItem;

  const CartItemTile({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemName = cartItem['item_name'] ?? 'No name';
    final itemPrice = cartItem['price'] ?? '0';

    // Access quantity from CartItems
    final itemQuantity = cartItem['CartItems']?['quantity'] ?? 1;

    final itemDescription = cartItem['description'] ?? 'No description';

    // Decode Picture field (if available)
    Uint8List? imageBytes;
    if (cartItem['Picture'] != null && cartItem['Picture']['data'] != null) {
      try {
        imageBytes = Uint8List.fromList(List<int>.from(cartItem['Picture']['data']));
      } catch (e) {
        print("Error decoding image: $e");
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Color(0xFF3B4280),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Display item image
            imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
            SizedBox(width: 10),
            // Display item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Price: $itemPrice NIS",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "Quantity: $itemQuantity", // Ensure quantity is displayed
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    itemDescription,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
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
