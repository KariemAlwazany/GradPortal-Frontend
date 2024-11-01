import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ManageStudentRequestsPage extends StatefulWidget {
  @override
  _ManageStudentRequestsPageState createState() =>
      _ManageStudentRequestsPageState();
}

class _ManageStudentRequestsPageState extends State<ManageStudentRequestsPage> {
  // Sample list of student requests and doctor options
  final List<Map<String, dynamic>> studentRequests = [
    {
      'id': 1,
      'name': 'John Doe',
      'studentId': 'S12345',
      'selectedDoctor': null,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'studentId': 'S67890',
      'selectedDoctor': null,
    },
  ];

  final List<String> doctorOptions = [
    'Dr. Raed Alqadi',
    'Dr. Smith Johnson',
    'Dr. Emily Williams',
  ];

  // Function to save the selected doctor for a student
  void saveRequest(int index) {
    if (studentRequests[index]['selectedDoctor'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Assigned ${studentRequests[index]['selectedDoctor']} to ${studentRequests[index]['name']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select a doctor for ${studentRequests[index]['name']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Manage Student Registration',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentRequests.isEmpty
            ? Center(
                child: Text(
                  'No registration requests.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: studentRequests.length,
                itemBuilder: (context, index) {
                  final request = studentRequests[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Name: ${request['name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Student ID: ${request['studentId']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Assign to Doctor',
                              border: OutlineInputBorder(),
                            ),
                            value: request['selectedDoctor'],
                            items: doctorOptions.map((doctor) {
                              return DropdownMenuItem(
                                value: doctor,
                                child: Text(doctor),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                request['selectedDoctor'] = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => saveRequest(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: Text('Save Request'),
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
