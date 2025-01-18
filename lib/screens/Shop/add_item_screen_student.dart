import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemScreenStudents extends StatefulWidget {
  const AddItemScreenStudents({super.key});

  @override
  _AddItemScreenStudentsState createState() => _AddItemScreenStudentsState();
}

class _AddItemScreenStudentsState extends State<AddItemScreenStudents> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String selectedType = 'Hardware'; // Default dropdown value
  String selectedCategory = 'Motors'; // Default category value



void showStudentAddItemDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Add Item Notice",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B4280),
          ),
        ),
        content: Text(
          "GradHub will take a 5% profit of the component price. Do you agree?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate back to the previous screen
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Decline",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              "Agree",
              style: TextStyle(
                color: Color(0xFF3B4280),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}


  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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

    final shopName = "Students Shop";
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? ''; // Fetch from .env
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}/GP/v1/seller/items/additemStudent'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['item_name'] = itemNameController.text.trim();
      request.fields['Quantity'] = quantityController.text.trim();
      request.fields['Price'] = priceController.text.trim();
      request.fields['Description'] = descriptionController.text.trim();
      request.fields['Type'] = selectedType;
      request.fields['Category'] = selectedCategory; // Added category field
      request.fields['Available'] = 'true';

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'Picture',
          _selectedImage!.path,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = json.decode(responseBody)['message'] ?? 'Failed to upload item';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

@override
void initState() {
  super.initState();

  // Show the dialog after the widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showStudentAddItemDialog();
  });
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
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: const TextStyle(color: Color(0xFF3B4280)),
                    prefixIcon: const Icon(Icons.art_track, color: Color(0xFF3B4280)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B4280)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B4280), width: 2.0),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hardware', child: Text('Hardware')),
                    DropdownMenuItem(value: '3D Printing', child: Text('3D Printing')),
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
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Color(0xFF3B4280)),
                    prefixIcon: const Icon(Icons.category, color: Color(0xFF3B4280)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B4280)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B4280), width: 2.0),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Motors', child: Text('Motors')),
                    DropdownMenuItem(value: 'Drivers', child: Text('Drivers')),
                    DropdownMenuItem(value: 'Robotics', child: Text('Robotics')),
                    DropdownMenuItem(value: 'Microcontrollers', child: Text('Microcontrollers')),
                    DropdownMenuItem(value: 'Sensors', child: Text('Sensors')),
                    DropdownMenuItem(value: 'Arms', child: Text('Arms')),
                    DropdownMenuItem(value: '3D Printing', child: Text('3D Printing')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value ?? 'Motors';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
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
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
            labelStyle: const TextStyle(color: Color(0xFF3B4280)),
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF3B4280)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B4280)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B4280), width: 2.0),
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
