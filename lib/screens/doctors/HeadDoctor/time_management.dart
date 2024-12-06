import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/tracking_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class DeadlineManagementPage extends StatefulWidget {
  @override
  _DeadlineManagementPageState createState() => _DeadlineManagementPageState();
}

class _DeadlineManagementPageState extends State<DeadlineManagementPage> {
  List<Map<String, dynamic>> deadlines = [
    {
      'title': 'Joining Application',
      'icon': Icons.app_registration,
      'deadline': '2024-12-15 12:00 PM',
      'visible': true,
    },
    {
      'title': 'Find Partners',
      'icon': Icons.group_add,
      'deadline': '2024-12-20 05:00 PM',
      'visible': true,
    },
    {
      'title': 'Find Doctor',
      'icon': Icons.person_search,
      'deadline': '2024-12-25 03:00 PM',
      'visible': true,
    },
    {
      'title': 'Submit Abstract',
      'icon': Icons.description,
      'deadline': '2025-01-05 11:59 PM',
      'visible': true,
    },
    {
      'title': 'Final Submission',
      'icon': Icons.assignment_turned_in,
      'deadline': '2025-01-15 11:59 PM',
      'visible': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? token = await getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/manage'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['fetchDates'][0];
        setState(() {
          deadlines = [
            {
              'title': 'Joining Application',
              'icon': Icons.app_registration,
              'deadline': data['JoinApplication'],
              'visible': data['JoinApplicationStatus'] == 'Show',
            },
            {
              'title': 'Find Partners',
              'icon': Icons.group_add,
              'deadline': data['FindPartners'],
              'visible': data['FindPartnersStatus'] == 'Show',
            },
            {
              'title': 'Find Doctor',
              'icon': Icons.person_search,
              'deadline': data['FindDoctor'],
              'visible': data['FindDoctorStatus'] == 'Show',
            },
            {
              'title': 'Submit Abstract',
              'icon': Icons.description,
              'deadline': data['SubmitAbstract'],
              'visible': data['SubmitAbstractStatus'] == 'Show',
            },
            {
              'title': 'Final Submission',
              'icon': Icons.assignment_turned_in,
              'deadline': data['FinalSubmission'],
              'visible': data['FinalSubmissionStatus'] == 'Show',
            },
          ];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
        ));
      }
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Deadlines'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.white),
            tooltip: 'View Student Status',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentStatusPage()),
              );
            },
          ),
        ],
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: deadlines.length + 1, // Add 1 for the new card
        itemBuilder: (context, index) {
          if (index == deadlines.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DeadlineCardForStudents(
                onEdit: _showEditStudentNumberDialog,
              ),
            );
          }
          final deadline = deadlines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DeadlineCard(
              title: deadline['title']!,
              icon: deadline['icon']!,
              deadline: deadline['deadline']!,
              visible: deadline['visible']!,
              onToggleVisibility: () {
                setState(() {
                  deadlines[index]['visible'] = !deadlines[index]['visible'];
                });
                _updateVisibility(index);
              },
              onEdit: () {
                _showEditDialog(context, index);
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) async {
    final deadline = deadlines[index];

    // Split the deadline into date and time components
    List<String> dateTimeParts = deadline['deadline']!.split(' ');
    DateTime? selectedDate = DateTime.tryParse(dateTimeParts[0]);
    selectedDate ??= DateTime.now();

    TimeOfDay? selectedTime = TimeOfDay(
      hour: int.parse(dateTimeParts[1].split(':')[0]),
      minute: int.parse(dateTimeParts[1].split(':')[1].split(' ')[0]),
    );

    final newDate = await showDatePicker(
      context: context,
      initialDate:
          selectedDate.isBefore(DateTime.now()) ? DateTime.now() : selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      final newTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (newTime != null) {
        final newDeadline =
            "${newDate.toIso8601String().split('T')[0]} ${newTime.format(context)}";

        setState(() {
          deadlines[index]['deadline'] = newDeadline;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${deadline['title']} deadline updated to $newDeadline',
            ),
          ),
        );

        _updateDeadline(index, newDeadline);
      }
    }
  }

  Future<void> _updateDeadline(int index, String newDeadline) async {
    String? token = await getToken();
    if (token != null) {
      final deadlineType = deadlines[index]['title'].replaceAll(' ', '');
      String key = deadlineType == "JoinApplication"
          ? "JoinApplication"
          : deadlineType == "FinalSubmission"
              ? "FinalSubmission"
              : deadlineType;

      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/manage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          key: newDeadline,
        }),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update deadline. Please try again later.'),
        ));
      }
    }
  }

  Future<void> _updateVisibility(int index) async {
    String? token = await getToken();
    if (token != null) {
      final deadlineType = deadlines[index]['title'].replaceAll(' ', '');
      final status = deadlines[index]['visible'] ? 'Show' : 'Hide';

      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/manage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          '${deadlineType}Status': status,
        }),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update visibility. Please try again later.'),
        ));
      }
    }
  }

  // New method to handle the student number update
  void _showEditStudentNumberDialog() async {
    final TextEditingController controller = TextEditingController();

    final int? studentNumber = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Student Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter student number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final int value = int.tryParse(controller.text) ?? 0;
                Navigator.pop(context, value);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (studentNumber != null) {
      // Send the student number to the API
      await _updateStudentNumber(studentNumber);
    }
  }

  Future<void> _updateStudentNumber(int studentNumber) async {
    String? token = await getToken();
    if (token != null) {
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/manage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'StudentNumber': studentNumber,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Student number updated successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Failed to update student number. Please try again later.'),
        ));
      }
    }
  }
}

class DeadlineCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String deadline;
  final bool visible;
  final VoidCallback onEdit;
  final VoidCallback onToggleVisibility;

  DeadlineCard({
    required this.title,
    required this.icon,
    required this.deadline,
    required this.visible,
    required this.onEdit,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1.0 : 0.5, // Adjust opacity for disabled state
      child: Card(
        elevation: visible ? 4 : 0, // Lower elevation if hidden
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 50, color: visible ? primaryColor : Colors.grey),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: visible ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Deadline: $deadline',
                      style: TextStyle(
                        fontSize: 16,
                        color: visible ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: visible ? primaryColor : Colors.grey),
                    tooltip: 'Edit Deadline',
                    onPressed: visible ? onEdit : null,
                  ),
                  IconButton(
                    icon: Icon(
                      visible ? Icons.visibility : Icons.visibility_off,
                      color: visible ? Colors.green : Colors.red,
                    ),
                    tooltip: visible ? 'Hide Deadline' : 'Show Deadline',
                    onPressed: onToggleVisibility,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New class for the "Manage Number of Students" card
class DeadlineCardForStudents extends StatelessWidget {
  final VoidCallback onEdit;

  DeadlineCardForStudents({
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.people, size: 50, color: primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Student Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Edit the number of students assigned to doctors.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: primaryColor),
                  tooltip: 'Edit Student Number',
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
