import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;

class DiscussionTablePage extends StatefulWidget {
  @override
  _DiscussionTablePageState createState() => _DiscussionTablePageState();
}

class _DiscussionTablePageState extends State<DiscussionTablePage> {
  bool isDiscussionTable = true; // Tracks which tab is active
  List<Map<String, dynamic>> discussionTableData = []; // Discussion Table data
  List<Map<String, dynamic>> myTableData = []; // My Table data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchTableData(); // Fetch data for the initial tab
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchTableData({bool isDoctorTable = false}) async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    final endpoint = isDoctorTable
        ? '${dotenv.env['API_BASE_URL']}/GP/v1/table/doctor'
        : '${dotenv.env['API_BASE_URL']}/GP/v1/table';

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data']['table'];
      setState(() {
        final tableData =
            List<Map<String, dynamic>>.from(data).asMap().entries.map((entry) {
          final index = entry.key + 1;
          final row = entry.value;
          final time = DateTime.parse(row['Time']);
          return {
            'id': index, // Local ID starting from 1
            'time':
                '${DateFormat.jm().format(time)}-${DateFormat.jm().format(time.add(Duration(minutes: 20)))}',
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

        if (isDoctorTable) {
          myTableData = tableData;
        } else {
          discussionTableData = tableData;
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch table data')),
      );
    }
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.download, color: primaryColor),
              title: Text('Download Discussion Table'),
              onTap: () async {
                await downloadTableAsPdf(
                    discussionTableData, 'Discussion Table');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: primaryColor),
              title: Text('Download My Table'),
              onTap: () async {
                await downloadTableAsPdf(myTableData, 'My Table');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadTableAsPdf(
      List<Map<String, dynamic>> tableData, String tableTitle) async {
    final pdf = pw.Document();

    // Group the data by 'day'
    final groupedData = tableData.fold<Map<String, List<Map<String, dynamic>>>>(
      {},
      (map, row) {
        final day = row['day'] ?? 'Unknown Day';
        map.putIfAbsent(day, () => []).add(row);
        return map;
      },
    );

    // Add content to the PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => groupedData.entries.map((entry) {
          final day = entry.key;
          final rows = entry.value;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$tableTitle - $day',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: [
                  'ID',
                  'Time',
                  'Room',
                  'Project Title',
                  'Type',
                  'Student 1',
                  'Student 2',
                  'Supervisor',
                  'Examiner 1',
                  'Examiner 2'
                ],
                data: rows.map((row) {
                  return [
                    row['id'].toString(),
                    row['time'] ?? '',
                    row['room'] ?? '',
                    row['projectTitle'] ?? '',
                    row['type'] ?? '',
                    row['student1'] ?? '',
                    row['student2'] ?? '',
                    row['supervisor'] ?? '',
                    row['examiner1'] ?? '',
                    row['examiner2'] ?? '',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );

    // Save and trigger download
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDownloadOptions(context),
        backgroundColor: primaryColor,
        child: Icon(Icons.download, color: Colors.white),
      ),
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
          // Top row with "Discussion Table" and "My Table" connected buttons
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
                        fetchTableData(isDoctorTable: false);
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
                        fetchTableData(isDoctorTable: true);
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
                          'My Table',
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
                : buildGroupedTable(),
          ),
        ],
      ),
    );
  }

  // Builds a scrollable table grouped by day
  Widget buildGroupedTable() {
    // Group the data by 'day'
    final groupedData = <String, List<Map<String, dynamic>>>{};
    for (var row in (isDiscussionTable ? discussionTableData : myTableData)) {
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
                          DataCell(Text(row['id'].toString())), // Local ID
                          DataCell(Text(row['time'] ?? '')), // Time range
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
}
