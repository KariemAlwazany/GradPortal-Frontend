import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

const Color primaryColor = Color(0xFF3B4280);

class ViewMeetingsPage extends StatefulWidget {
  @override
  _ViewMeetingsPageState createState() => _ViewMeetingsPageState();
}

class _ViewMeetingsPageState extends State<ViewMeetingsPage> {
  List<dynamic> meetings = [];
  List<dynamic> filteredMeetings = [];
  bool isLoading = true;
  String searchQuery = '';
  String sortOption = 'None';
  bool isSearchVisible = false;
  String userId = 'Fetching...';

  @override
  void initState() {
    super.initState();
    fetchMeetings();
    _loadUsername();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchMeetings() async {
    final token = await getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings/myMeetings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          meetings = data['data']['meetings'];
          filteredMeetings = List.from(meetings);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUsername() async {
    final token = await getToken();
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/users/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          setState(() {
            userId = userData['data']['data']['Username'] ?? 'Unknown User';
          });
        } else {
          setState(() {
            userId = 'Error fetching Username';
          });
        }
      } catch (e) {
        setState(() {
          userId = 'Error: $e';
        });
      }
    } else {
      setState(() {
        userId = 'Token not found';
      });
    }
  }

  Future<void> createNewMeeting(String meetingId, int id) async {
    final token = await getToken();
    if (token == null) {
      print("Token not found");
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings/addID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"id": id, "MeetingID": meetingId}),
      );

      if (response.statusCode == 200) {
        print("Meeting ID successfully sent to the server");
      } else {
        print("Failed to send Meeting ID: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending Meeting ID: $e");
    }
  }

  Future<void> cancelMeeting(int id) async {
    final token = await getToken();
    if (token == null) {
      print("Token not found");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings/deleteMeeting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"id": id}),
      );

      if (response.statusCode == 200) {
        print("Meeting successfully canceled");
        fetchMeetings(); // Refresh the list
      } else {
        print("Failed to cancel meeting: ${response.statusCode}");
      }
    } catch (e) {
      print("Error canceling meeting: $e");
    }
  }

  Future<void> editMeetingDate(int id) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final updatedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        if (updatedDateTime.isBefore(DateTime.now())) {
          // Show an error message if the selected date and time are in the past
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Selected date and time must be in the future.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final token = await getToken();
        if (token == null) {
          print("Token not found");
          return;
        }

        try {
          final response = await http.patch(
            Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings/editDate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              "id": id,
              "Date": updatedDateTime.toIso8601String(),
            }),
          );

          if (response.statusCode == 200) {
            print("Meeting date successfully updated");
            fetchMeetings(); // Refresh the list
          } else {
            print("Failed to update meeting date: ${response.statusCode}");
          }
        } catch (e) {
          print("Error updating meeting date: $e");
        }
      }
    }
  }

  void filterAndSortMeetings(String query, String sortBy) {
    List<dynamic> filtered = meetings.where((meeting) {
      final gpTitle = meeting['GP_Title'].toLowerCase();
      final searchLower = query.toLowerCase();
      return gpTitle.contains(searchLower);
    }).toList();

    if (sortBy == 'Date') {
      filtered.sort((a, b) {
        DateTime dateA = DateTime.parse(a['Date']);
        DateTime dateB = DateTime.parse(b['Date']);
        return dateA.compareTo(dateB);
      });
    } else if (sortBy == 'Software' || sortBy == 'Hardware') {
      filtered = filtered.where((meeting) {
        final gpType = meeting['GP_Type'].toLowerCase();
        return gpType == sortBy.toLowerCase();
      }).toList();
    }

    setState(() {
      searchQuery = query;
      sortOption = sortBy;
      filteredMeetings = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduled Meetings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    if (isSearchVisible)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    filterAndSortMeetings(value, sortOption),
                                decoration: InputDecoration(
                                  labelText: 'Search by GP Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: sortOption,
                                underline: SizedBox(),
                                items: ['None', 'Date', 'Software', 'Hardware']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text('Sort by $value'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    filterAndSortMeetings(searchQuery, value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: filteredMeetings.isEmpty
                          ? Center(child: Text('No meetings found'))
                          : ListView.builder(
                              itemCount: filteredMeetings.length,
                              itemBuilder: (context, index) {
                                final meeting = filteredMeetings[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'GP Title: ${meeting['GP_Title']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => editMeetingDate(
                                                  meeting['id']),
                                              child: Icon(
                                                Icons.calendar_today,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Divider(color: Colors.grey[300]),
                                        SizedBox(height: 10),
                                        _buildDetailRow(
                                          icon: Icons.person,
                                          label: 'Student 1',
                                          value: meeting['Student_1'],
                                        ),
                                        _buildDetailRow(
                                          icon: Icons.person_outline,
                                          label: 'Student 2',
                                          value: meeting['Student_2'],
                                        ),
                                        _buildDetailRow(
                                          icon: Icons.category,
                                          label: 'GP Type',
                                          value: meeting['GP_Type'],
                                        ),
                                        _buildDetailRow(
                                          icon: Icons.date_range,
                                          label: 'Date',
                                          value: meeting['Date'],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () =>
                                                  cancelMeeting(meeting['id']),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: primaryColor),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Parse the meeting's date and time
                                                DateTime meetingDateTime =
                                                    DateTime.parse(
                                                        meeting['Date']);

                                                // Check if the current time is past the meeting time
                                                if (!DateTime.now()
                                                    .isAfter(meetingDateTime)) {
                                                  // Show a message if the meeting date and time are in the future
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Meeting can only be created on or after the scheduled time."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return null; // Disable button
                                                }

                                                // Proceed with meeting creation logic if the time is valid
                                                final randomMeetingId = (Random()
                                                                .nextInt(
                                                                    1000000000) *
                                                            10 +
                                                        Random().nextInt(10))
                                                    .toString()
                                                    .padLeft(10, '0');

                                                await createNewMeeting(
                                                    randomMeetingId,
                                                    meeting['id']);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VideoConferencePage(
                                                      conferenceID:
                                                          randomMeetingId,
                                                      userId: userId,
                                                      meetingId: meeting['id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12),
                                              ),
                                              child: Text('Start Meeting'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearchVisible = !isSearchVisible;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;
  final String userId;
  final int meetingId;

  VideoConferencePage(
      {Key? key,
      required this.conferenceID,
      required this.userId,
      required this.meetingId})
      : super(key: key);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> endMeeting() async {
    final token = await getToken();

    if (token == null) {
      print("Token not found");
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_BASE_URL']}/GP/v1/meetings/endMeeting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"id": meetingId}),
      );

      if (response.statusCode == 200) {
        print("Meeting successfully ended on the server");
      } else {
        print("Failed to end meeting: ${response.statusCode}");
      }
    } catch (e) {
      print("Error ending meeting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int appID = int.parse(dotenv.get('ZEGO_APP_ID', fallback: '0'));
    final String appSign = dotenv.get('ZEGO_APP_SIGN', fallback: '');

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: appID,
        appSign: appSign,
        conferenceID: conferenceID,
        userID: userId,
        userName: '$userId',
        config: ZegoUIKitPrebuiltVideoConferenceConfig()
          ..onLeaveConfirmation = (context) async {
            // Call endMeeting before leaving
            await endMeeting();
            Navigator.of(context).pop(); // Leave the meeting screen
          },
      ),
    );
  }
}
