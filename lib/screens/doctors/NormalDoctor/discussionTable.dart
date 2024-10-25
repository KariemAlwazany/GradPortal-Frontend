import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;

class DiscussionTablePage extends StatefulWidget {
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
            child: isDiscussionTable
                ? buildScrollableTable("Discussion Table")
                : buildScrollableTable("My Table"),
          ),
        ],
      ),
    );
  }

  // Builds a scrollable table
  Widget buildScrollableTable(String tableTitle) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
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
            // Add as many columns as needed
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
}
