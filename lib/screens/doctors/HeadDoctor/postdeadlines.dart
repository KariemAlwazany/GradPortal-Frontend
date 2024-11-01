import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);

class PostDeadlinesPage extends StatefulWidget {
  @override
  _PostDeadlinesPageState createState() => _PostDeadlinesPageState();
}

class _PostDeadlinesPageState extends State<PostDeadlinesPage> {
  final TextEditingController titleController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> deadlines = [];

  // Select date and time for the deadline
  Future<void> selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  // Add a new deadline
  void addDeadline() {
    if (titleController.text.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      setState(() {
        deadlines.add({
          'title': titleController.text,
          'dateTime': DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          ),
        });
        titleController.clear();
        selectedDate = null;
        selectedTime = null;
      });
    }
  }

  // Delete a deadline
  void deleteDeadline(int index) {
    setState(() {
      deadlines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Post Deadlines',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Deadline input section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => selectDateTime(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            child: Text(
                              selectedDate == null || selectedTime == null
                                  ? 'Select Deadline Date & Time'
                                  : 'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime(
                                      selectedDate!.year,
                                      selectedDate!.month,
                                      selectedDate!.day,
                                      selectedTime!.hour,
                                      selectedTime!.minute,
                                    ))}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: addDeadline,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      ),
                      child: Text('Add Deadline'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Deadline list section
            Expanded(
              child: deadlines.isEmpty
                  ? Center(
                      child: Text(
                        'No deadlines posted yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: deadlines.length,
                      itemBuilder: (context, index) {
                        final deadline = deadlines[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              deadline['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(deadline['dateTime'])}',
                              style: TextStyle(color: primaryColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteDeadline(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
