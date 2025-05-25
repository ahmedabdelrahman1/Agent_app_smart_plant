import 'package:flutter/material.dart';
import '../widgets/history_chart.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String sensorType;
  final String unit;
  
  const HistoryScreen({
    Key? key,
    required this.sensorType,
    required this.unit,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Day';
  final List<String> _periods = ['Day', 'Week', 'Month'];
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Mock data - would be fetched from your database
  List<Map<String, dynamic>> getMockData() {
    if (widget.sensorType == 'Temperature') {
      return List.generate(24, (i) => {
        'time': DateTime.now().subtract(Duration(hours: 24-i)),
        'value': 20 + (i % 10),
      });
    } else if (widget.sensorType.contains('Light')) {
      return List.generate(24, (i) => {
        'time': DateTime.now().subtract(Duration(hours: 24-i)),
        'value': 50 + (i * 5) % 50,
      });
    } else {
      return List.generate(24, (i) => {
        'time': DateTime.now().subtract(Duration(hours: 24-i)),
        'value': 40 + (i * 3) % 60,
      });
    }
  }

  Color _getSensorColor() {
    if (widget.sensorType.contains('Temperature')) {
      return kTemperatureColor;
    } else if (widget.sensorType.contains('Moisture')) {
      return kMoistureColor;
    } else {
      return kLightColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = getMockData();
    final sensorColor = _getSensorColor();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sensorType} History'),
        backgroundColor: sensorColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sensor info header
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: sensorColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: sensorColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking your ${widget.sensorType.toLowerCase()} changes over time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Period selector
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.2, 0.7, curve: Curves.easeOut),
                    )),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time Period:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: sensorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPeriod,
                                  icon: Icon(Icons.keyboard_arrow_down, color: sensorColor),
                                  style: TextStyle(
                                    color: sensorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedPeriod = newValue;
                                      });
                                    }
                                  },
                                  items: _periods.map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }
                                  ).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Chart
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Interval(0.3, 0.8, curve: Curves.easeOut),
                      )),
                      child: SimpleHistoryChart(
                        data: data,
                        sensorType: widget.sensorType,
                        unit: widget.unit,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Stats summary
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.4, 0.9, curve: Curves.easeOut),
                    )),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.analytics_outlined, color: sensorColor),
                                SizedBox(width: 8),
                                Text(
                                  'Statistics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            _buildStatRow(
                              context, 
                              label: 'Average', 
                              value: '${_calculateAverage(data).toStringAsFixed(1)} ${widget.unit}',
                              icon: Icons.calculate_outlined,
                              sensorColor: sensorColor,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: _buildStatRow(
                                context,
                                label: 'Minimum', 
                                value: '${_calculateMin(data).toStringAsFixed(1)} ${widget.unit}',
                                icon: Icons.arrow_downward,
                                sensorColor: sensorColor,
                              ),
                            ),
                            _buildStatRow(
                              context,
                              label: 'Maximum', 
                              value: '${_calculateMax(data).toStringAsFixed(1)} ${widget.unit}',
                              icon: Icons.arrow_upward,
                              sensorColor: sensorColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(BuildContext context, {
    required String label, 
    required String value,
    required IconData icon,
    required Color sensorColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: sensorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: sensorColor),
        ),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  
  double _calculateAverage(List<Map<String, dynamic>> data) {
    return data.map((e) => e['value'] as double).reduce((a, b) => a + b) / data.length;
  }
  
  double _calculateMin(List<Map<String, dynamic>> data) {
    return data.map((e) => e['value'] as double).reduce((a, b) => a < b ? a : b);
  }
  
  double _calculateMax(List<Map<String, dynamic>> data) {
    return data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
  }
}