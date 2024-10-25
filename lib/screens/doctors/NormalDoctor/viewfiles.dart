import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ViewFilesPage extends StatelessWidget {
  final List<Map<String, dynamic>> submissions = [
    {
      'projectTitle': 'AI Research Project',
      'submitTitle': 'Final Report Submission',
      'files': [
        {'fileName': 'Report.pdf', 'url': 'https://example.com/report.pdf'},
        {
          'fileName': 'Presentation.pptx',
          'url': 'https://example.com/presentation.pptx'
        },
      ],
    },
    {
      'projectTitle': 'IoT in Smart Cities',
      'submitTitle': 'Midterm Report',
      'files': [
        {
          'fileName': 'IoT_Report.docx',
          'url': 'https://example.com/iot_report.docx'
        },
      ],
    },
    {
      'projectTitle': 'Blockchain Technology',
      'submitTitle': 'Initial Research Paper',
      'files': [
        {
          'fileName': 'Blockchain_Research.pdf',
          'url': 'https://example.com/blockchain_research.pdf'
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('View Files', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return _buildSubmissionCard(
              context,
              projectTitle: submission['projectTitle'],
              submitTitle: submission['submitTitle'],
              files: submission['files'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context, {
    required String projectTitle,
    required String submitTitle,
    required List<Map<String, String>> files,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
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
          'Project: $projectTitle',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        children: files
            .map((file) => _buildFileRow(file['fileName']!, file['url']!))
            .toList(),
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
            onPressed: () {
              // Handle file download logic here
              print('Downloading $url');
            },
          ),
        ],
      ),
    );
  }
}
