import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);

class ManageDoctorsTransferPage extends StatefulWidget {
  @override
  _ManageDoctorsTransferPageState createState() =>
      _ManageDoctorsTransferPageState();
}

class _ManageDoctorsTransferPageState extends State<ManageDoctorsTransferPage> {
  List<Map<String, dynamic>> doctors = [
    {'name': 'Dr. Alice Johnson', 'role': 'Head Doctor', 'isHeadDoctor': true},
    {
      'name': 'Dr. Bob Brown',
      'role': 'Assistant Doctor',
      'isHeadDoctor': false
    },
    {
      'name': 'Dr. Charlie Davis',
      'role': 'Assistant Doctor',
      'isHeadDoctor': false
    },
  ];

  void transferHeadDoctorRole(String newHeadDoctor) {
    setState(() {
      for (var doctor in doctors) {
        doctor['isHeadDoctor'] = doctor['name'] == newHeadDoctor;
        doctor['role'] =
            doctor['isHeadDoctor'] ? 'Head Doctor' : 'Assistant Doctor';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Head Doctor role transferred to $newHeadDoctor'),
        backgroundColor: primaryColor,
      ),
    );
  }

  void confirmTransfer(String doctorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Transfer'),
        content:
            Text('Are you sure you want to make $doctorName the Head Doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              transferHeadDoctorRole(doctorName);
            },
            child: Text('Confirm', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Manage Doctors Transfer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
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
                      doctor['name'],
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Role: ${doctor['role']}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 16),
                    if (!doctor['isHeadDoctor'])
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => confirmTransfer(doctor['name']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Make Head Doctor'),
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
