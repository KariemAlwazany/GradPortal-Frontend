import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

const Color primaryColor = Color(0xFF3B4280);

class ScheduledMeetingsPage extends StatefulWidget {
  const ScheduledMeetingsPage({super.key});

  @override
  _ScheduledMeetingsPageState createState() => _ScheduledMeetingsPageState();
}

class _ScheduledMeetingsPageState extends State<ScheduledMeetingsPage> {
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
        Uri.parse(
            '${dotenv.env['API_BASE_URL']}/GP/v1/meetings/students/myMeetings'),
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
                                final meetingID = meeting['MeetingID'] ?? 'N/A';

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
                                            Icon(
                                              Icons.calendar_today,
                                              color: primaryColor,
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
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: meetingID != 'N/A'
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            VideoConferencePage(
                                                          conferenceID:
                                                              meetingID,
                                                          userId: userId,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null, // Disable button if MeetingID is 'N/A'
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 12),
                                            ),
                                            child: Text('Join Meeting'),
                                          ),
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

  const VideoConferencePage(
      {super.key, required this.conferenceID, required this.userId});

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
        userName: userId,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),
    );
  }
}
