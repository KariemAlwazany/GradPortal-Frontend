import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class SellerRequestsPage extends StatefulWidget {
  @override
  _SellerRequestsPageState createState() => _SellerRequestsPageState();
}

class _SellerRequestsPageState extends State<SellerRequestsPage> {
  List<Map<String, dynamic>> sellerRequests = [];

  @override
  void initState() {
    super.initState();
    fetchSellerRequests();
  }

  Future<void> fetchSellerRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/admin/sellers'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          sellerRequests =
              List<Map<String, dynamic>>.from(data['data']['sellers']);
        });
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch seller requests')),
      );
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> handleResponse(int index, String username, String action) async {
    final token = await getToken();
    final url = action == 'accept'
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/admin/approve'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/admin/decline';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'Username': username}),
    );

    if (response.statusCode == 200) {
      setState(() {
        sellerRequests.removeAt(index); // Remove the card instantly
      });
      _showResponseSnackBar(
        context,
        '${action == 'accept' ? 'Accepted' : 'Declined'} $username',
      );
    } else {
      _showResponseSnackBar(context, 'Failed to $action $username');
    }
  }

  void _showResponseSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Seller Approval Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: sellerRequests.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: sellerRequests.length,
                itemBuilder: (context, index) {
                  final request = sellerRequests[index];
                  return _buildRequestCard(
                    name: request['User']['FullName'] ?? 'Unknown',
                    phoneNumber: request['Phone_number'] ?? 'No phone',
                    shopName: request['Shop_name'] ?? 'No shop name',
                    onAccept: () =>
                        handleResponse(index, request['Username'], 'accept'),
                    onDecline: () =>
                        handleResponse(index, request['Username'], 'decline'),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String phoneNumber,
    required String shopName,
    required Function onAccept,
    required Function onDecline,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: $phoneNumber',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Shop: $shopName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => onAccept(),
                  icon: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
                SizedBox(width: 16),
                IconButton(
                  onPressed: () => onDecline(),
                  icon: Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
