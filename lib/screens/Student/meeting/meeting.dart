import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);

class MeetingRequestPage extends StatefulWidget {
  final DateTime initialDateTime;

  MeetingRequestPage({required this.initialDateTime});

  @override
  _MeetingRequestPageState createState() => _MeetingRequestPageState();
}

class _MeetingRequestPageState extends State<MeetingRequestPage> {
  late DateTime selectedDateTime;
  String doctorName = "Loading..."; // Initial placeholder for the doctor's name

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
    _fetchDoctorName(); // Fetch doctor name from backend when page loads
  }

  // Placeholder function to simulate fetching the doctor's name from the backend
  Future<void> _fetchDoctorName() async {
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 2));

    // In a real app, this is where you'd make a network request.
    // For now, let's set a hardcoded name for demonstration.
    setState(() {
      doctorName =
          "Dr. John Doe"; // Replace with the fetched name from the backend
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
    String formattedTime = DateFormat('HH:mm').format(selectedDateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Meeting',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back arrow color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              'Meeting Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),

            // Doctor Section (displaying fetched doctor name)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: primaryColor, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        doctorName, // Display the doctor's name here
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Date Section with Icon
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _selectDate(context), // Open Date Picker on tap
                      child: Icon(Icons.calendar_today,
                          color: primaryColor, size: 30),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Time Section with Icon
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _selectTime(context), // Open Time Picker on tap
                      child: Icon(Icons.access_time,
                          color: primaryColor, size: 30),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),

            // Submit Button with adjusted position
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0), // Adjust padding to raise the button
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _submitMeetingRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to open the Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  // Method to open the Time Picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submitMeetingRequest(BuildContext context) {
    // Simulate submitting the meeting request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Meeting request submitted! Await doctor's response."),
        backgroundColor: primaryColor,
      ),
    );

    // Navigate back to the main student page
    Navigator.pop(context);
  }
}
