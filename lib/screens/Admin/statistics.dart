import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryColor = Color(0xFF3B4280);

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Statistics Data
  int doctorsCount = 0;
  int studentsCount = 0;
  int sellersCount = 0;
  int normalUsersCount = 0; // Added for normal users
  int projectsCount = 0;
  int softwareProjects = 0;
  int hardwareProjects = 0;
  int upcomingMeetings = 0;
  int completedMeetings = 0;
  int storeItemsCount = 0;
  int transactionsCount = 0;
  int profit = 0;
  List<int> monthlyCounts = List.generate(12, (_) => 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchStatistics();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchStatistics() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Token not found");

      final baseUrl = dotenv.env['API_BASE_URL'];

      final protfitResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/orders/getProfitData'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final storeResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/seller/items/countAllItems'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final studentsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/users/students/count'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final doctorsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/users/doctors/count'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final sellersResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/users/sellers/count'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final normalUsersResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/users/normal/count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch projects count
      final projectsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/projects/all/count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch software projects count
      final softwareProjectsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/projects/software/count'),
      );

      // Fetch hardware projects count
      final hardwareProjectsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/projects/hardware/count'),
      );

      // Fetch all users for monthly registration
      final allUsersResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch meeting statistics
      final completedMeetingsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/meetings/completed'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final upcomingMeetingsResponse = await http.get(
        Uri.parse('$baseUrl/GP/v1/meetings/upcoming'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (studentsResponse.statusCode == 200) {
        final studentsData = json.decode(studentsResponse.body);
        studentsCount = studentsData['data']['count'];
      }

      if (doctorsResponse.statusCode == 200) {
        final doctorsData = json.decode(doctorsResponse.body);
        doctorsCount = doctorsData['data']['count'];
      }

      if (sellersResponse.statusCode == 200) {
        final sellersData = json.decode(sellersResponse.body);
        sellersCount = sellersData['data']['count'];
      }

      if (normalUsersResponse.statusCode == 200) {
        final normalUsersData = json.decode(normalUsersResponse.body);
        normalUsersCount = normalUsersData['data']['count'];
      }

      if (projectsResponse.statusCode == 200) {
        final projectsData = json.decode(projectsResponse.body);
        projectsCount = projectsData['data']['projectsCount'];
      }

      if (softwareProjectsResponse.statusCode == 200) {
        final softwareData = json.decode(softwareProjectsResponse.body);
        softwareProjects = softwareData['data']['softwareCount'];
      }

      if (hardwareProjectsResponse.statusCode == 200) {
        final hardwareData = json.decode(hardwareProjectsResponse.body);
        hardwareProjects = hardwareData['data']['hardwareCount'];
      }

      if (allUsersResponse.statusCode == 200) {
        final usersData = json.decode(allUsersResponse.body);
        final users = usersData['data']['data'];

        // Calculate monthly counts from createdAt field
        for (var user in users) {
          final createdAt = DateTime.parse(user['createdAt']);
          monthlyCounts[createdAt.month - 1]++;
        }
      }

      if (completedMeetingsResponse.statusCode == 200) {
        final completedData = json.decode(completedMeetingsResponse.body);
        completedMeetings = completedData['data']['completed'];
      }

      if (upcomingMeetingsResponse.statusCode == 200) {
        final upcomingData = json.decode(upcomingMeetingsResponse.body);
        upcomingMeetings = upcomingData['data']['upcomming'];
      }
      if (storeResponse.statusCode == 200) {
        final storeResponsedata = json.decode(storeResponse.body);
        storeItemsCount = storeResponsedata['totalItems'];
      }
      if (protfitResponse.statusCode == 200) {
        final protfitResponsedata = json.decode(protfitResponse.body);
        profit = protfitResponsedata['data']['1'];
      }
      setState(() {});
    } catch (error) {
      print('Error fetching statistics: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Statistics',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.black,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.people), text: "Users"),
                  Tab(icon: Icon(Icons.work), text: "Projects"),
                  Tab(icon: Icon(Icons.store), text: "Store"),
                  Tab(icon: Icon(Icons.video_call), text: "Meetings"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersPage(),
          _buildProjectsPage(),
          _buildStorePage(),
          _buildMeetingsPage(),
        ],
      ),
    );
  }

  Widget _buildUsersPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.person,
                  title: 'Doctors',
                  count: '$doctorsCount',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.school,
                  title: 'Students',
                  count: '$studentsCount',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.store,
                  title: 'Sellers',
                  count: '$sellersCount',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.group,
                  title: 'Users',
                  count: '$normalUsersCount',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildPieChart(
            title: 'User Distribution',
            data: [doctorsCount, studentsCount, sellersCount, normalUsersCount],
            colors: [
              Colors.blueAccent,
              Colors.greenAccent,
              Colors.orangeAccent,
              Colors.purpleAccent
            ],
            labels: ['Doctors', 'Students', 'Sellers', 'Users'],
          ),
          SizedBox(height: 24),
          _buildBarChart(title: 'Monthly Registrations', data: monthlyCounts),
        ],
      ),
    );
  }

  Widget _buildProjectsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.stacked_line_chart,
                  title: 'Total Projects',
                  count: '$projectsCount',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.computer,
                  title: 'Software Projects',
                  count: '$softwareProjects',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.memory,
                  title: 'Hardware Projects',
                  count: '$hardwareProjects',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildPieChart(
            title: 'Projects Distribution',
            data: [softwareProjects, hardwareProjects],
            colors: [Colors.blue, Colors.orange],
            labels: ['Software', 'Hardware'],
          ),
        ],
      ),
    );
  }

  Widget _buildStorePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.shopping_cart,
                  title: 'Store Items',
                  count: '$storeItemsCount',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.monetization_on,
                  title: 'Profit',
                  count: '$profit',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildBarChart(
            title: 'Store Overview',
            data: [storeItemsCount, profit],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.videocam,
                  title: 'Upcoming Meetings',
                  count: '$upcomingMeetings',
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: _buildOptionCard(
                  icon: Icons.done_all,
                  title: 'Completed Meetings',
                  count: '$completedMeetings',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildBarChart(
            title: 'Meetings Overview',
            data: [upcomingMeetings, completedMeetings],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      {required IconData icon, required String title, required String count}) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: primaryColor),
              SizedBox(height: 16),
              Text(
                count,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
      {required String title,
      required List<int> data,
      required List<Color> colors,
      required List<String> labels}) {
    final sections = List.generate(data.length, (index) {
      if (data[index] > 0) {
        return PieChartSectionData(
          color: colors[index],
          value: data[index].toDouble(),
          title: labels[index],
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }
      return null;
    }).where((section) => section != null).cast<PieChartSectionData>().toList();

    if (sections.isEmpty) {
      return Center(
        child: Text(
          'No data available for pie chart',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart({required String title, required List<int> data}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor)),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                        y: data[index].toDouble(),
                        colors: [Colors.blueAccent],
                        width: 16),
                  ]);
                }),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      if (title == 'Store Overview') {
                        return ['Items', 'Profit'][value.toInt()];
                      } else if (title == 'Meetings Overview') {
                        return ['Upcoming', 'Completed'][value.toInt()];
                      } else if (title == 'Projects Overview') {
                        return ['Total', 'Software', 'Hardware'][value.toInt()];
                      }
                      return [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ].elementAt(value.toInt());
                    },
                  ),
                  leftTitles: SideTitles(showTitles: true),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
