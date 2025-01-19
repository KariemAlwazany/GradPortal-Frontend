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


class ProfileScreenClicked extends StatefulWidget {
  final String username;

  const ProfileScreenClicked({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenClickedState createState() => _ProfileScreenClickedState();
}

class _ProfileScreenClickedState extends State<ProfileScreenClicked> {
  bool isPhoneVisible = true;
  List<dynamic> userPosts = [];
  bool isLoading = true;
  String? email;
  String? phoneNumber;

  final TextEditingController _postController = TextEditingController();
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }


  Future<void> _fetchUserPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) throw Exception("JWT token not found");

      final response = await http.get(
        Uri.parse('$baseUrl/GP/v1/community/getUserPosts/${widget.username}'),
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
          const SizedBox(height: 16),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          const Divider(),
          const Text(
            "Posts",
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
