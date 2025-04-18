import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String conferenceId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final conferenceIdController = TextEditingController();
  final String randomConferenceId =
      (Random().nextInt(1000000000) * 10 + Random().nextInt(10))
          .toString()
          .padLeft(10, '0');
  String userId = 'Fetching...';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final token = await getToken();
      if (token != null) {
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
      } else {
        setState(() {
          userId = 'Token not found';
        });
      }
    } catch (e) {
      setState(() {
        userId = 'Error: $e';
      });
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Retrieve JWT token from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff0046DA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.zegocloud.com/_nuxt/img/pic_videoconference@2x.c50d1d2.png',
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            Text('Your userId: $userId'),
            const Text('Please test with 2 or more devices'),
            const SizedBox(height: 20),
            TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Join a Meeting by Input an Conference',
                hintText: 'Enter conferenceId',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              controller: conferenceIdController,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: buttonStyle,
                    child: const Text('Join a Meeting'),
                    onPressed: () {
                      final conferenceId = conferenceIdController.text;
                      print(
                          "Joining conference with ID: $conferenceId, User ID: $userId"); // Print conferenceId and userId
                      goToMeetingPage(context, conferenceId: conferenceId);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: buttonStyle,
                    child: const Text('New Meeting'),
                    onPressed: () {
                      print(
                          "Creating new meeting with ID: $randomConferenceId, User ID: $userId"); // Print randomConferenceId and userId
                      goToMeetingPage(context,
                          conferenceId: randomConferenceId);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void goToMeetingPage(BuildContext context, {required String conferenceId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConferencePage(
          conferenceID: conferenceId,
          userId: userId,
        ),
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
    // Print conferenceID and userId whenever VideoConferencePage is built
    print(
        "Entering VideoConferencePage with Conference ID: $conferenceID, User ID: $userId");

    // Ensure dotenv is initialized
    if (!dotenv.isInitialized) {
      throw Exception(
          "Environment variables not initialized. Make sure to call dotenv.load() in main().");
    }

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
