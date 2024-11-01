import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const Color primaryColor = Color(0xFF3B4280);

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Statistics',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                      child: _buildSummaryCard('Doctors', '50', Icons.person)),
                  SizedBox(width: 16),
                  Flexible(
                      child:
                          _buildSummaryCard('Students', '200', Icons.school)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                      child: _buildSummaryCard('Sellers', '30', Icons.store)),
                  SizedBox(width: 16),
                  Flexible(
                      child: _buildSummaryCard('Projects', '120', Icons.work)),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 300, // Fixed height for pie chart
                child: _buildPieChart(),
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 300, // Fixed height for bar chart
                child: _buildBarChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon) {
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
          Icon(icon, size: 40, color: primaryColor),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
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
            'User Distribution',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: 50,
                    title: 'Doctors',
                    radius: 50,
                    titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: 200,
                    title: 'Students',
                    radius: 50,
                    titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orangeAccent,
                    value: 30,
                    title: 'Sellers',
                    radius: 50,
                    titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
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
            'Monthly Registrations',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 20,
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(showTitles: true, reservedSize: 28),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      switch (value.toInt()) {
                        case 0:
                          return 'Jan';
                        case 1:
                          return 'Feb';
                        case 2:
                          return 'Mar';
                        case 3:
                          return 'Apr';
                        case 4:
                          return 'May';
                        case 5:
                          return 'Jun';
                        default:
                          return '';
                      }
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        y: 10, colors: [Colors.blueAccent], width: 16)
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        y: 12, colors: [Colors.greenAccent], width: 16)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        y: 8, colors: [Colors.orangeAccent], width: 16)
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                        y: 14, colors: [Colors.purpleAccent], width: 16)
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(y: 9, colors: [Colors.redAccent], width: 16)
                  ]),
                  BarChartGroupData(x: 5, barRods: [
                    BarChartRodData(
                        y: 11, colors: [Colors.yellowAccent], width: 16)
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
