import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const Color primaryColor = Color(0xFF3B4280);

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Statistics Data
  int doctorsCount = 120;
  int studentsCount = 350;
  int sellersCount = 75;
  int normalUsersCount = 400; // Added for normal users
  int projectsCount = 50;
  int softwareProjects = 30;
  int hardwareProjects = 20;
  int upcomingMeetings = 15;
  int completedMeetings = 25;
  int storeItemsCount = 100;
  int transactionsCount = 200;
  List<int> monthlyCounts = List.generate(12, (_) => 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Simulate data fetching
    _simulateFetchStatistics();
  }

  void _simulateFetchStatistics() {
    // Simulate fetching data by generating random values or using static values
    setState(() {});
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
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.person,
                  title: 'Doctors',
                  count: '$doctorsCount',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.school,
                  title: 'Students',
                  count: '$studentsCount',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.store,
                  title: 'Sellers',
                  count: '$sellersCount',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
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
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.stacked_line_chart,
                  title: 'Total Projects',
                  count: '$projectsCount',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.computer,
                  title: 'Software Projects',
                  count: '$softwareProjects',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
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
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.shopping_cart,
                  title: 'Store Items',
                  count: '$storeItemsCount',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.monetization_on,
                  title: 'Transactions',
                  count: '$transactionsCount',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildBarChart(
            title: 'Store Overview',
            data: [storeItemsCount, transactionsCount],
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
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.videocam,
                  title: 'Upcoming Meetings',
                  count: '$upcomingMeetings',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
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
    List<PieChartSectionData> sections = List.generate(data.length, (index) {
      return PieChartSectionData(
        value: data[index].toDouble(),
        color: colors[index],
        title: '${labels[index]} (${data[index]})',
        radius: 40,
      );
    });

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          PieChart(PieChartData(sections: sections)),
        ],
      ),
    );
  }

  Widget _buildBarChart({required String title, required List<int> data}) {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          BarChart(
            BarChartData(
              barGroups: data
                  .asMap()
                  .map((index, value) {
                    return MapEntry(
                      index,
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            y: value.toDouble(),
                            colors: [primaryColor],
                            width: 16,
                          ),
                        ],
                      ),
                    );
                  })
                  .values
                  .toList(),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ],
      ),
    );
  }
}
