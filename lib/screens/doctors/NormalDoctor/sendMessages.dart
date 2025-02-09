import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color primaryColor = Color(0xFF3B4280);

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({super.key});

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  String selectedRecipient = 'All Students';
  List<String> gpGroups = [
    'All Students',
    'Software Projects',
    'Hardware Projects',
    'Head Doctor'
  ];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProjectTitles();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchProjectTitles() async {
    final token = await getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/doctors/students'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allStudents = data['data']['allStudents'] as List;

        setState(() {
          gpGroups.addAll(
            allStudents.map((student) => student['GP_Title'] as String),
          );
        });
      } else {
        print('Failed to load project titles');
      }
    }
  }

  Future<void> sendMessage() async {
    final token = await getToken();
    if (token == null) {
      print('Token is null');
      return;
    }

    try {
      // Send the message
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Message': messageController.text,
          'Receiver': selectedRecipient,
        }),
      );

      if (response.statusCode == 200) {
        print('Message sent to $selectedRecipient');
        messageController.clear();

        // If the recipient is 'All', notify all students
        if (selectedRecipient == 'All Students') {
          await notifyAllStudents();
        }
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> notifyAllStudents() async {
    final token = await getToken();
    if (token == null) {
      print('Token is null');
      return;
    }

    try {
      // Prepare additionalData with date and other details
      final additionalData = {
        'date': DateTime.now().toIso8601String(), // Add current date
        'message': 'New message from doctor for all students',
        // Add other fields as needed
      };

      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/notification/doctor/notifyMyStudents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': 'New Message',
          'body': 'New message from doctor for all students',
          'additionalData': additionalData, // Include additionalData
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent to all students');
      } else {
        print('Failed to notify students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error notifying students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Send Message', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewMessagesPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Recipient',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedRecipient,
              items: gpGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRecipient = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Message',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Type your message here...',
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  sendMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Send Message',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewMessagesPage extends StatefulWidget {
  const ViewMessagesPage({super.key});

  @override
  _ViewMessagesPageState createState() => _ViewMessagesPageState();
}

class _ViewMessagesPageState extends State<ViewMessagesPage> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchMessages() async {
    final token = await getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/messages/doctors/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final findMessage = data['data']['findMessage'] as List;

        setState(() {
          messages = findMessage
              .map((message) => {
                    'id': message['id'],
                    'Sender': message['Sender'],
                    'Receiver': message['Receiver'],
                    'Message': message['Message'],
                    'createdAt': message['createdAt'],
                  })
              .toList();
        });
      } else {
        print('Failed to load messages');
      }
    }
  }

  Future<void> deleteMessage(int id) async {
    final token = await getToken();
    if (token != null) {
      // Remove the message immediately from the UI
      setState(() {
        messages.removeWhere((message) => message['id'] == id);
      });

      // Send delete request to the server
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
        }),
      );

      if (response.statusCode != 200) {
        // Optional: show error or restore the message if the deletion failed
        print('Failed to delete message from server');
        // Restore the message if deletion failed
        fetchMessages(); // Reload messages from the server to ensure consistency
      }
    }
  }

  void showEditDialog(int id, String currentMessage) {
    final TextEditingController editController =
        TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Enter new message...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                await editMessage(id, editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> editMessage(int id, String newMessage) async {
    final token = await getToken();
    if (token != null) {
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'Message': newMessage,
        }),
      );

      if (response.statusCode == 200) {
        fetchMessages();
      } else {
        print('Failed to edit message');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('View Messages', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  'To: ${message['Receiver']}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(message['Message']),
                    SizedBox(height: 4),
                    Text(
                      'Sent on: ${message['createdAt']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () =>
                          showEditDialog(message['id'], message['Message']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteMessage(message['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
