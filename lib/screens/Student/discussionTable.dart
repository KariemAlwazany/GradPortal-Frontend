import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;

class DiscussionTablePage extends StatefulWidget {
  const DiscussionTablePage({super.key});

  @override
  _DiscussionTablePageState createState() => _DiscussionTablePageState();
}

class _DiscussionTablePageState extends State<DiscussionTablePage> {
  bool isDiscussionTable = true; // Tracks which tab is active

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
            child: isDiscussionTable
                ? buildScrollableTable("Discussion Table")
                : buildEnhancedSingleDiscussionCard(),
          ),
        ],
      ),
    );
  }

  // Builds a scrollable table for "Discussion Table"
  Widget buildScrollableTable(String tableTitle) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label:
                    Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Topic',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Comments',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(20, (index) {
            return DataRow(
              cells: [
                DataCell(Text('ID-$index')),
                DataCell(Text('User $index')),
                DataCell(Text(tableTitle == "Discussion Table"
                    ? 'Topic $index'
                    : 'My Topic $index')),
                DataCell(Text('2024-01-${index + 1}')),
                DataCell(Text(index % 2 == 0 ? 'Open' : 'Closed')),
                DataCell(Text('Comments for entry $index')),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Builds an enhanced single card for "My Discussion"
  Widget buildEnhancedSingleDiscussionCard() {
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
                children: const [
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
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.access_time, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Time: 10:00 AM', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.room, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Room: A-101', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.calendar_today, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Date: 2024-01-10', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.today, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Day: Monday', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.person, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Supervisor: Dr. Supervisor',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.person, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Examiner 1: Examiner1', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: const [
                  Icon(Icons.person, color: primaryColor),
                  SizedBox(width: 8.0),
                  Text('Examiner 2: Examiner2', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
