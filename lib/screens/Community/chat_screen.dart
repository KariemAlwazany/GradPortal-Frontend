import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String? username;

  ChatScreen({required this.senderId, required this.receiverId, required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();

  String? _message;

  void _sendMessage() async {
    if (_message != null && _message!.trim().isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': _message,
        'sender_id': widget.senderId.toString(), // Convert int to String
        'receiver_id': widget.receiverId.toString(), // Convert int to String
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
    }
  }

  Stream<QuerySnapshot> _getChatMessages() {
    return _firestore
        .collection('messages')
        .where('sender_id', whereIn: [
          widget.senderId.toString(),
          widget.receiverId.toString()
        ])
        .where('receiver_id', whereIn: [
          widget.senderId.toString(),
          widget.receiverId.toString()
        ])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username ?? 'Chat', style: TextStyle(color: Colors.white)),
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
                  final messageTime = (message['timestamp'] as Timestamp?)?.toDate();

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
            color: Color(0xFF3B4280), // Set bubble color for both sender and receiver
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
