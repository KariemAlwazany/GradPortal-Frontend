import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Get JWT token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Fetch the count of student approval requests
  static Future<int> fetchStudentRequestCount() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.10:3000/GP/v1/projects/WaitingList/student/count'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data']['count'] ?? 0;
        } else {
          throw Exception('Failed to retrieve student request count');
        }
      } else {
        throw Exception('Failed to load student request count');
      }
    } catch (e) {
      print('Error: $e');
      return 0; // Return 0 in case of an error
    }
  }

  // Fetch the count of project approval requests
  static Future<int> fetchProjectRequestCount() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:3000/GP/v1/projects/WaitingList/projects/count'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data']['count'] ?? 0;
        } else {
          throw Exception('Failed to retrieve project request count');
        }
      } else {
        throw Exception('Failed to load project request count');
      }
    } catch (e) {
      print('Error: $e');
      return 0; // Return 0 in case of an error
    }
  }

  // Fetch the list of project approval requests
  static Future<List<Map<String, dynamic>>> fetchProjectRequests() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:3000/GP/v1/projects/WaitingList/getCurrent/project-list'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          List<dynamic> waitingList = responseData['data']['waitingList'];
          return waitingList
              .map((item) => {
                    'student1': item['Partner_1'],
                    'student2': item['Partner_2'],
                    'title': item['ProjectTitle'] ?? 'No Title',
                    'description':
                        item['ProjectDescription'] ?? 'No Description',
                  })
              .toList();
        } else {
          throw Exception('Failed to retrieve project list');
        }
      } else {
        throw Exception('Failed to load project list');
      }
    } catch (e) {
      print('Error: $e');
      return []; // Return empty list in case of an error
    }
  }
}
