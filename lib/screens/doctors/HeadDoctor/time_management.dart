import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/tracking_page.dart';

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
        itemCount: deadlines.length,
        itemBuilder: (context, index) {
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
    DateTime? selectedDate = DateTime.tryParse(
        deadline['deadline']!.split(' ')[0]); // Parse date portion
    selectedDate ??= DateTime.now();

    TimeOfDay? selectedTime = TimeOfDay(
      hour: int.parse(deadline['deadline']!.split(' ')[1].split(':')[0]),
      minute: int.parse(deadline['deadline']!.split(' ')[1].split(':')[1]),
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
        final newDeadline = "${newDate.toIso8601String().split('T')[0]} "
            "${newTime.format(context)}";

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
