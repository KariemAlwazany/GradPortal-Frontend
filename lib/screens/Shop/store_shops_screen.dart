// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/store_selected_shop_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoreShopsScreen extends StatefulWidget {
  @override
  _StoreShopsScreenState createState() => _StoreShopsScreenState();
}

class _StoreShopsScreenState extends State<StoreShopsScreen> {
  List<Map<String, dynamic>> shops = [];
  bool isLoading = true;
  String shopName = "";
  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/getAllShops');
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
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          shops = List<Map<String, dynamic>>.from(data['shops'] ?? []);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch shops')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching shops: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching shops')),
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
        title: Text('Shops'),
        backgroundColor: Color(0xFF3B4280),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : shops.isEmpty
              ? Center(
                  child: Text('No shops available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          shop['shop_name'] ?? 'Unknown Shop',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Seller: ${shop['Seller_Username'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Pass shop_id to StoreItemsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreItemsScreen(
                                shopName: shop['shop_name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
