import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://kwpruamypgndlsbhbtlx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3cHJ1YW15cGduZGxzYmhidGx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzNTA2NzEsImV4cCI6MjA2MzkyNjY3MX0.4hLP0_X-ZJzM1hkvNmYMwwmAfEg-LjnxX-E0Gq9de30',
  );
  
  await NotificationService.initialize();
  
  runApp(PlantMonitorApp());
}

class PlantMonitorApp extends StatelessWidget {
  const PlantMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    SettingsScreen(),
  ];

  Future<List<double>> _fetchTemperatureData() async {
    try {
      final response = await _supabase
          .from('sensor_data')
          .select('temperature')
          .limit(24)
          .timeout(const Duration(seconds: 10));

      if (response.isEmpty) {
        throw Exception('No temperature data available');
      }

      return response.map((record) {
        final temp = record['temperature'];
        if (temp == null) throw Exception('Missing temperature value');
        if (temp is num) return temp.toDouble();
        throw Exception('Invalid temperature format');
      }).toList();
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch data: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _generateWeatherPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final temperatures = await _fetchTemperatureData();
      if (temperatures.isEmpty) {
        throw Exception('No valid temperature data available');
      }

      final avgTemp = temperatures.reduce((a, b) => a + b) / temperatures.length;
      final prediction = avgTemp * 1.03;
      final condition = _getWeatherCondition(prediction);
      final confidence = _calculateConfidence(temperatures);

      return {
        'current_avg': avgTemp.toStringAsFixed(1),
        'prediction': prediction.toStringAsFixed(1),
        'condition': condition,
        'confidence': confidence,
        'data_points': temperatures.length,
      };
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getWeatherCondition(double temp) {
    if (temp > 30) return 'Hot ☀️';
    if (temp > 25) return 'Warm 🌤️';
    if (temp > 20) return 'Mild ⛅';
    if (temp > 15) return 'Cool 🌥️';
    return 'Cold ❄️';
  }

  String _calculateConfidence(List<double> temps) {
    if (temps.length < 5) return 'Low (not enough data)';
    
    final mean = temps.reduce((a, b) => a + b) / temps.length;
    final variance = temps.map((t) => pow(t - mean, 2)).reduce((a, b) => a + b) / temps.length;
    final stdDev = sqrt(variance);

    if (stdDev < 1.0) return 'High (very stable)';
    if (stdDev < 2.5) return 'Medium (some variation)';
    return 'Low (high variability)';
  }

  Future<void> _showWeatherPrediction(BuildContext context) async {
    try {
      final prediction = await _generateWeatherPrediction();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🌦️ Weather Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPredictionRow('Current Average:', '${prediction['current_avg']}°C'),
                const SizedBox(height: 12),
                _buildPredictionRow('Tomorrow\'s Prediction:', '${prediction['prediction']}°C'),
                const SizedBox(height: 12),
                _buildPredictionRow('Expected Conditions:', prediction['condition']),
                const SizedBox(height: 12),
                _buildPredictionRow('Confidence:', prediction['confidence']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Failed to generate prediction'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildPredictionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Settings'),
        actions: _selectedIndex == 0 
            ? [
                if (_isLoading)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Predicting...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.wb_sunny_outlined, size: 20),
                      label: const Text('Predict Weather'),
                      onPressed: () => _showWeatherPrediction(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ]
            : null,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
