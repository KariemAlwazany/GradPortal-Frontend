// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/custom_scaffold.dart';

class DoctorFirstScreen extends StatefulWidget {
  const DoctorFirstScreen({super.key, required username});

  @override
  _DoctorFirstScreenState createState() =>  _DoctorFirstScreenState();
}

class  _DoctorFirstScreenState extends State<DoctorFirstScreen> {
  final TextEditingController _shopNameController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  void _createShop() {
    final shopName = _shopNameController.text;
    if (shopName.isNotEmpty) {
      // Logic to create the shop, and then navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NextPage(shopName: shopName), // Navigate to the next screen
        ),
      );
    } else {
      // Show a message if the shop name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a shop name'),
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
            const Text(
              'Set up your shop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shopNameController,
              decoration: const InputDecoration(
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
