import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);

class PostDeadlinesPage extends StatefulWidget {
  const PostDeadlinesPage({super.key});

  @override
  _PostDeadlinesPageState createState() => _PostDeadlinesPageState();
}

class _PostDeadlinesPageState extends State<PostDeadlinesPage> {
  final TextEditingController titleController = TextEditingController();
  String? selectedFileName;
  String? description;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> deadlines = [];

  @override
  void initState() {
    super.initState();
    fetchDeadlines(); // Load deadlines when the page is loaded
  }

  // Fetch deadlines from the backend
  Future<void> fetchDeadlines() async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/doctor/deadlines');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          deadlines = List<Map<String, dynamic>>.from(
              data['data']['deadLines'].map((deadline) => {
                    'id': deadline['id'],
                    'Doctor': deadline['Doctor'],
                    'title': deadline['Title'],
                    'description': deadline['Description'],
                    'date': DateTime.parse(deadline['Date']),
                    'file': deadline[
                        'File'], // Highlighting the file URL storage here
                  }));
        });
      }
    } else {
      print('Failed to fetch deadlines: ${response.statusCode}');
    }
  }

  // Select a file
  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFileName = result.files.single.name;
      });
      print('Selected file: ${result.files.single.path}');
    }
  }

  // Show "More Options" dialog for adding or editing
  Future<void> showMoreOptionsDialog({int? index}) async {
    TextEditingController descriptionController =
        TextEditingController(text: description ?? '');
    TextEditingController titleDialogController =
        TextEditingController(text: titleController.text);

    if (index != null) {
      titleDialogController.text = deadlines[index]['title'];
      descriptionController.text = deadlines[index]['description'];
      selectedDate = deadlines[index]['date'];
      selectedTime = TimeOfDay(
        hour: deadlines[index]['date'].hour,
        minute: deadlines[index]['date'].minute,
      );
      selectedFileName = deadlines[index]['file'];
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'More Options' : 'Edit Deadline'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleDialogController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => selectDateTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(
                  selectedDate == null || selectedTime == null
                      ? 'Select Deadline Date & Time'
                      : 'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ))}',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: selectFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(
                  selectedFileName == null
                      ? 'Select File'
                      : 'Selected File: $selectedFileName',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              titleController.text = titleDialogController.text;
              description = descriptionController.text;
              final dateTime = selectedDate != null && selectedTime != null
                  ? DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    )
                  : null;

              if (index == null) {
                addDeadlineLocally(
                  titleDialogController.text,
                  description ?? '',
                  dateTime,
                  selectedFileName,
                );
              } else {
                editDeadlineLocally(
                  index,
                  titleDialogController.text,
                  description ?? '',
                  dateTime,
                  selectedFileName,
                );
              }
              clearInputs();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Local function to add a deadline and send it to the backend
  void addDeadlineLocally(
      String title, String description, DateTime? dateTime, String? fileName) {
    final newDeadline = {
      'id': DateTime.now().millisecondsSinceEpoch, // Temp ID for UI
      'title': title,
      'description': description,
      'date': dateTime,
      'file': fileName, // Saving file name/URL here
    };
    setState(() {
      deadlines.add(newDeadline);
    });
    postDeadline(
        newDeadline); // Send the dateTime as part of the newDeadline map
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Post a new deadline to the backend
  Future<void> postDeadline(Map<String, dynamic> deadline) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/doctor/deadlines');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Title': deadline['title'],
        'Description': deadline['description'],
        'Date': deadline['date']?.toIso8601String(),
        'File': deadline['file'], // Highlighted to store file as URL here
      }),
    );

    if (response.statusCode == 201) {
      print('Deadline posted successfully');
      fetchDeadlines(); // Refresh deadlines after posting
    } else {
      print('Failed to post deadline: ${response.statusCode}');
    }
  }

  // Edit deadline locally and update on backend
  void editDeadlineLocally(int index, String title, String description,
      DateTime? dateTime, String? fileName) {
    final id = deadlines[index]['id'];
    setState(() {
      deadlines[index] = {
        'id': id,
        'title': title,
        'description': description,
        'date': dateTime,
        'file': fileName, // File URL or name maintained here for updates
      };
    });
    updateDeadline(deadlines[index]);
  }

  // Update an existing deadline on the backend
  Future<void> updateDeadline(Map<String, dynamic> deadline) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/doctor/deadlines');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': deadline['id'], // Including ID in the body
        'Title': deadline['title'],
        'Description': deadline['description'],
        'Date': deadline['date']?.toIso8601String(),
        'File': deadline['file'], // Highlighted to store file as URL here
      }),
    );

    if (response.statusCode == 200) {
      print('Deadline updated successfully');
      fetchDeadlines(); // Refresh deadlines after updating
    } else {
      print('Failed to update deadline: ${response.statusCode}');
    }
  }

  // Delete a deadline locally and on the backend
  void deleteDeadline(int index) {
    final id = deadlines[index]['id'];
    setState(() {
      deadlines.removeAt(index);
    });
    deleteDeadlineBE(id);
  }

  Future<void> deleteDeadlineBE(int id) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/doctor/deadlines');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id, // Including ID in the body
      }),
    );

    if (response.statusCode == 200) {
      print('Deadline deleted successfully');
      fetchDeadlines(); // Refresh deadlines after deletion
    } else {
      print('Failed to delete deadline: ${response.statusCode}');
    }
  }

  // Select date and time
  Future<void> selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  // Clear input fields
  void clearInputs() {
    titleController.clear();
    description = null;
    selectedDate = null;
    selectedTime = null;
    selectedFileName = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Post Deadlines',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Deadline input section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => showMoreOptionsDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: Text('More Options'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => showMoreOptionsDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      ),
                      child: Text('Add Deadline'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Deadline list section
            Expanded(
              child: deadlines.isEmpty
                  ? Center(
                      child: Text(
                        'No deadlines posted yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: deadlines.length,
                      itemBuilder: (context, index) {
                        final deadline = deadlines[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              deadline['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (deadline['description'] != null &&
                                    deadline['description'].isNotEmpty)
                                  Text(
                                      'Description: ${deadline['description']}'),
                                if (deadline['date'] != null)
                                  Text(
                                    'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(deadline['date'])}',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                if (deadline['file'] != null)
                                  Text('File: ${deadline['file']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      showMoreOptionsDialog(index: index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteDeadline(index),
                                ),
                              ],
                            ),
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
