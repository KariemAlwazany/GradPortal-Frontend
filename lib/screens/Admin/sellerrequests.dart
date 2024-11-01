import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class SellerRequestsPage extends StatelessWidget {
  final List<Map<String, String>> sellerRequests = [
    {'name': 'Tech Solutions', 'details': 'Request for vendor approval'},
    {'name': 'Smart Gadgets Co.', 'details': 'Product listing request'},
  ];

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
        child: ListView.builder(
          itemCount: sellerRequests.length,
          itemBuilder: (context, index) {
            final request = sellerRequests[index];
            return _buildRequestCard(
              name: request['name']!,
              details: request['details']!,
              onAccept: () {
                _showResponseSnackBar(context, 'Accepted ${request['name']}');
              },
              onDecline: () {
                _showResponseSnackBar(context, 'Declined ${request['name']}');
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String details,
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
              details,
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

  void _showResponseSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }
}
