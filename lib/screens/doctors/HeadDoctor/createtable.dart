import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/rooms.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;

const Color primaryColor = Color(0xFF3B4280);

class CreateDiscussionTablePage extends StatefulWidget {
  @override
  _CreateDiscussionTablePageState createState() =>
      _CreateDiscussionTablePageState();
}

class _CreateDiscussionTablePageState extends State<CreateDiscussionTablePage> {
  final TextEditingController rowsController = TextEditingController();
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool isTableCreated = false;

  List<Map<String, dynamic>> discussionTable = [];
  List<String> days = [];

  final List<String> tableHeaders = [
    'GP#',
    'Time',
    'Room',
    'Project\'s Title',
    'Type',
    'Student 1',
    'Student 2',
    'Supervisor',
    'Examiner 1',
    'Examiner 2'
  ];

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchTableFromApi() async {
    final token = await getToken();
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/table';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data']['table'];
      discussionTable = data.map<Map<String, dynamic>>((item) {
        final time = DateTime.parse(item['Time']);
        return {
          'id': item['id'], // Include ID for patching
          'gp': null, // Placeholder for GP# counter
          'time': TimeOfDay(hour: time.hour, minute: time.minute),
          'day': DateFormat('EEEE').format(time),
          'room': item['Room'],
          'projectTitle': item['GP_Title'],
          'type': item['GP_Type'],
          'student1': item['Student_1'],
          'student2': item['Student_2'],
          'supervisor': item['Supervisor_1'],
          'examiner1': item['Examiner_1'],
          'examiner2': item['Examiner_2'],
        };
      }).toList();

      // Group rows by time and assign GP# counters
      discussionTable.asMap().forEach((index, row) {
        row['gp'] = index + 1;
      });

