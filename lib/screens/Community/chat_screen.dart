import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String? username;

  ChatScreen(
      {required this.senderId,
      required this.receiverId,
      required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

///ChatScreen(userid,receiverId,userNameOfReceiver)

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();
  String? _message;
  String loggedInUsername = "";
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<void> _fetchLoggedInUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

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
          print(loggedInUsername);
        });
      } else {
        throw Exception('Failed to fetch id');
      }
    } catch (error) {
      print('Error fetching id: $error');
    }
  }

  Future<void> _sendNotification(String receiverId, String message) async {
    print(
        'Invoking _sendNotification with receiverId: $receiverId and message: $message');
    _fetchLoggedInUsername();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print('No JWT token found');
        return;
      }

      // Validate receiverId
      if (receiverId.isEmpty) {
        print('Invalid receiverId: Empty string');
        return;
      }

      int parsedReceiverId;
      try {
        parsedReceiverId =
            int.parse(receiverId); // Convert receiverId to an integer
      } catch (e) {
        print('Error parsing receiverId: $receiverId is not a valid number');
        return;
      }

      // Send the notification
      final response = await http.post(
        Uri.parse('$baseUrl/GP/v1/notification/notifyUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "userId": parsedReceiverId,
          "title": "Gradhub",
          "body": "$loggedInUsername: $message",
          "additionalData": {"chat": "true"}
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _sendMessage() async {
    if (_message != null && _message!.trim().isNotEmpty) {
      final messageToSend = _message;

      print('Sending message: $messageToSend');
      await _firestore.collection('messages').add({
        'text': messageToSend,
        'sender_id': widget.senderId.toString(),
        'receiver_id': widget.receiverId.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      setState(() {
        _message = null;
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      // Use the saved message for notification
      print('Calling _sendNotification');
      await _sendNotification(widget.receiverId.toString(), messageToSend!);
    }
  }

  Stream<QuerySnapshot> _getChatMessages() {
    return _firestore
        .collection('messages')
        .where('sender_id',
            whereIn: [widget.senderId.toString(), widget.receiverId.toString()])
        .where('receiver_id',
            whereIn: [widget.senderId.toString(), widget.receiverId.toString()])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username ?? 'Chat',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3B4280),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getChatMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<MessageBubble> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['text'];
                  final messageSender = message['sender_id'];
                  final messageTime =
                      (message['timestamp'] as Timestamp?)?.toDate();

                  final messageWidget = MessageBubble(
                    text: messageText,
                    isMe: messageSender == widget.senderId.toString(),
                    timestamp: messageTime,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  reverse: true,
                  controller: _scrollController,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      setState(() {
                        _message = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF3B4280)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF3B4280)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF3B4280)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;

  const MessageBubble({
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (timestamp != null)
            Text(
              DateFormat('hh:mm a').format(timestamp!),
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5.0,
            color: Color(0xFF3B4280),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
