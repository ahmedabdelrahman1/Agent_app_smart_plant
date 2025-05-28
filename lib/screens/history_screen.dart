import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/sensor_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<SensorData> _historicalData = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Date range selection
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now().subtract(const Duration(days: 1));
  
  // Currently selected sensor type for chart
  String _selectedSensorType = 'temperature';
  
 @override
void initState() {
  super.initState();
  debugPrint('HistoryScreen initState called');
  // Ensure the fetch happens after the widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('Post frame callback - fetching historical data');
    _fetchHistoricalData();
  });
}
  Future<void> _fetchHistoricalData() async {
  debugPrint('=== FETCHING HISTORICAL DATA ===');
  debugPrint('Start date: $_startDate');
  debugPrint('End date: $_endDate');
  
  setState(() {
    _isLoading = true;
    _hasError = false;
  });
  
  try {
    final data = await SensorService.fetchSensorDataByDateRange(
      _startDate, 
      _endDate,
    );
    
    debugPrint('Fetched ${data.length} historical records');
    
    setState(() {
      _historicalData.clear();
      _historicalData.addAll(data);
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Error in _fetchHistoricalData: $e');
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load historical data: $e';
    });
  }
}
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked.start != _startDate || picked!.end != _endDate) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchHistoricalData();
    }
  }
  
  double _getValueForSensorType(SensorData data) {
    switch (_selectedSensorType) {
      case 'temperature':
        return data.temperature;
      case 'humidity':
        return data.humidity;
      case 'soilMoisture':
        return data.soilMoisture;
      case 'lightLevel':
        return data.lightLevel;
      default:
        return 0.0;
    }
  }
  
  String _getChartTitle() {
    switch (_selectedSensorType) {
      case 'temperature':
        return 'Temperature (°C)';
      case 'humidity':
        return 'Humidity (%)';
      case 'soilMoisture':
        return 'Soil Moisture (%)';
      case 'lightLevel':
        return 'Light Level (lux)';
      default:
        return '';
    }
  }
  
  Color _getChartColor() {
    switch (_selectedSensorType) {
      case 'temperature':
        return Colors.red;
      case 'humidity':
        return Colors.blue;
      case 'soilMoisture':
        return Colors.brown;
      case 'lightLevel':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor History'),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistoricalData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range display
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'From: ${DateFormat('MMM dd, yyyy').format(_startDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'To: ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sensor type selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'temperature',
                  label: Text('Temp'),
                  icon: Icon(Icons.thermostat),
                ),
                ButtonSegment(
                  value: 'humidity',
                  label: Text('Humidity'),
                  icon: Icon(Icons.water_drop),
                ),
                ButtonSegment(
                  value: 'soilMoisture',
                  label: Text('Soil'),
                  icon: Icon(Icons.grass),
                ),
                ButtonSegment(
                  value: 'lightLevel',
                  label: Text('Light'),
                  icon: Icon(Icons.wb_sunny),
                ),
              ],
              selected: {_selectedSensorType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedSensorType = newSelection.first;
                });
              },
            ),
          ),
          
          // Chart area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text('Loading sensor data...'),
                      ],
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchHistoricalData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _historicalData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No data available for the selected date range',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getChartTitle(),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_historicalData.length} data points',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
  child: LineChart(
    _buildLineChartData(),
    duration: const Duration(milliseconds: 250), // Changed from swapAnimationDuration
    curve: Curves.easeInOut, // Optional: add animation curve
  ),
),
                              ],
                            ),
                          ),
          ),
          
          // Data statistics card
          if (!_isLoading && !_hasError && _historicalData.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: _getChartColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Statistics - ${_getChartTitle()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatisticColumn('Minimum', _calculateMin(), Icons.arrow_downward),
                          _buildStatisticColumn('Maximum', _calculateMax(), Icons.arrow_upward),
                          _buildStatisticColumn('Average', _calculateAverage(), Icons.show_chart),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticColumn(String label, double value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: _getChartColor().withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: _getChartColor(),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
  
  double _calculateMin() {
    if (_historicalData.isEmpty) return 0;
    return _historicalData
        .map((data) => _getValueForSensorType(data))
        .reduce((a, b) => a < b ? a : b);
  }
  
  double _calculateMax() {
    if (_historicalData.isEmpty) return 0;
    return _historicalData
        .map((data) => _getValueForSensorType(data))
        .reduce((a, b) => a > b ? a : b);
  }
  
  double _calculateAverage() {
    if (_historicalData.isEmpty) return 0;
    final sum = _historicalData
        .map((data) => _getValueForSensorType(data))
        .reduce((a, b) => a + b);
    return sum / _historicalData.length;
  }
  
  LineChartData _buildLineChartData() {
    // Filter data to have a reasonable number of points
    List<SensorData> filteredData = _historicalData;
    if (_historicalData.length > 100) {
      final step = _historicalData.length ~/ 100;
      filteredData = [];
      for (int i = 0; i < _historicalData.length; i += step) {
        filteredData.add(_historicalData[i]);
      }
    }
    
    final spots = filteredData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value;
      return FlSpot(index, _getValueForSensorType(data));
    }).toList();
    
    // Calculate min and max values for better chart scaling
    final values = filteredData.map((data) => _getValueForSensorType(data)).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (range > 0 ? range / 5 : 1),
        verticalInterval: filteredData.length > 1 ? (filteredData.length - 1) / 5 : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: range > 0 ? range / 5 : 10,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: filteredData.length > 1 ? (filteredData.length - 1) / 5 : 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < filteredData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd\nHH:mm').format(filteredData[index].timestamp),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      minX: 0,
      maxX: filteredData.length - 1.0,
      minY: min - (range * 0.1),
      maxY: max + (range * 0.1),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getChartColor(),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _getChartColor().withOpacity(0.2),
          ),
        ),
      ],
    lineTouchData: LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (touchedSpot) => Colors.white.withOpacity(0.9), // Changed from tooltipBgColor
    tooltipBorder: BorderSide(color: _getChartColor(), width: 1),
    getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < filteredData.length) {
                final data = filteredData[index];
                return LineTooltipItem(
                  '${DateFormat('MMM dd, HH:mm').format(data.timestamp)}\n${spot.y.toStringAsFixed(1)} ${_getUnitForSensorType()}',
                  TextStyle(
                    color: _getChartColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: _getChartColor().withOpacity(0.5),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: _getChartColor(),
                  );
                },
              ),
            );
          }).toList();
        },
      ),
    );
  }
  
  String _getUnitForSensorType() {
    switch (_selectedSensorType) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'soilMoisture':
        return '%';
      case 'lightLevel':
        return 'lux';
      default:
        return '';
    }
  }
}

// Optional: Add a custom painter for gradient background
class ChartBackgroundPainter extends CustomPainter {
  final Color color;
  
  ChartBackgroundPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension to add utility methods
extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return DateFormat('MMM dd, yyyy HH:mm').format(this);
  }
  
  String toShortDateString() {
    return DateFormat('MM/dd').format(this);
  }
  
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }
}