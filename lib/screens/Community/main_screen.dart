import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/components/navbar/community_navabar.dart';
import 'package:flutter_project/widgets/comments_section.dart';
import 'package:flutter_project/widgets/post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  List<Post> _posts = [];
  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  File? _selectedImage;
  String? loggedInUsername;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchLoggedInUsername();
  }

  Future<void> _fetchPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final _fetchPosts = await http.get(
        Uri.parse('$baseUrl/GP/v1/community/getAllPosts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (_fetchPosts.statusCode == 200) {
        final data = json.decode(_fetchPosts.body);
        setState(() {
          _posts = (data['posts'] as List)
              .map((postJson) => Post.fromJson(postJson))
              .toList();
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
    }
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
        });
      } else {
        throw Exception('Failed to fetch username');
      }
    } catch (error) {
      print('Error fetching username: $error');
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
        _fetchPosts();
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
        _fetchPosts();
      } else {
        print('Error deleting post: ${response.body}');
      }
    } catch (error) {
      print('Error deleting post: $error');
    }
  }

  void _editPost(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: post.content);
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: 'Edit your post',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedContent = editController.text;
                if (updatedContent.isNotEmpty) {
                  await _updatePost(post.id, updatedContent);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
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
        _fetchPosts();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3B4280),
        centerTitle: true,
        title: const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Post Input Section
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
          const Divider(height: 1, color: Colors.grey),
          // Posts Feed
          Expanded(
            child: _posts.isEmpty
                ? const Center(
                    child: Text(
                      'No posts yet. Share something!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Post Header
                              Row(
                                children: [
                                  Text(
                                    post.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    post.timestamp != null
                                        ? post.timestamp.toString()
                                        : 'Unknown time',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (post.username == loggedInUsername)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editPost(post);
                                        } else if (value == 'delete') {
                                          _deletePost(post.id);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      icon: Icon(Icons.more_vert),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Post Content
                              Text(post.content, style: const TextStyle(fontSize: 16)),
                              if (post.image != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.memory(
                                    base64Decode(post.image!),
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              // Comments Section
                              CommentsSection(
                                postId: post.id,
                                apiBaseUrl: baseUrl,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
