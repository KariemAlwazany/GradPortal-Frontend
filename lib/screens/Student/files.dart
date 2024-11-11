import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

const Color primaryColor = Color(0xFF3B4280);

class UploadFilesPage extends StatefulWidget {
  @override
  _UploadFilesPageState createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  final List<Map<String, dynamic>> submissions = [
    {
      'projectTitle': 'AI Research Project',
      'submitTitle': 'Final Report Submission',
      'deadline': '2024-12-01',
    },
    {
      'projectTitle': 'IoT in Smart Cities',
      'submitTitle': 'Midterm Report',
      'deadline': '2024-11-20',
    },
    {
      'projectTitle': 'Blockchain Technology',
      'submitTitle': 'Initial Research Paper',
      'deadline': '2024-11-25',
    },
  ];

  Map<String, String?> uploadedFiles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Upload Files', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return _buildUploadCard(
              context,
              projectTitle: submission['projectTitle'],
              submitTitle: submission['submitTitle'],
              deadline: submission['deadline'],
              submissionIndex: index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadCard(
    BuildContext context, {
    required String projectTitle,
    required String submitTitle,
    required String deadline,
    required int submissionIndex,
  }) {
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
              submitTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Project: $projectTitle',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 4.0),
            Text(
              'Deadline: $deadline',
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            SizedBox(height: 12.0),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text('Upload File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                _selectFile(context, submissionIndex);
              },
            ),
            if (uploadedFiles.containsKey(submissionIndex.toString()) &&
                uploadedFiles[submissionIndex.toString()] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Uploaded File: ${uploadedFiles[submissionIndex.toString()]}',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile(BuildContext context, int submissionIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // You can restrict the file types if needed
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final fileName = result.files.single.name;
      setState(() {
        uploadedFiles[submissionIndex.toString()] = fileName;
      });

      // Handle file upload logic here. For now, it just prints the file path.
      print('Selected file: ${result.files.single.path}');
    } else {
      // User canceled the picker
      print('No file selected');
    }
  }
}
