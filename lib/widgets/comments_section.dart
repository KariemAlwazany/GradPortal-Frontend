import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CommentsSection extends StatefulWidget {
  final int postId; // Unique identifier for the post
  final String apiBaseUrl; // Base URL for API calls

  const CommentsSection({
    Key? key,
    required this.postId,
    required this.apiBaseUrl,
  }) : super(key: key);

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  int likesCount = 0;
  bool isLiked = false; // Track if the user has liked the post
  int commentsCount = 0;
  List<Map<String, dynamic>> comments = [];
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchLikesCount();
    _checkIfLiked(); // Check if the user already liked the post
  }

  Future<void> _fetchComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final url = '${widget.apiBaseUrl}/GP/v1/community/getAllComments/${widget.postId}';
      print('Fetching comments from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          comments = List<Map<String, dynamic>>.from(data['comments']);
          commentsCount = comments.length;
        });
      } else {
        print('Failed to fetch comments: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error fetching comments: $error');
    }
  }

  Future<void> _fetchLikesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final url = '${widget.apiBaseUrl}/GP/v1/community/countLikes/${widget.postId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          likesCount = data['likes'] ?? 0;
        });
      } else {
        print('Failed to fetch likes count: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error fetching likes count: $error');
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final url = '${widget.apiBaseUrl}/GP/v1/community/checkIfLiked/${widget.postId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isLiked = data['isLiked'] ?? false;
        });
      } else {
        print('Failed to check like status: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error checking like status: $error');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final url = isLiked
          ? '${widget.apiBaseUrl}/GP/v1/community/removeLike/${widget.postId}'
          : '${widget.apiBaseUrl}/GP/v1/community/addLike/${widget.postId}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          isLiked = !isLiked;
          likesCount += isLiked ? 1 : -1;
        });
        print(isLiked ? 'Like added successfully' : 'Like removed successfully');
      } else {
        print('Error toggling like: ${response.body}');
      }
    } catch (error) {
      print('Error toggling like: $error');
    }
  }

Future<String?> fetchLoggedInUsername(String apiBaseUrl) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // Ensure token is stored in SharedPreferences

    if (token == null) {
      throw Exception('JWT token is missing');
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/GP/v1/seller/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['Username']; // Replace 'Username' with the actual field in the API response
    } else {
      print('Failed to fetch user data: ${response.statusCode}, ${response.body}');
      return null;
    }
  } catch (error) {
    print('Error fetching user data: $error');
    return null;
  }
}



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Like Button
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: isLiked ? Color(0xFF3B4280) : Colors.grey,
                  ),
                  onPressed: _toggleLike, // Toggle like when clicked
                ),
                Text('$likesCount likes'),
              ],
            ),

            // Comment Button
            TextButton.icon(
              onPressed: () => _showComments(context),
              icon: Icon(Icons.comment_outlined, color: Color(0xFF3B4280)),
              label: Text('$commentsCount Comments'),
            ),
          ],
        ),
      ],
    );
  }

void _showComments(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          Expanded(
            child: FutureBuilder<String?>(
              future: fetchLoggedInUsername(widget.apiBaseUrl), // Fetch the logged-in username from the API
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show a loading spinner while fetching username
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching user data')); // Handle errors gracefully
                }

                final loggedInUsername = snapshot.data;

                return ListView.separated(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.person, // User icon
                          color: Colors.white, // Icon color
                        ),
                        backgroundColor: Color(0xFF3B4280), // Background color for the icon
                      ),
                      title: Text(
                        comment['createdBy'] ?? 'Unknown User', // Display the username
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        comment['content'] ?? '', // Display the comment content
                      ),
                      trailing: (comment['createdBy'] == loggedInUsername)
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(comment);
                                } else if (value == 'delete') {
                                  _deleteComment(comment['id']);
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
                            )
                          : null, // Show the menu only for the logged-in user's comments
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Color(0xFF3B4280), // Separator color
                    thickness: 1, // Optional: Thickness of the divider
                  ),
                );
              },
            ),
          ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final comment = commentController.text;
                    if (comment.isNotEmpty) {
                      _addComment(comment);
                      commentController.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


void _editComment(Map<String, dynamic> comment) {
  showDialog(
    context: context,
    builder: (context) {
      final editController = TextEditingController(text: comment['content']);
      return AlertDialog(
        title: Text('Edit Comment'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Edit your comment',
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
                await _updateComment(comment['id'], updatedContent);
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

Future<void> _updateComment(int commentId, String content) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.patch(
      Uri.parse('${widget.apiBaseUrl}/GP/v1/community/editComment/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      print('Comment updated successfully');
      _fetchComments(); // Refresh the comments
    } else {
      print('Error updating comment: ${response.body}');
    }
  } catch (error) {
    print('Error updating comment: $error');
  }
}


Future<void> _deleteComment(int commentId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.delete(
      Uri.parse('${widget.apiBaseUrl}/GP/v1/community/deleteComment/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Comment deleted successfully');
      _fetchComments(); // Refresh the comments
    } else {
      print('Error deleting comment: ${response.body}');
    }
  } catch (error) {
    print('Error deleting comment: $error');
  }
}


  Future<void> _addComment(String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/GP/v1/community/addComment/${widget.postId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        print('Comment added successfully');
        _fetchComments(); // Refresh comments after adding a new one
      } else {
        print('Error adding comment: ${response.body}');
      }
    } catch (error) {
      print('Error adding comment: $error');
    }
  }
}
