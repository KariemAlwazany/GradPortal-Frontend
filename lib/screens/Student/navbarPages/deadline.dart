import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/files.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);

class DeadlinePage extends StatelessWidget {
  const DeadlinePage({super.key});

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Method to parse and format date
  String formatDate(String rawDate) {
    try {
      DateTime parsedDate;

      // Trim any extra spaces
      rawDate = rawDate.trim();

      // Check if the date is in ISO format (e.g., 2024-11-12T16:34:00.000)
      if (rawDate.contains('T')) {
        parsedDate = DateTime.parse(rawDate); // Parse ISO 8601 format
      } else {
        // Custom date format handling (e.g., 2024-12-21 2:14 AM)
        DateFormat inputFormat = DateFormat('yyyy-MM-dd h:mm a');
        parsedDate = inputFormat.parseStrict(rawDate); // Parse custom format
      }

      // Return formatted date
      return DateFormat('yyyy-MM-dd h:mm a').format(parsedDate);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date'; // Return a fallback text if date parsing fails
    }
  }

  Future<List<Map<String, String>>> fetchDeadlines() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/student/deadlines'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['status'] == 'success') {
        final deadlines = body['data']['deadLines'] as List;
        return deadlines.map((item) {
          String rawDate = item['Date'] as String;
          String formattedDate = formatDate(rawDate); // Format the date
          return {
            'title': item['Title'] as String,
            'date': formattedDate, // Use the formatted date
          };
        }).toList();
      } else {
        throw Exception('Failed to load deadlines');
      }
    } else {
      throw Exception('Failed to load deadlines');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(),
          ),
          padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Deadlines',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, String>>>(
              future: fetchDeadlines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No deadlines available.'));
                }

                final deadlines = snapshot.data!;
                return ListView.builder(
                  itemCount: deadlines.length,
                  itemBuilder: (context, index) {
                    final deadline = deadlines[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading:
                            Icon(Icons.calendar_today, color: primaryColor),
                        title: Text(
                          deadline['title']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Due Date: ${deadline['date']}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeadlinesPage(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
