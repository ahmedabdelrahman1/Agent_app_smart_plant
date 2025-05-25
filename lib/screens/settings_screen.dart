import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  double _moistureThreshold = 30.0;
  double _temperatureThreshold = 30.0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('App Settings'),
            subtitle: Text('Customize the application behavior'),
            leading: Icon(Icons.app_settings_alt),
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Enable dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // Here you would implement the theme switching logic
              });
            },
          ),
          SwitchListTile(
            title: Text('Notifications'),
            subtitle: Text('Receive alerts when action is needed'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          Divider(),
          
          ListTile(
            title: Text('Plant Care Settings'),
            subtitle: Text('Set thresholds for plant health alerts'),
            leading: Icon(Icons.eco),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moisture Alert Threshold'),
                Text('${_moistureThreshold.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          Slider(
            value: _moistureThreshold,
            min: 0,
            max: 100,
            divisions: 100,
            label: _moistureThreshold.round().toString(),
            onChanged: (value) {
              setState(() {
                _moistureThreshold = value;
              });
            },
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Temperature Alert Threshold'),
                Text('${_temperatureThreshold.toStringAsFixed(0)}°C'),
              ],
            ),
          ),
          Slider(
            value: _temperatureThreshold,
            min: 10,
            max: 40,
            divisions: 30,
            label: _temperatureThreshold.round().toString(),
            onChanged: (value) {
              setState(() {
                _temperatureThreshold = value;
              });
            },
          ),
          
          Divider(),
          
          ListTile(
            title: Text('Device Settings'),
            subtitle: Text('Connect and configure your monitoring device'),
            leading: Icon(Icons.devices),
            onTap: () {
              // Navigate to device settings page
            },
          ),
          
          ListTile(
            title: Text('About'),
            subtitle: Text('App version and information'),
            leading: Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Smart Plant Monitor',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 Plant Monitor Inc.',
              );
            },
          ),
        ],
      ),
    );
  }
}