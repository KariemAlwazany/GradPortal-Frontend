import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/custom_scaffold.dart';

class SellerSetupScreen extends StatefulWidget {
  final String username; // Add username parameter to display it

  const SellerSetupScreen({Key? key, required this.username}) : super(key: key);

  @override
  _SellerSetupScreenState createState() => _SellerSetupScreenState();
}

class _SellerSetupScreenState extends State<SellerSetupScreen> {
  final TextEditingController _shopNameController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  void _createShop() {
    final shopName = _shopNameController.text;
    if (shopName.isNotEmpty) {
      // Logic to create the shop and navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NextPage(shopName: shopName), // Navigate to the next screen
        ),
      );
    } else {
      // Show a message if the shop name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a shop name'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the logged-in username at the top
            Text(
              'Hello, ${widget.username}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Set up your shop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // White background for the input field
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // White color for the input field
                border: OutlineInputBorder(),
                labelText: 'Enter your shop name',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createShop,
              child: const Text('Create Shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final String shopName;

  const NextPage({Key? key, required this.shopName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Created')),
      body: Center(
        child: Text(
          'Your shop "$shopName" has been created!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
