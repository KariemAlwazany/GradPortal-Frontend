import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

const Color primaryColor = Color(0xFF3B4280);

class ViewFilesPage extends StatefulWidget {
  const ViewFilesPage({super.key});

  @override
  _ViewFilesPageState createState() => _ViewFilesPageState();
}

class _ViewFilesPageState extends State<ViewFilesPage> {
  String selectedCategory = 'All';
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchSubmissions() async {
    final token = await getToken();
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/submit/doctor');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        submissions =
            List<Map<String, dynamic>>.from(data['data']['submissions']);
      });
    } else {
      print('Failed to fetch submissions: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubmissions = selectedCategory == 'All'
        ? submissions
        : submissions
            .where(
                (submission) => submission['ProjectType'] == selectedCategory)
            .toList();

    final Map<String, List<Map<String, dynamic>>> groupedSubmissions = {};
    for (var submission in filteredSubmissions) {
      groupedSubmissions
          .putIfAbsent(
              submission['ProjectTitle'] ?? 'Unknown Project', () => [])
          .add(submission);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('View Files', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('All'),
                  selected: selectedCategory == 'All',
                  selectedColor: primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = 'All';
                    });
                  },
                  labelStyle: TextStyle(
                    color:
                        selectedCategory == 'All' ? Colors.white : primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                ChoiceChip(
                  label: Text('Hardware'),
                  selected: selectedCategory == 'Hardware',
                  selectedColor: primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = 'Hardware';
                    });
                  },
                  labelStyle: TextStyle(
                    color: selectedCategory == 'Hardware'
                        ? Colors.white
                        : primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                ChoiceChip(
                  label: Text('Software'),
                  selected: selectedCategory == 'Software',
                  selectedColor: primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = 'Software';
                    });
                  },
                  labelStyle: TextStyle(
                    color: selectedCategory == 'Software'
                        ? Colors.white
                        : primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: groupedSubmissions.entries.map((entry) {
                  return _buildProjectGroup(
                    context,
                    projectTitle: entry.key,
                    submissions: entry.value,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGroup(
    BuildContext context, {
    required String projectTitle,
    required List<Map<String, dynamic>> submissions,
  }) {
    final studentNames = submissions
        .map((submission) =>
            '${submission['Student1'] ?? 'Unknown'} & ${submission['Student2'] ?? 'Unknown'}')
        .toSet()
        .join(", ");

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ExpansionTile(
        title: Text(
          projectTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        subtitle: Text(
          'Students: $studentNames',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        children: submissions.map((submission) {
          return _buildSubmissionCard(
            context,
            submitTitle: submission['SubmissionTitle'] ?? 'No Title',
            submissionDate: submission['SubmissionDate'] ?? 'No Date',
            files: [
              {
                'fileName': submission['FileSubmitted'] ?? 'No file',
                'url':
                    'https://example.com/${submission['FileSubmitted'] ?? ''}'
              }
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context, {
    required String submitTitle,
    required String submissionDate,
    required List<Map<String, String>> files,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ExpansionTile(
          title: Text(
            submitTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          subtitle: Text(
            'Submitted on: $submissionDate',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          children: files
              .map((file) => _buildFileRow(file['fileName']!, file['url']!))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFileRow(String fileName, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(fileName, style: TextStyle(fontSize: 16)),
          IconButton(
            icon: Icon(Icons.download, color: primaryColor),
            onPressed: () async {
              await _downloadFile(fileName, url);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String fileName, String url) async {
    try {
      // Get the directory for storing the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Use Dio to download the file
      final dio = Dio();
      await dio.download(url, filePath);

      // Notify user about the successful download
      print('File downloaded to $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded: $fileName')),
      );
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download $fileName')),
      );
    }
  }
}
