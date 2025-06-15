import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';

void main() async {
  // Add this line - IMPORTANT
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase - IMPORTANT
  await Supabase.initialize(
    url: 'https://kwpruamypgndlsbhbtlx.supabase.co', // Replace with your URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3cHJ1YW15cGduZGxzYmhidGx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzNTA2NzEsImV4cCI6MjA2MzkyNjY3MX0.4hLP0_X-ZJzM1hkvNmYMwwmAfEg-LjnxX-E0Gq9de30', // Replace with your anon key
  );
  
  await NotificationService.initialize();
  
  runApp(PlantMonitorApp());
}

class PlantMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
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
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    SettingsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}