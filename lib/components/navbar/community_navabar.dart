import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/Community/chat_screen.dart';
import 'package:flutter_project/screens/Community/main_screen.dart';
import 'package:flutter_project/screens/Community/profile_community_screen.dart';
import 'package:flutter_project/screens/Community/show_users_for_chat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color primaryColor = Color(0xFF3B4280);

class CommunityNavbar extends StatefulWidget {
  const CommunityNavbar({Key? key}) : super(key: key);

  @override
  _CommunityNavbarState createState() => _CommunityNavbarState();
}

class _CommunityNavbarState extends State<CommunityNavbar> {
  int _selectedIndex = 0;
  int? currentUserId;
  bool _isLoading = true;
  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('JWT token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/GP/v1/seller/role'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        print(user);
        setState(() {
          currentUserId = user['id'];
          print(currentUserId);

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load current user ID');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching current user ID: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _pages = [
      CommunityScreen(),
      UserListScreen(currentUserId: currentUserId!),
      ProfileScreen(),
    ];


    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'News Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
