import 'package:flutter/material.dart';
import '../widgets/sensor_card.dart';
import '../widgets/control_widget.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import '../utils/constants.dart';
import '../services/sensor_service.dart';
import '../models/sensor_reading.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  // Data handling
  SensorReading? _latestReading;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Control values
  double sunShieldPosition = 50.0;
  bool pumpActive = false;
  
  // Animation
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    
    // Fetch latest sensor data
    _loadLatestData();
  }
  
  Future<void> _loadLatestData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final dataList = await SensorService.fetchLatestSensorData();
      
       setState(() {
      if (dataList.isNotEmpty) {
        final latestData = dataList.first;
        // Create a SensorReading from SensorData
        _latestReading = SensorReading(
          id: DateTime.now().millisecondsSinceEpoch,
          temperature: latestData.temperature,
          humidity: latestData.humidity,
          soilMoisture: (latestData.soilMoisture * 100).toInt(), // Convert to percentage
          lightLevel: latestData.lightLevel.toInt(),
          pumpStatus: pumpActive, // Keep current pump status
          insertedAt: latestData.timestamp,
        );
      }
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load data: $e';
      _isLoading = false;
    });
    print('Error loading sensor data: $e');
  }
  }
  
  // Get safe values with fallbacks
  double get temperature => _latestReading?.temperature ?? 24.5;
double get moistureLevel => _latestReading != null ? _latestReading!.soilMoisture.toDouble() / 100 : 65.0;
  double get lightLevel => _latestReading?.lightLevel.toDouble() ?? 75.0;
  double get humidity => _latestReading?.humidity ?? 65.0;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadLatestData,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: kPrimaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('My Plant Monitor',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kPrimaryColor,
                            kPrimaryDarkColor,
                          ],
                        ),
                      ),
                    ),
                    // Plant pattern overlay with error handling
                    Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        'assets/images/images.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.transparent);
                        },
                      ),
                    ),
                    // Bottom gradient shadow for better text contrast
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status content
                    Positioned(
                      bottom: 70,
                      left: 16,
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.2, 0.8, curve: Curves.easeOut),
                        )),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _isLoading ? Colors.amber : 
                                      _errorMessage.isNotEmpty ? Colors.red : 
                                      Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _isLoading ? 'Loading data...' :
                              _errorMessage.isNotEmpty ? 'Connection error' :
                              'System Online',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Last updated timestamp
                    if (_latestReading != null)
                      Positioned(
                        bottom: 50,
                        left: 16,
                        child: Text(
                          'Last updated: ${_formatDateTime(_latestReading!.insertedAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'Refresh data',
                  onPressed: _loadLatestData,
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined),
                  ),
                  tooltip: 'Diagnose Plant',
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => CameraScreen()),
                    );
                  },
                ),
                SizedBox(width: 8),
              ],
            ),
            
            // Display loading indicator or error if needed
            if (_isLoading)
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
              
            if (!_isLoading && _errorMessage.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load sensor data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(_errorMessage),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLatestData,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Main content
            if (!_isLoading && _errorMessage.isEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Readings',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Monitor your plant\'s environment in real-time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Quick stats summary
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            _buildQuickStatItem(
                              context,
                              icon: Icons.thermostat_outlined,
                              value: '${temperature.toStringAsFixed(1)}°C', 
                              label: 'Temp',
                              color: kTemperatureColor,
                              delay: 0.0,
                            ),
                            SizedBox(width: 8),
                            _buildQuickStatItem(
                              context,
                              icon: Icons.water_drop_outlined,
                              value: '${(moistureLevel).toStringAsFixed(1)}%', 
                              label: 'Moisture',
                              color: kMoistureColor,
                              delay: 0.2,
                            ),
                            SizedBox(width: 8),
                            _buildQuickStatItem(
                              context,
                              icon: Icons.wb_sunny_outlined,
                              value: '${lightLevel.toStringAsFixed(1)} lux', 
                              label: 'Light',
                              color: kLightColor,
                              delay: 0.4,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      Text(
                        'Detailed Monitoring',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          
            // Sensor cards
            if (!_isLoading && _errorMessage.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Modern sensor cards with better visual design
                    ModernSensorCard(
                      title: 'Temperature',
                      value: temperature,
                      unit: '°C',
                      icon: Icons.thermostat_outlined,
                      color: kTemperatureColor,
                      gradientColors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                      minValue: 15,
                      maxValue: 35,
                      idealRange: 'Ideal: 18-27°C',
                      onViewHistory: () => _navigateToHistory('Temperature', '°C'),
                      delay: 0.1,
                      controller: _controller,
                    ),
                    
                    ModernSensorCard(
                      title: 'Soil Moisture',
                      value: moistureLevel,
                      unit: '%',
                      icon: Icons.water_drop_outlined,
                      color: kMoistureColor,
                      gradientColors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      minValue: 0,
                      maxValue: 100,
                      idealRange: 'Ideal: 40-70%',
                      onViewHistory: () => _navigateToHistory('Soil Moisture', '%'),
                      delay: 0.2,
                      controller: _controller,
                    ),
                    
                    ModernSensorCard(
                      title: 'Light Intensity',
                      value: lightLevel,
                      unit: 'lux',
                      icon: Icons.wb_sunny_outlined,
                      color: kLightColor,
                      gradientColors: [Color(0xFFFFC371), Color(0xFFFF5F6D)],
                      minValue: 0,
                      maxValue: 100,
                      idealRange: 'Ideal: 50-80 lux',
                      onViewHistory: () => _navigateToHistory('Light Level', 'lux'),
                      delay: 0.3,
                      controller: _controller,
                    ),

                    ModernSensorCard(
  title: 'Humidity',
  value: humidity,
  unit: '%',
  icon: Icons.water_drop_outlined,
  color: Colors.blue,
  gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
  minValue: 0,
  maxValue: 100,
  idealRange: 'Ideal: 50-70%',
  onViewHistory: () => _navigateToHistory('Humidity', '%'),
  delay: 0.35,
  controller: _controller,
),
                    
                    SizedBox(height: 24),
                  
                    SizedBox(height: 16),
                    
                    
                    
                    SizedBox(height: 24),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Format the DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (date == today.subtract(Duration(days: 1))) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}, ${_formatTime(dateTime)}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // Method to update pump status in database
  Future<void> _updatePumpStatus(bool status) async {
    // Here you would add code to update the pump status in your database
    // For now, we'll just print the status change
    print('Pump status changed to: $status');
  }
  
  Widget _buildQuickStatItem(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double delay,
  }) {
    return Expanded(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.6, curve: Curves.easeOut),
        )),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(delay, delay + 0.6, curve: Curves.easeOut),
          )),
          child: Card(
            elevation: 0,
            color: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToHistory(String sensorType, String unit) async {
  debugPrint('Navigating to history for: $sensorType');
  
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HistoryScreen(),
    ),
  );
  
  // Optionally refresh dashboard data when returning
  debugPrint('Returned from history screen');
}
}