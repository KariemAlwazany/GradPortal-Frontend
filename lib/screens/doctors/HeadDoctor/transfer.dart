import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class TransferStudentPage extends StatefulWidget {
  @override
  _TransferStudentPageState createState() => _TransferStudentPageState();
}

class _TransferStudentPageState extends State<TransferStudentPage> {
  // Sample list of students with assigned doctors
  final List<Map<String, dynamic>> students = [
    {
      'id': 1,
      'name': 'John Doe',
      'currentDoctor': 'Dr. Raed Alqadi',
      'newDoctor': null,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'currentDoctor': 'Dr. Emily Williams',
      'newDoctor': null,
    },
  ];

  final List<String> doctorOptions = [
    'Dr. Raed Alqadi',
    'Dr. Smith Johnson',
    'Dr. Emily Williams',
  ];

  // Function to transfer a student to a new doctor
  void transferStudent(int index) {
    if (students[index]['newDoctor'] != null &&
        students[index]['newDoctor'] != students[index]['currentDoctor']) {
      setState(() {
        students[index]['currentDoctor'] = students[index]['newDoctor'];
        students[index]['newDoctor'] = null; // Reset newDoctor after transfer
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Transferred ${students[index]['name']} to ${students[index]['currentDoctor']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select a different doctor for ${students[index]['name']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Transfer Student to Another Doctor',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: students.isEmpty
            ? Center(
                child: Text(
                  'No students available for transfer.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Name: ${student['name']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Current Doctor: ${student['currentDoctor']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Transfer to Doctor',
                                border: OutlineInputBorder(),
                              ),
                              value: student['newDoctor'],
                              items: doctorOptions
                                  .where((doctor) =>
                                      doctor !=
                                      student[
                                          'currentDoctor']) // Exclude current doctor from options
                                  .map((doctor) {
                                return DropdownMenuItem(
                                  value: doctor,
                                  child: Text(doctor),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  student['newDoctor'] = value;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => transferStudent(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: Text('Transfer Student'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
