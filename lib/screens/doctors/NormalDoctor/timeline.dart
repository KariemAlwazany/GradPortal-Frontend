import 'package:flutter/material.dart';
import 'package:flutter_project/screens/doctors/HeadDoctor/postdeadlines.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/doctor.dart';
import 'package:flutter_project/screens/doctors/NormalDoctor/meeting/createMeeting.dart';

import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);
const Color backgroundColor = Colors.white;
const Color selectedDayColor = Color(0xFFFF3B30);
const Color textColor = Colors.black87;

class ScrollableCalendarPage extends StatefulWidget {
  const ScrollableCalendarPage({super.key});

  @override
  _ScrollableCalendarPageState createState() => _ScrollableCalendarPageState();
}

class _ScrollableCalendarPageState extends State<ScrollableCalendarPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> tasks = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final token = await getToken();
    if (token == null) return;

    final deadlinesUrl =
        '${dotenv.env['API_BASE_URL']}/GP/v1/deadlines/doctor/deadlines';
    final meetingsUrl =
        '${dotenv.env['API_BASE_URL']}/GP/v1/meetings/myMeetings';

    try {
      final deadlinesResponse = await http.get(
        Uri.parse(deadlinesUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      final meetingsResponse = await http.get(
        Uri.parse(meetingsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (deadlinesResponse.statusCode == 200 &&
          meetingsResponse.statusCode == 200) {
        final deadlinesData =
            jsonDecode(deadlinesResponse.body)['data']['deadLines'] as List;
        final meetingsData =
            jsonDecode(meetingsResponse.body)['data']['meetings'] as List;

        Map<String, List<Map<String, dynamic>>> loadedTasks = {};

        for (var deadline in deadlinesData) {
          final dateTime = DateTime.parse(deadline['Date']);
          final date = DateFormat('yyyy-MM-dd').format(dateTime);
          loadedTasks[date] = (loadedTasks[date] ?? [])
            ..add({
              'type': 'deadline',
              'title': deadline['Title'] ?? 'No Title',
              'time': DateFormat.jm().format(dateTime),
            });
        }

        for (var meeting in meetingsData) {
          final dateTime = DateTime.parse(meeting['Date']);
          final date = DateFormat('yyyy-MM-dd').format(dateTime);
          loadedTasks[date] = (loadedTasks[date] ?? [])
            ..add({
              'type': 'meeting',
              'title': meeting['GP_Title'],
              'time': DateFormat.jm().format(dateTime),
            });
        }

        setState(() {
          tasks = loadedTasks;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Calendar',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: BackButton(
          color: Colors.white,
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

  void _showTasksDialog(
      BuildContext context, String date, List<Map<String, dynamic>> tasks) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Events for $date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tasks.map((task) {
              IconData icon = task['type'] == 'deadline'
                  ? Icons.file_present
                  : Icons.video_call;

              return ListTile(
                leading: Icon(icon, color: primaryColor),
                title: Text("${task['title']} (${task['time']})"),
                subtitle:
                    Text(task['type'] == 'deadline' ? 'Deadline' : 'Meeting'),
                onTap: () {
                  Navigator.of(context).pop();
                  if (task['type'] == 'deadline') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostDeadlinesPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewMeetingsPage()),
                    );
                  }
                },
              );
            }).toList(),
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
