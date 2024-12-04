import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

class StudentStatusPage extends StatefulWidget {
  @override
  _StudentStatusPageState createState() => _StudentStatusPageState();
}

class _StudentStatusPageState extends State<StudentStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    'Joining',
    'Partner',
    'Doctor',
    'Abstract',
    'Final'
  ];

  final List<Map<String, dynamic>> students = [
    {
      'name': 'John Doe',
      'id': '12345',
      'email': 'john.doe@example.com',
      'phone': '+1234567890',
      'department': 'Computer Science',
      'statuses': {
        'Joining': 'Completed',
        'Find Partner': 'Pending',
        'Find Doctor': 'Pending',
        'Abstract Submission': 'Not Started',
        'Final Submission': 'Not Started',
      }
    },
    {
      'name': 'Jane Smith',
      'id': '67890',
      'email': 'jane.smith@example.com',
      'phone': '+0987654321',
      'department': 'Electrical Engineering',
      'statuses': {
        'Joining': 'Completed',
        'Find Partner': 'Completed',
        'Find Doctor': 'Pending',
        'Abstract Submission': 'Pending',
        'Final Submission': 'Not Started',
      }
    },
  ];

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Status', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs
              .map(
                (tab) => Tab(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          indicatorColor: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Filter Dropdown and Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                    items: [
                      'All',
                      'Completed',
                      'Pending',
                      'Not Started',
                    ].map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Students',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentName =
                        student['name'].toString().toLowerCase();
                    final status = student['statuses'][tab];

                    // Apply Search Filter
                    if (searchQuery.isNotEmpty &&
                        !studentName.contains(searchQuery)) {
                      return SizedBox.shrink();
                    }

                    // Apply Status Filter
                    if (selectedFilter != 'All' && status != selectedFilter) {
                      return SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: ListTile(
                          title: Text(
                            student['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${student['id']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailsPage(
                                    student: student,
                                    onRemove: () {
                                      setState(() {
                                        students.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    }),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onRemove;

  StudentDetailsPage({required this.student, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student['name']} Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                _buildInfoRow('Name', student['name']),
                _buildInfoRow('ID', student['id']),
                _buildInfoRow('Email', student['email']),
                _buildInfoRow('Phone', student['phone']),
                _buildInfoRow('Department', student['department']),
                Divider(),
                Text(
                  'Status Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                ...student['statuses'].entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 16,
                        color: entry.value == 'Completed'
                            ? Colors.green
                            : entry.value == 'Pending'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _confirmRemove(context);
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Remove Student from system'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this student?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onRemove(); // Perform removal
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
