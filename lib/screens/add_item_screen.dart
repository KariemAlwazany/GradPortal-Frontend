import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String selectedType = 'Hardware'; // Default dropdown value

  // Method to select an image
  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print("Selected Image Path: ${_selectedImage!.path}");
    } else {
      print("No image selected.");
    }
  }

  // Fetch shop name using an API call
  Future<String?> _fetchShopName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final shopData = json.decode(response.body);
        print("Fetched Shop Name: ${shopData['Shop_name']}");
        return shopData['Shop_name'];
      } else {
        print(
            "Failed to fetch shop details. Status Code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch shop details')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching shop details')),
      );
      print(e);
      return null;
    }
  }

  // Upload item to the API
  Future<void> _uploadItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final shopName = await _fetchShopName();
    if (shopName == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/seller/items/additem'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['item_name'] = itemNameController.text.trim();
      request.fields['Quantity'] = quantityController.text.trim();
      request.fields['Price'] = priceController.text.trim();
      request.fields['Description'] = descriptionController.text.trim();
      request.fields['Type'] = selectedType;
      request.fields['Available'] = 'true';

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'Picture', // This must match the backend field name
          _selectedImage!.path,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      print("Request Fields: ${request.fields}");
      print("Selected Image: ${_selectedImage!.path}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage =
            json.decode(responseBody)['message'] ?? 'Failed to upload item';
        print("Error Response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print("Exception occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B4280),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Item Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B4280),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: itemNameController,
                  label: 'Item Name',
                  hint: 'Enter item name',
                  icon: Icons.label,
                ),

                _buildTextField(
                  controller: quantityController,
                  label: 'Quantity',
                  hint: 'Enter item quantity',
                  icon: Icons.confirmation_number,
                  keyboardType: TextInputType.number,
                ),

                _buildTextField(
                  controller: priceController,
                  label: 'Price (NIS)',
                  hint: 'Enter item price',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),

                _buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  hint: 'Enter item description',
                  icon: Icons.description,
                ),

                const SizedBox(height: 16),

                // Type Field as Dropdown
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    hintText: 'Select item type',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Hardware', child: Text('Hardware')),
                    DropdownMenuItem(
                        value: '3D Printing', child: Text('3D Printing')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? 'Hardware';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedImage == null
                          ? 'Upload Picture'
                          : 'Picture Selected: ${_selectedImage!.path.split('/').last}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3B4280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton(
                    onPressed: _uploadItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      backgroundColor: const Color(0xFF3B4280),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Item',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
