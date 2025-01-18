import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Admin/students_shop_items.dart';
import 'package:flutter_project/screens/Shop/store_selected_shop_screen.dart';
import 'package:flutter_project/widgets/item_app_bar.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter_project/widgets/item_bottom_navabr.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  ItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _ItemScreenState createState() => _ItemScreenState();
}
class _ItemScreenState extends State<ItemScreen> {
  int quantity = 1;
  double averageRating = 0.0;
  int totalRatings = 0;
  List<Map<String, dynamic>> comments = []; // To store comments with ratings
  bool isLoading = true;
  bool isFavorite = false; // Track favorite status

  @override
  void initState() {
    super.initState();
    fetchRatingData(); // Fetch rating data
    checkIfFavorite(); // Check favorite status when screen loads
  }

  Future<void> fetchRatingData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final itemId = widget.item['Item_ID'];

    final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/ratings/getItemRating/$itemId');

    try {
      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Rating Data: $data'); // Log the response for debugging

        setState(() {
          averageRating = (data['average_rating'] ?? 0.0).toDouble();
          totalRatings = (data['total_ratings'] ?? 0).toInt();
          comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch rating data')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rating data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/favoriteItems/checkFavoriteItem/${widget.item['Item_ID']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      if (isFavorite) {
        // Remove from favorites
        final response = await http.delete(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/favoriteItems/removeFavoriteItem'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"item_id": widget.item['Item_ID']}),
        );

        if (response.statusCode == 200) {
          setState(() {
            isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed from favorites')),
          );
        }
      } else {
        // Add to favorites
        final response = await http.post(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/favoriteItems/addFavoriteItem'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"item_id": widget.item['Item_ID']}),
        );

        if (response.statusCode == 200) {
          setState(() {
            isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added to favorites')),
          );
        }
      }
    } catch (e) {
      print("Error toggling favorite status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite status')),
      );
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> showRatingDialog() async {
    double newRating = 0.0;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rate this Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  newRating = rating;
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await submitRating(newRating, commentController.text);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitRating(double rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userId = prefs.getInt('user_id');

    final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/shop/ratings/addOrUpdate');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'item_id': widget.item['Item_ID'],
          'user_id': userId,
          'rating': rating,
          'review': comment,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')),
        );
        fetchRatingData();
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
      }
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String itemName = widget.item['item_name'] ?? 'No name';
    String description = widget.item['Description'] ?? 'No description';
    String price = widget.item['Price'] != null ? "${widget.item['Price']} NIS" : 'No price';
    String base64Image = widget.item['Picture'] ?? '';
    String shop_name = widget.item['Shop_name'];
    Uint8List? imageBytes;
    if (base64Image.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64Image);
      } catch (e) {
        print("Error decoding Base64 image: $e");
      }
    }

    Widget imageWidget = imageBytes != null && imageBytes.isNotEmpty
        ? Image.memory(imageBytes)
        : const Center(child: Text('No image available'));

    return Scaffold(
      backgroundColor: Color(0XFFEDECF2),
      body: ListView(
        children: [
          ItemAppBar(),
          Padding(
            padding: EdgeInsets.all(16),
            child: imageWidget,
          ),
          Arc(
            edge: Edge.TOP,
            arcType: ArcType.CONVEY,
            height: 30,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                  Padding(
                    padding: EdgeInsets.only(top: 103, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Color(0xFF3B4280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleFavorite,
                        ),
                      ],
                    ),
                  ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreItemsScreen(shopName:shop_name),
                            ),
                          );
                        },
                        child: Text(
                          shop_name,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B4280),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: averageRating,
                                itemCount: 5,
                                itemSize: 20,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '($totalRatings)',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.rate_review, color: Color(0xFF3B4280)),
                            onPressed: showRatingDialog,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B4280),
                        ),
                      ),
                    ),
                    Divider(),
                    ...comments.map((comment) {
                      return ListTile(
                        title: Text(comment['user_name'] ?? 'Anonymous'),
                        subtitle: Text(comment['review'] ?? 'No comment'),
                        trailing: RatingBarIndicator(
                          rating: comment['rating']?.toDouble() ?? 0.0,
                          itemCount: 5,
                          itemSize: 15,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ItemBottomNavBar(
        item: widget.item,
        quantity: quantity,
      ),
    );
  }
}
