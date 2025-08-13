import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  final List<double> distanceHistory;

  const AnalyticsPage({Key? key, required this.distanceHistory})
      : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedTimeRange = 0; // 0: All, 1: Last 50, 2: Last 20

  List<double> get _filteredData {
    switch (_selectedTimeRange) {
      case 1:
        return widget.distanceHistory.length > 50
            ? widget.distanceHistory.sublist(widget.distanceHistory.length - 50)
            : widget.distanceHistory;
      case 2:
        return widget.distanceHistory.length > 20
            ? widget.distanceHistory.sublist(widget.distanceHistory.length - 20)
            : widget.distanceHistory;
      default:
        return widget.distanceHistory;
    }
  }

  double get _averageDistance {
    if (_filteredData.isEmpty) return 0;
    return _filteredData.reduce((a, b) => a + b) / _filteredData.length;
  }

  double get _minDistance {
    if (_filteredData.isEmpty) return 0;
    return _filteredData.reduce((a, b) => a < b ? a : b);
  }

  double get _maxDistance {
    if (_filteredData.isEmpty) return 0;
    return _filteredData.reduce((a, b) => a > b ? a : b);
  }

  int get _occupiedCount {
    return _filteredData.where((distance) => distance < 50).length;
  }

  double get _occupancyRate {
    if (_filteredData.isEmpty) return 0;
    return (_occupiedCount / _filteredData.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Seat Analytics'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Time Range Selector
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Range',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ToggleButtons(
                      isSelected: [
                        _selectedTimeRange == 0,
                        _selectedTimeRange == 1,
                        _selectedTimeRange == 2,
                      ],
                      onPressed: (index) {
                        setState(() {
                          _selectedTimeRange = index;
                        });
                      },
                      children: const [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('All')),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Last 50')),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Last 20')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                    'Average Distance',
                    '${_averageDistance.toStringAsFixed(1)} cm',
                    Icons.straighten,
                    Colors.blue),
                _buildStatCard(
                    'Occupancy Rate',
                    '${_occupancyRate.toStringAsFixed(1)}%',
                    Icons.person,
                    Colors.green),
                _buildStatCard(
                    'Min Distance',
                    '${_minDistance.toStringAsFixed(1)} cm',
                    Icons.compress,
                    Colors.orange),
                _buildStatCard(
                    'Max Distance',
                    '${_maxDistance.toStringAsFixed(1)} cm',
                    Icons.expand,
                    Colors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // Line Chart
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance Over Time',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: _filteredData.isEmpty
                          ? const Center(child: Text('No data available'))
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()}cm',
                                            style:
                                                const TextStyle(fontSize: 10));
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()}',
                                            style:
                                                const TextStyle(fontSize: 10));
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots:
                                        _filteredData.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value);
                                    }).toList(),
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 3,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Occupancy Chart
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seat Occupancy',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: _occupiedCount.toDouble(),
                              title: 'Occupied\n$_occupiedCount',
                              color: Colors.red,
                              radius: 80,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: (_filteredData.length - _occupiedCount)
                                  .toDouble(),
                              title:
                                  'Available\n${_filteredData.length - _occupiedCount}',
                              color: Colors.green,
                              radius: 80,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
