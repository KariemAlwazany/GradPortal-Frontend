import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  List<String> days = [];
  List<Map<String, dynamic>> discussionTable = [];

  final List<String> tableHeaders = [
    'Time',
    'GP#',
    'Room',
    'Project\'s Title',
    'Type',
    'Supervisor',
    'Examiner 1',
    'Examiner 2',
    'Supervisor 2'
  ];

  // Combines date and time into a single DateTime value
  Future<DateTime?> selectDateTime(BuildContext context, String label) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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

  void createTable() {
    int rows = int.tryParse(rowsController.text) ?? 0;

    if (startDateTime != null && endDateTime != null) {
      days = [];
      DateTime currentDate = startDateTime!;
      while (currentDate.isBefore(endDateTime!.add(Duration(days: 1)))) {
        days.add(DateFormat('EEEE').format(currentDate));
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    discussionTable = [];
    for (var day in days) {
      for (int i = 1; i <= rows; i++) {
        discussionTable.add({
          'day': day,
          'row': i,
          'time': null,
          'gp': '',
          'room': '',
          'projectTitle': '',
          'type': null,
          'supervisor': '',
          'examiner1': '',
          'examiner2': '',
          'supervisor2': '',
        });
      }
    }

    setState(() {
      isTableCreated = true;
    });
  }

  void generateRandomTable() {
    final random = Random();
    int rows = int.tryParse(rowsController.text) ?? 0;

    if (startDateTime != null && endDateTime != null) {
      days = [];
      DateTime currentDate = startDateTime!;
      while (currentDate.isBefore(endDateTime!.add(Duration(days: 1)))) {
        days.add(DateFormat('EEEE').format(currentDate));
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    discussionTable = [];
    for (var day in days) {
      for (int i = 1; i <= rows; i++) {
        discussionTable.add({
          'day': day,
          'row': i,
          'time':
              TimeOfDay(hour: random.nextInt(12), minute: random.nextInt(60)),
          'gp': 'GP ${random.nextInt(100)}',
          'room': 'Room ${random.nextInt(20)}',
          'projectTitle': 'Project ${random.nextInt(50)}',
          'type': random.nextBool() ? 'Software' : 'Hardware',
          'supervisor': 'Dr. ${[
            'Smith',
            'Johnson',
            'Williams',
            'Jones'
          ][random.nextInt(4)]}',
          'examiner1': 'Dr. ${[
            'Brown',
            'Davis',
            'Miller',
            'Wilson'
          ][random.nextInt(4)]}',
          'examiner2': 'Dr. ${[
            'Moore',
            'Taylor',
            'Anderson',
            'Thomas'
          ][random.nextInt(4)]}',
          'supervisor2': 'Dr. ${[
            'Jackson',
            'White',
            'Harris',
            'Martin'
          ][random.nextInt(4)]}',
        });
      }
    }

    setState(() {
      isTableCreated = true;
    });
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

  void selectTime(int index) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        discussionTable[index]['time'] = selectedTime;
      });
    }
  }

  void postForDoctors() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table posted successfully for doctors!')),
    );
  }

  void postForStudents() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table posted successfully for students!')),
    );
  }

  // Function to generate and download the PDF
  Future<void> downloadTableAsPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Discussion Table', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: discussionTable.map((row) {
                  return [
                    row['time'] != null
                        ? (row['time'] as TimeOfDay)
                            .format(context as BuildContext)
                        : '',
                    row['gp'],
                    row['room'],
                    row['projectTitle'],
                    row['type'],
                    row['supervisor'],
                    row['examiner1'],
                    row['examiner2'],
                    row['supervisor2'],
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Use the Printing package to save or share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
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
      ),
      body: Column(
        children: [
          if (!isTableCreated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: rowsController,
                    decoration: InputDecoration(
                      labelText: 'Number of Rows',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectStartDateTime,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          child: Text(startDateTime == null
                              ? 'Select Start Date & Time'
                              : 'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(startDateTime!)}'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectEndDateTime,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          child: Text(endDateTime == null
                              ? 'Select End Date & Time'
                              : 'End: ${DateFormat('yyyy-MM-dd HH:mm').format(endDateTime!)}'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: createTable,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          child: Text('Create Empty Table'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: generateRandomTable,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          child: Text('Generate Randomly'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (isTableCreated)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: days.map((day) {
                    List<Map<String, dynamic>> rowsForDay = discussionTable
                        .where((row) => row['day'] == day)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(day,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: tableHeaders
                                .map((header) => DataColumn(
                                      label: Text(header,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ))
                                .toList(),
                            rows: rowsForDay.asMap().entries.map((entry) {
                              int index = entry.key;
                              var row = entry.value;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    GestureDetector(
                                      onTap: () => selectTime(index),
                                      child: Text(
                                        row['time'] == null
                                            ? 'Select Time'
                                            : row['time']!.format(context),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  DataCell(TextFormField(
                                    initialValue: row['gp'],
                                    onChanged: (value) => row['gp'] = value,
                                  )),
                                  DataCell(TextFormField(
                                    initialValue: row['room'],
                                    onChanged: (value) => row['room'] = value,
                                  )),
                                  DataCell(TextFormField(
                                    initialValue: row['projectTitle'],
                                    onChanged: (value) =>
                                        row['projectTitle'] = value,
                                  )),
                                  DataCell(
                                    DropdownButton<String>(
                                      value: row['type'],
                                      hint: Text('Select Type'),
                                      items: ['Software', 'Hardware']
                                          .map((type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          row['type'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(TextFormField(
                                    initialValue: row['supervisor'],
                                    onChanged: (value) =>
                                        row['supervisor'] = value,
                                  )),
                                  DataCell(TextFormField(
                                    initialValue: row['examiner1'],
                                    onChanged: (value) =>
                                        row['examiner1'] = value,
                                  )),
                                  DataCell(TextFormField(
                                    initialValue: row['examiner2'],
                                    onChanged: (value) =>
                                        row['examiner2'] = value,
                                  )),
                                  DataCell(TextFormField(
                                    initialValue: row['supervisor2'],
                                    onChanged: (value) =>
                                        row['supervisor2'] = value,
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          if (isTableCreated)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: postForDoctors,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      child: Text('Post for Doctors'),
                    ),
                    ElevatedButton(
                      onPressed: postForStudents,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      child: Text('Post for Students'),
                    ),
                    ElevatedButton(
                      onPressed: downloadTableAsPdf,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      child: Text('Download as PDF'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
