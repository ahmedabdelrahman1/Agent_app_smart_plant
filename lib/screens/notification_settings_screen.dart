import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  Map<String, double> _thresholds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    final thresholds = await NotificationService.getThresholds();
    setState(() {
      _thresholds = thresholds;
      _isLoading = false;
    });
  }

  Future<void> _saveThreshold(String key, double value) async {
    await NotificationService.saveThreshold(key, value);
    setState(() {
      _thresholds[key] = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Threshold updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Notification Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Temperature Thresholds'),
          _buildThresholdTile(
            'Minimum Temperature',
            '°C',
            NotificationService.TEMP_MIN_KEY,
            'temp_min',
            0,
            50,
            Icons.thermostat,
            kTemperatureColor,
          ),
          _buildThresholdTile(
            'Maximum Temperature',
            '°C',
            NotificationService.TEMP_MAX_KEY,
            'temp_max',
            0,
            50,
            Icons.thermostat,
            kTemperatureColor,
          ),
          
          SizedBox(height: 24),
          _buildSectionTitle('Soil Moisture Thresholds'),
          _buildThresholdTile(
            'Minimum Moisture',
            '%',
            NotificationService.MOISTURE_MIN_KEY,
            'moisture_min',
            0,
            100,
            Icons.water_drop,
            kMoistureColor,
          ),
          _buildThresholdTile(
            'Maximum Moisture',
            '%',
            NotificationService.MOISTURE_MAX_KEY,
            'moisture_max',
            0,
            100,
            Icons.water_drop,
            kMoistureColor,
          ),
          
          SizedBox(height: 24),
          _buildSectionTitle('Light Level Thresholds'),
          _buildThresholdTile(
            'Minimum Light',
            'lux',
            NotificationService.LIGHT_MIN_KEY,
            'light_min',
            0,
            9999,
            Icons.wb_sunny,
            kLightColor,
          ),
          _buildThresholdTile(
            'Maximum Light',
            'lux',
            NotificationService.LIGHT_MAX_KEY,
            'light_max',
            10000,
            20000,
            Icons.wb_sunny,
            kLightColor,
          ),
          
          SizedBox(height: 24),
          _buildSectionTitle('Humidity Thresholds'),
          _buildThresholdTile(
            'Minimum Humidity',
            '%',
            NotificationService.HUMIDITY_MIN_KEY,
            'humidity_min',
            0,
            100,
            Icons.water_drop_outlined,
            Colors.blue,
          ),
          _buildThresholdTile(
            'Maximum Humidity',
            '%',
            NotificationService.HUMIDITY_MAX_KEY,
            'humidity_max',
            0,
            100,
            Icons.water_drop_outlined,
            Colors.blue,
          ),
          
          SizedBox(height: 32),
          Center(
            child: Text(
              'Notifications are sent when values go outside these ranges',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThresholdTile(
    String title,
    String unit,
    String prefKey,
    String thresholdKey,
    double min,
    double max,
    IconData icon,
    Color color,
  ) {
    final value = _thresholds[thresholdKey] ?? 0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
                          activeColor: color,
              onChanged: (newValue) {
                setState(() {
                  _thresholds[thresholdKey] = newValue;
                });
              },
              onChangeEnd: (newValue) {
                _saveThreshold(prefKey, newValue);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.toStringAsFixed(0)} $unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${max.toStringAsFixed(0)} $unit',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}