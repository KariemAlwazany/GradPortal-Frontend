import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/welcome_screen.dart';
import 'package:flutter_project/widgets/comments_section.dart';
import 'package:flutter_project/widgets/post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget{
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPhoneVisible = true;
  List<dynamic> userPosts = [];
  bool isLoading = true;
  String? loggedInUsername;
  File? _selectedImage;
  List<Post> _posts = [];
  String phoneNumber = "";
  String email = "";
  final TextEditingController _postController = TextEditingController();
  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();    
    _fetchLoggedInUsername();
  }

Future<void> _fetchLoggedInUsername() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception("JWT token not found");

    final response = await http.get(
      Uri.parse('$baseUrl/GP/v1/seller/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        loggedInUsername = data['Username'];
        phoneNumber = data['phone_number'];
        email = data['Email'];
      });

      _fetchUserPosts();
    } else {
      throw Exception('Failed to fetch username');
    }
  } catch (error) {
    print('Error fetching username: $error');
  }
}

Future<void> _fetchUserPosts() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) throw Exception("JWT token not found");

    if (loggedInUsername == null) {
      throw Exception("Username is not available");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/GP/v1/community/getUserPosts/$loggedInUsername'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userPosts = data['posts'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  } catch (error) {
    print('Error fetching user posts: $error');
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> _updatePost(int postId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.patch(
        Uri.parse('$baseUrl/GP/v1/community/editPost/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 200) {
        print('Post updated successfully');
        _fetchUserPosts();
      } else {
        print('Error updating post: ${response.body}');
      }
    } catch (error) {
      print('Error updating post: $error');
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/GP/v1/community/deletePost/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Post deleted successfully');
        _fetchUserPosts();
      } else {
        print('Error deleting post: ${response.body}');
      }
    } catch (error) {
      print('Error deleting post: $error');
    }
  }


  void _editPost(dynamic post) {
    showDialog(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: post['content']);
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Edit your post',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedContent = editController.text.trim();
                if (updatedContent.isNotEmpty) {
                  await _updatePost(post['id'], updatedContent);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPost(String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) throw Exception("JWT token not found");
      final TextEditingController _postController = TextEditingController();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/GP/v1/community/createPost'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['content'] = content;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        _fetchUserPosts();
        _postController.clear();
        setState(() {
          _selectedImage = null;
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to create post: $responseBody');
        throw Exception('Failed to create post');
      }
    } catch (error) {
      print('Error creating post: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit Profile clicked!")),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false, 
      );
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF3B4280),
      title: const Text(
        "Profile",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            loggedInUsername ?? 'Loading...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPhoneVisible ? phoneNumber : "Hidden",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              IconButton(
                icon: Icon(
                  isPhoneVisible ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF3B4280),
                ),
                onPressed: () {
                  setState(() {
                    isPhoneVisible = !isPhoneVisible;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What’s on your mind?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF3B4280)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, color: Color(0xFF3B4280)),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF3B4280)),
                      onPressed: () {
                        if (_postController.text.isNotEmpty) {
                          _createPost(_postController.text);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const Text(
            "Your Posts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const CircularProgressIndicator()
              : userPosts.isEmpty
                  ? const Text("No posts available.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post['content'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'Edit') {
                                          _editPost(post);
                                        } else if (value == 'Delete') {
                                          _deletePost(post['id']);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (post['image'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.memory(
                                      base64Decode(post['image']),
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                // Comments Section
                                CommentsSection(
                                  postId: post['id'],
                                  apiBaseUrl: baseUrl,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    ),
  );
}
}