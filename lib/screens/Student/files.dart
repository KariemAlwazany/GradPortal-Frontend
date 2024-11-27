import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);

class DeadlinesPage extends StatefulWidget {
  const DeadlinesPage({super.key});

  @override
  _DeadlinesPageState createState() => _DeadlinesPageState();
}

class _DeadlinesPageState extends State<DeadlinesPage> {
  List<Map<String, dynamic>> deadlines = [];

  @override
  void initState() {
    super.initState();
    fetchDeadlines();
  }

  Future<void> fetchDeadlines() async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/student/deadlines');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Populate deadlines and fetch file submissions for each deadline
        final deadlineList =
            List<Map<String, dynamic>>.from(data['data']['deadLines']);
        for (var deadline in deadlineList) {
          final submission = await fetchSubmittedFile(deadline['id']);
          if (submission != null) {
            deadline['FileSubmitted'] = submission['FileSubmitted'];
            deadline['SubmissionDate'] = submission['Date'];
          }
        }
        setState(() {
          deadlines = deadlineList;
        });
      } else {
        print('Failed to fetch data: ${data['message']}');
      }
    } else {
      print('Failed to fetch deadlines: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> fetchSubmittedFile(int taskId) async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/submit/student');
    final request = http.Request('GET', url)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'TaskID': taskId.toString(),
      });

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['data']['findSubmit'] != null) {
        return data['data']['findSubmit'];
      } else {
        print('No submission found for TaskID: $taskId');
      }
    } else {
      print('Failed to fetch submission details for TaskID: $taskId');
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Deadlines', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: deadlines.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: deadlines.length,
                itemBuilder: (context, index) {
                  final deadline = deadlines[index];
                  final submissionId = deadline['id'];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deadline['Title'] ?? 'No Title',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(deadline['Date']))}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.redAccent),
                          ),
                          if (deadline['FileSubmitted'] != null) ...[
                            SizedBox(height: 8.0),
                            Text(
                              'Submitted File: ${deadline['FileSubmitted']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            if (deadline['SubmissionDate'] != null)
                              Text(
                                'Submission Date: ${deadline['SubmissionDate']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                          SizedBox(height: 12.0),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 20.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeadlineDetailsPage(
                                      deadline: deadline,
                                      onFileUpload: (String fileName) {
                                        setState(() {
                                          // Logic to update the file name, if needed
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Text('Details'),
                            ),
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

class DeadlineDetailsPage extends StatefulWidget {
  final Map<String, dynamic> deadline;
  final Function(String) onFileUpload;

  const DeadlineDetailsPage({
    super.key,
    required this.deadline,
    required this.onFileUpload,
  });

  @override
  _DeadlineDetailsPageState createState() => _DeadlineDetailsPageState();
}

class _DeadlineDetailsPageState extends State<DeadlineDetailsPage> {
  String? uploadedFileName;
  String? submissionDate;
  bool isFileSaved = false;
  bool showSubmitButton = false;

  @override
  void initState() {
    super.initState();
    fetchSubmittedFile();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchSubmittedFile() async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/submit/student');
    final request = http.Request('GET', url)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'TaskID': widget.deadline['id'].toString(),
      });

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['data']['findSubmit'] != null) {
        final submission = data['data']['findSubmit'];
        setState(() {
          uploadedFileName = submission['FileSubmitted'];
          submissionDate = submission['Date'];
          isFileSaved = uploadedFileName != null;
        });
      } else {
        print('No submission found or failed to fetch data.');
      }
    } else {
      print('Failed to fetch submission details: ${response.statusCode}');
    }
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        uploadedFileName = result.files.single.name;
        isFileSaved = false;
        showSubmitButton = false;
      });
      widget.onFileUpload(result.files.single.name);
    } else {
      print('No file selected');
    }
  }

  void _removeFile() {
    setState(() {
      uploadedFileName = null;
      isFileSaved = false;
      showSubmitButton = true;
    });
  }

  void _editFile() {
    _selectFile();
  }

  void _saveFile() {
    setState(() {
      isFileSaved = true;
      showSubmitButton = true;
    });
  }

  Future<void> _submitFile() async {
    final token = await getToken();
    final currentDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    final submissionData = {
      'TaskID': widget.deadline['id'],
      'Title': widget.deadline['Title'],
      'Doctor': widget.deadline['Doctor'],
      'Date': currentDate,
      'FileSubmitted': uploadedFileName,
    };

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/submit/student');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(submissionData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File Submitted Successfully')),
      );
      setState(() {
        submissionDate = currentDate;
        showSubmitButton = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File submission failed')),
      );
    }
  }

  Future<void> _downloadFile(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Deadline Details', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Deadline at the top
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.deadline['Title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            color: primaryColor, size: 20),
                        SizedBox(width: 8.0),
                        Text(
                          'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.deadline['Date']))}',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[300], thickness: 1, height: 24),
              // Description with icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: primaryColor, size: 28),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          widget.deadline['Description'] ?? 'No Description',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              // Display submission date if available
              if (submissionDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Submitted on: $submissionDate',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              // File Upload and Trash Button
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                      ),
                      onPressed: _selectFile,
                    ),
                    if (isFileSaved)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _removeFile,
                        tooltip: 'Remove File',
                      ),
                  ],
                ),
              ),
              if (uploadedFileName != null && !isFileSaved)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: _saveFile,
                        tooltip: 'Save File',
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: _editFile,
                        tooltip: 'Edit File',
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: _removeFile,
                        tooltip: 'Cancel Upload',
                      ),
                    ],
                  ),
                ),
              if (isFileSaved)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'File Saved: $uploadedFileName',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              if (widget.deadline['File'] != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.download, color: Colors.white),
                      label: Text('Download Attached File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                      ),
                      onPressed: () => _downloadFile(widget.deadline['File']),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: showSubmitButton
          ? FloatingActionButton(
              onPressed: _submitFile,
              backgroundColor: primaryColor,
              child: Icon(Icons.send),
            )
          : null,
    );
  }
}