      setState(() {
        isTableCreated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch table data')),
      );
    }
  }

  Future<void> patchField({
    required int id,
    required String fieldKey,
    required String value,
    TimeOfDay? time,
  }) async {
    final token = await getToken();
    final url = '${dotenv.env['API_BASE_URL']}/GP/v1/table/$id';

    // Map input keys to the expected field names in the API
    Map<String, String> fieldKeyMap = {
      'time': 'Time',
      'room': 'Room',
      'examiner1': 'Examiner_1',
      'examiner_1': 'Examiner_1',
      'examiner2': 'Examiner_2',
      'examiner_2': 'Examiner_2',
    };

    // Normalize and map the fieldKey
    fieldKey = fieldKey.trim().toLowerCase();
    String? mappedFieldKey = fieldKeyMap[fieldKey];

    // Initialize the request body
    Map<String, dynamic> body = {};

    // Debugging Input
    print('Debugging Inputs:');
    print('Original fieldKey: $fieldKey');
    print('Mapped fieldKey: $mappedFieldKey');
    print('value: $value');
    print('time: $time');

    // Add fields to the body dynamically
    if (mappedFieldKey == 'Time' && time != null) {
      final now = DateTime.now();
      final DateTime fullDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      body['Time'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
    } else if (mappedFieldKey != null && value.isNotEmpty) {
      body[mappedFieldKey] = value;
    }

    // Debugging the constructed body
    print('Constructed body: $body');

    if (body.isEmpty) {
      print('No valid field to update.');
      return;
    }

    // Make the PATCH request
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Handle response
    if (response.statusCode != 200) {
      print('Failed response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $fieldKey')),
      );
    } else {
      print('Update successful for $mappedFieldKey.');
    }
  }

  Future<void> editField({
    required int index,
    required String fieldKey,
    required String currentValue,
    required String title,
  }) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text;
              setState(() {
                discussionTable[index][fieldKey] = newValue;
              });
              await patchField(
                id: discussionTable[index]['id'],
                fieldKey: fieldKey,
                value: newValue,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> editTime(int index) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: discussionTable[index]['time'],
    );

    if (selectedTime != null) {
      setState(() {
        discussionTable[index]['time'] = selectedTime;
      });
      await patchField(
        id: discussionTable[index]['id'],
        fieldKey: 'Time',
        value: '',
        time: selectedTime,
      );
    }
  }

  Future<void> generateRandomTable() async {
    if (startDateTime != null && endDateTime != null) {
      final token = await getToken();
      final url = '${dotenv.env['API_BASE_URL']}/GP/v1/table';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'StartDate': startDateTime!.toIso8601String(),
          'EndDate': endDateTime!.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        await fetchTableFromApi();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate table')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select start and end date and time')),
      );
    }
  }

  Future<DateTime?> selectDateTime(BuildContext context, String label) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }
    return null;
  }

  Future<void> selectStartDateTime() async {
    DateTime? selectedDateTime = await selectDateTime(context, 'Start');
    if (selectedDateTime != null) {
      setState(() {
        startDateTime = selectedDateTime;
      });
    }
  }

  Future<void> selectEndDateTime() async {
    DateTime? selectedDateTime = await selectDateTime(context, 'End');
    if (selectedDateTime != null) {
      setState(() {
        endDateTime = selectedDateTime;
      });
    }
  }

  String formatTimeWithRange(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final DateTime endTime = startTime.add(Duration(minutes: 20));

    final String formattedStartTime =
        DateFormat.jm().format(startTime); // e.g., 8:00 AM
    final String formattedEndTime =
        DateFormat.jm().format(endTime); // e.g., 8:20 AM

    return '$formattedStartTime - $formattedEndTime';
  }

  Future<void> _postToApi(String endpoint) async {
    final token = await getToken();
    final url = '${dotenv.env['API_BASE_URL']}$endpoint';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully posted to $endpoint')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to post to $endpoint: ${response.body}')),
      );
      print('Error response: ${response.body}');
    }
  }

  void _showBottomSheet(BuildContext context) {
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
              leading: Icon(Icons.people, color: primaryColor),
              title: Text('Post for Students'),
              onTap: () async {
                await _postToApi('/GP/v1/table/students');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryColor),
              title: Text('Post for Doctors'),
              onTap: () async {
                await _postToApi('/GP/v1/table/doctors');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: primaryColor),
              title: Text('Download Table'),
              onTap: () async {
                await downloadTableAsPdf(discussionTable, tableHeaders);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Create Discussion Table',
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.room),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoomsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isTableCreated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4.0,
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text('Start Date and Time'),
                      subtitle: Text(startDateTime != null
                          ? DateFormat('yyyy-MM-dd HH:mm')
                              .format(startDateTime!)
                          : 'Not Selected'),
                      trailing: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: selectStartDateTime,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text('End Date and Time'),
                      subtitle: Text(endDateTime != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(endDateTime!)
                          : 'Not Selected'),
                      trailing: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: selectEndDateTime,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4.0,
                    child: ElevatedButton.icon(
                      onPressed: generateRandomTable,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      icon: Icon(Icons.shuffle),
                      label: Text('Generate Randomly'),
                    ),
                  ),
                ],
              ),
            ),
          if (isTableCreated)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: discussionTable
                        .fold<Map<String, List<Map<String, dynamic>>>>(
                            {},
                            (map, row) =>
                                map..putIfAbsent(row['day'], () => []).add(row))
                        .entries
                        .map((entry) {
                          final day = entry.key;
                          final rows = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataTable(
                                columnSpacing: 16.0,
                                columns: tableHeaders
                                    .map((header) => DataColumn(
                                          label: Text(
                                            header,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                    .toList(),
                                rows: rows.map((row) {
                                  final int index =
                                      discussionTable.indexOf(row);
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['gp'].toString())),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => editTime(index),
                                          child: Text(
                                            formatTimeWithRange(row['time']!),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => editField(
                                            index: index,
                                            fieldKey: 'room',
                                            currentValue: row['room'] ?? '',
                                            title: 'Room',
                                          ),
                                          child: Text(row['room'] ?? 'N/A'),
                                        ),
                                      ),
                                      DataCell(
                                          Text(row['projectTitle'] ?? 'N/A')),
                                      DataCell(Text(row['type'] ?? 'N/A')),
                                      DataCell(Text(row['student1'] ?? 'N/A')),
                                      DataCell(Text(row['student2'] ?? 'N/A')),
                                      DataCell(
                                          Text(row['supervisor'] ?? 'N/A')),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => editField(
                                            index: index,
                                            fieldKey: 'examiner1',
                                            currentValue:
                                                row['examiner1'] ?? '',
                                            title: 'Examiner 1',
                                          ),
                                          child:
                                              Text(row['examiner1'] ?? 'N/A'),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => editField(
                                            index: index,
                                            fieldKey: 'examiner2',
                                            currentValue:
                                                row['examiner2'] ?? '',
                                            title: 'Examiner 2',
                                          ),
                                          child:
                                              Text(row['examiner2'] ?? 'N/A'),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: primaryColor,
        child: Icon(Icons.post_add, color: Colors.white),
      ),
    );
  }
}

Future<void> downloadTableAsPdf(List<Map<String, dynamic>> discussionTable,
    List<String> tableHeaders) async {
  final pdf = pw.Document();

  // Create a table for each day's discussion entries
  final groupedData =
      discussionTable.fold<Map<String, List<Map<String, dynamic>>>>(
    {},
    (map, row) {
      final day = row['day'] ?? 'Unknown Day';
      if (!map.containsKey(day)) map[day] = [];
      map[day]!.add(row);
      return map;
    },
  );

  // Add content to the PDF
  groupedData.forEach((day, rows) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(day,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: rows.map((row) {
                  return [
                    row['gp'].toString(),
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
        },
      ),
    );
  });

  // Save and trigger download
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
