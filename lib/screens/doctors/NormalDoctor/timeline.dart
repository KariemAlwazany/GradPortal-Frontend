import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/doctor.dart';

import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;
const Color selectedDayColor = Color(0xFFFF3B30);
const Color textColor = Colors.black87;

class ScrollableCalendarPage extends StatefulWidget {
  @override
  _ScrollableCalendarPageState createState() => _ScrollableCalendarPageState();
}

class _ScrollableCalendarPageState extends State<ScrollableCalendarPage> {
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<String>> tasks = {
    '2025-01-05': ['Project Proposal Submission'],
    '2024-01-20': ['Midterm Review'],
    '2024-02-15': ['Project Presentation'],
    '2024-03-01': ['Final Report Submission'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Timeline',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DoctorPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Text(
                  day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                DateTime month =
                    DateTime(DateTime.now().year, DateTime.now().month + index);
                return _buildMonthView(month);
              },
              itemCount: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(DateTime month) {
    List<String> daysInMonth = _daysInMonth(month);
    int startingWeekday = DateTime(month.year, month.month, 1).weekday;
    int emptyDays = (startingWeekday % 7);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            DateFormat.yMMMM().format(month),
            style: TextStyle(
              color: primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: daysInMonth.length + emptyDays,
            itemBuilder: (context, index) {
              if (index < emptyDays) {
                return Container();
              } else {
                final dayString = daysInMonth[index - emptyDays];
                final dayDate = DateTime.parse(dayString);
                final isTaskDay = tasks.containsKey(dayString);
                final isSelectedDay =
                    DateFormat('yyyy-MM-dd').format(_selectedDate) == dayString;
                final isToday =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                        dayString;

                return GestureDetector(
                  onTap: () => _onDayTapped(dayDate, context),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelectedDay
                          ? selectedDayColor.withOpacity(0.7)
                          : backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.d().format(dayDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelectedDay || isToday
                                ? Colors.white
                                : textColor,
                          ),
                        ),
                        if (isTaskDay) ...[
                          SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: selectedDayColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  List<String> _daysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      return DateFormat('yyyy-MM-dd').format(date);
    });
  }

  void _onDayTapped(DateTime date, BuildContext context) {
    setState(() {
      _selectedDate = date;
    });

    final String dateString = DateFormat('yyyy-MM-dd').format(date);
    if (tasks.containsKey(dateString)) {
      _showTasksDialog(context, dateString, tasks[dateString]!);
    }
  }

  void _showTasksDialog(BuildContext context, String date, List<String> tasks) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tasks for $date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tasks
                .map((task) => ListTile(
                      leading: Icon(Icons.task, color: primaryColor),
                      title: Text(task),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
