import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Admin/admin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoomsPage extends StatefulWidget {
  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  List<dynamic> rooms = [];
  final TextEditingController roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  // Fetch the rooms from the API
  Future<void> fetchRooms() async {
    final token = await getToken();
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/room');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        rooms = json.decode(response.body)['data'] ?? [];
      });
    } else {
      print('Failed to load rooms');
    }
  }

  // Get JWT token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Create a new room
  Future<void> createRoom() async {
    final roomName = roomController.text.trim();
    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Room name cannot be empty')));
      return;
    }

    final token = await getToken();
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/room');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'Room': roomName}),
    );

    if (response.statusCode == 201) {
      setState(() {
        // Add the newly created room to the list
        rooms.add(json.decode(response.body)['data']);
      });
      roomController.clear(); // Clear the input field after creating the room
    } else {
      print('Failed to create room');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create room')));
    }
  }

  // Update room
  Future<void> updateRoom(int id, String roomName) async {
    final token = await getToken();
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/room/$id');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'Room': roomName}),
    );

    if (response.statusCode == 200) {
      fetchRooms(); // Refresh the list
    } else {
      print('Failed to update room');
    }
  }

  // Delete room
  Future<void> deleteRoom(int id) async {
    final token = await getToken();
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/room/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        rooms.removeWhere((room) => room['id'] == id);
      });
    } else {
      print('Failed to delete room');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, // Keep your original primary color
        title: Text(
          'Manage Rooms',
          style: TextStyle(color: Colors.white), // Set title text to white
        ),
        iconTheme:
            IconThemeData(color: Colors.white), // Set back arrow icon to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: roomController,
              decoration: InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createRoom,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Create Room'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: rooms.isEmpty
                  ? Center(child: Text('No rooms available'))
                  : ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        var room = rooms[index];
                        return ListTile(
                          title: Text(room['Room'] ?? 'Unnamed Room'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Room'),
                                      content: TextField(
                                        controller: roomController
                                          ..text = room['Room'] ?? '',
                                        decoration: InputDecoration(
                                          labelText: 'Room Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            updateRoom(room['id'],
                                                roomController.text);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Update'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteRoom(room['id']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
