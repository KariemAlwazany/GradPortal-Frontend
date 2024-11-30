import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;

class DiscussionTablePage extends StatefulWidget {
  @override
  _DiscussionTablePageState createState() => _DiscussionTablePageState();
}

class _DiscussionTablePageState extends State<DiscussionTablePage> {
  bool isDiscussionTable = true; // Tracks which tab is active
  List<Map<String, dynamic>> tableData = []; // Holds fetched table data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchTableData(); // Fetch initial data
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchTableData({bool isStudentTable = false}) async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    final endpoint = isStudentTable
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/table/student'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/table';

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (isStudentTable) {
        final table = data['table'];
        setState(() {
          tableData = [
            {
              'id': 1, // Start from 1 for student table
              'time': formatTimeWithRange(DateTime.parse(table['Time'])),
              'day': DateFormat.EEEE().format(DateTime.parse(table['Time'])),
              'room': table['Room'],
              'projectTitle': table['GP_Title'],
              'type': table['GP_Type'],
              'student1': table['Student_1'],
              'student2': table['Student_2'],
              'supervisor': table['Supervisor_1'],
              'examiner1': table['Examiner_1'],
              'examiner2': table['Examiner_2'],
            }
          ];
          isLoading = false;
        });
      } else {
        final tableList = List<Map<String, dynamic>>.from(data['table']);
        setState(() {
          tableData = tableList.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final time = DateTime.parse(row['Time']);
            return {
              'id': index + 1, // Generate IDs starting from 1
              'time': formatTimeWithRange(
                  time), // Format time with 20-min intervals
              'day': DateFormat.EEEE().format(time),
              'room': row['Room'],
              'projectTitle': row['GP_Title'],
              'type': row['GP_Type'],
              'student1': row['Student_1'],
              'student2': row['Student_2'],
              'supervisor': row['Supervisor_1'],
              'examiner1': row['Examiner_1'],
              'examiner2': row['Examiner_2'],
            };
          }).toList();
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch table data')),
      );
    }
  }

  String formatTimeWithRange(DateTime startTime) {
    final DateTime endTime = startTime.add(Duration(minutes: 20));
    final String formattedStartTime =
        DateFormat('h:mm').format(startTime); // e.g., 8:00
    final String formattedEndTime =
        DateFormat('h:mm').format(endTime); // e.g., 8:20
    final String period = DateFormat('a').format(endTime); // AM/PM

    return '$formattedStartTime-$formattedEndTime$period';
  }

  Widget buildEnhancedSingleDiscussionCard() {
    if (tableData.isEmpty) {
      return Center(child: Text('No discussions found.'));
    }
    final discussion = tableData.first; // Assuming single discussion data
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Discussion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Icon(Icons.chat, color: primaryColor),
                ],
              ),
              Divider(color: Colors.grey[300]),
              buildDetailRow(Icons.access_time, 'Time', discussion['time']),
              buildDetailRow(Icons.today, 'Day', discussion['day']),
              buildDetailRow(Icons.room, 'Room', discussion['room']),
              buildDetailRow(
                  Icons.title, 'Project Title', discussion['projectTitle']),
              buildDetailRow(Icons.category, 'Type', discussion['type']),
              buildDetailRow(Icons.person, 'Student 1', discussion['student1']),
              buildDetailRow(Icons.person, 'Student 2', discussion['student2']),
              buildDetailRow(Icons.supervisor_account, 'Supervisor',
                  discussion['supervisor']),
              buildDetailRow(
                  Icons.person, 'Examiner 1', discussion['examiner1']),
              buildDetailRow(
                  Icons.person, 'Examiner 2', discussion['examiner2']),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
        title: Text(
          'Discussion',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Top row with "Discussion Table" and "My Discussion" connected buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 300, // Wider control for buttons
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDiscussionTable = true;
                        });
                        fetchTableData(isStudentTable: false);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDiscussionTable
                              ? primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(20)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Discussion Table',
                          style: TextStyle(
                            color:
                                isDiscussionTable ? Colors.white : primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDiscussionTable = false;
                        });
                        fetchTableData(isStudentTable: true);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isDiscussionTable
                              ? primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(20)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'My Discussion',
                          style: TextStyle(
                            color: !isDiscussionTable
                                ? Colors.white
                                : primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content based on the selected tab
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : isDiscussionTable
                    ? buildScrollableTable()
                    : buildEnhancedSingleDiscussionCard(),
          ),
        ],
      ),
    );
  }

  Widget buildScrollableTable() {
    // Group the data by 'day'
    final groupedData = <String, List<Map<String, dynamic>>>{};
    for (var row in tableData) {
      final day = row['day'] ?? 'Unknown Day';
      if (!groupedData.containsKey(day)) {
        groupedData[day] = [];
      }
      groupedData[day]?.add(row);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedData.entries.map((entry) {
          final day = entry.key;
          final rows = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                // Table for the Day
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16.0,
                    columns: [
                      DataColumn(
                          label: Text('GP#',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Time',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Room',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Project\'s Title',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Type',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Student 1',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Student 2',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Supervisor',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Examiner 1',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Examiner 2',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: rows.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(
                              Text(row['id'].toString())), // Use generated ID
                          DataCell(Text(
                              row['time'] ?? '')), // Display formatted time
                          DataCell(Text(row['room'] ?? '')),
                          DataCell(Text(row['projectTitle'] ?? '')),
                          DataCell(Text(row['type'] ?? '')),
                          DataCell(Text(row['student1'] ?? '')),
                          DataCell(Text(row['student2'] ?? '')),
                          DataCell(Text(row['supervisor'] ?? '')),
                          DataCell(Text(row['examiner1'] ?? '')),
                          DataCell(Text(row['examiner2'] ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          SizedBox(width: 8.0),
          Text('$title: $value', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
