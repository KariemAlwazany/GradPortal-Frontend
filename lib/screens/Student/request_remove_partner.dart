import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Color(0xFFF5F5F5);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RemovePartnerRequestPage(),
  ));
}

class RemovePartnerRequestPage extends StatelessWidget {
  final String status = "Accepted"; // Example status
  final String messageFromHeadDoctor =
      "Your partner removal request has been approved."; // Example message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request to Remove Partner'),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit a Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please provide a reason for requesting the removal of your partner. Your request will be reviewed.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason for Removal',
                hintText: 'Explain your reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: status == "Accepted" ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Message from Head Doctor:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              messageFromHeadDoctor,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request Submitted Successfully')),
                  );
                  Navigator.pop(context);
                },
                child: Text('Submit Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
