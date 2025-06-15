import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sensor_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // OneSignal REST API endpoint
  static const String oneSignalApiUrl = 'https://onesignal.com/api/v1/notifications';
  // Your OneSignal App ID
  static const String appId = 'f19dddbc-690c-4508-b3fb-871102c7fc5d';
  // IMPORTANT: Replace this with your actual REST API Key from OneSignal Dashboard
  static const String restApiKey = 'os_v2_app_6go53pdjbrcqrm73q4iqfr74lvu2kdlec3oueu4hbjjhz2mms4lynqahbxcl2hktqzjw2sdafxs66sjmnbwhiv7u5pimwmhy5xphm6i'; // ← Replace this!
  
  // Store the player ID locally
  static String? _currentPlayerId;
  
  // Threshold keys for SharedPreferences
  static const String TEMP_MIN_KEY = 'temp_min_threshold';
  static const String TEMP_MAX_KEY = 'temp_max_threshold';
  static const String MOISTURE_MIN_KEY = 'moisture_min_threshold';
  static const String MOISTURE_MAX_KEY = 'moisture_max_threshold';
  static const String LIGHT_MIN_KEY = 'light_min_threshold';
  static const String LIGHT_MAX_KEY = 'light_max_threshold';
  static const String HUMIDITY_MIN_KEY = 'humidity_min_threshold';
  static const String HUMIDITY_MAX_KEY = 'humidity_max_threshold';
  
  // Default thresholds
  static const double DEFAULT_TEMP_MIN = 18.0;
  static const double DEFAULT_TEMP_MAX = 29.0;
  static const double DEFAULT_MOISTURE_MIN = 40.0;
  static const double DEFAULT_MOISTURE_MAX = 70.0;
  static const double DEFAULT_LIGHT_MIN = 30.0;
  static const double DEFAULT_LIGHT_MAX = 80.0;
  static const double DEFAULT_HUMIDITY_MIN = 40.0;
  static const double DEFAULT_HUMIDITY_MAX = 70.0;

  // Initialize OneSignal
  static Future<void> initialize() async {
    try {
      print(' Initializing OneSignal...');
      
      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(appId);
      
      // Request permission for notifications
      await OneSignal.Notifications.requestPermission(true);
      
      // Wait a bit for initialization
      await Future.delayed(Duration(seconds: 3));
      
      // Get and store the player ID
      _currentPlayerId = OneSignal.User.pushSubscription.id;
      print('OneSignal initialized with Player ID: $_currentPlayerId');
      
      // Check if we have a valid player ID
      if (_currentPlayerId == null || _currentPlayerId!.isEmpty) {
        print(' Warning: No player ID received. Trying alternative method...');
        
        // Wait a bit more and try again
        await Future.delayed(Duration(seconds: 2));
        _currentPlayerId = OneSignal.User.pushSubscription.id;
        
        if (_currentPlayerId != null) {
          print(' Player ID obtained on retry: $_currentPlayerId');
        } else {
          print(' Still no player ID. Check OneSignal setup.');
        }
      }
      
      // Save player ID to SharedPreferences for persistence
      if (_currentPlayerId != null && _currentPlayerId!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('onesignal_player_id', _currentPlayerId!);
        print(' Player ID saved to SharedPreferences');
      }
      
      // Set up notification handlers
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print(" Notification received in foreground: ${event.notification.title}");
        print(" Body: ${event.notification.body}");
      });
      
      OneSignal.Notifications.addClickListener((event) {
        print(" Notification clicked: ${event.notification.title}");
      });
      
      // Check notification permission
      final hasPermission = await OneSignal.Notifications.permission;
      print(' Notification permission granted: $hasPermission');
      
      // Check subscription status
      final isSubscribed = OneSignal.User.pushSubscription.optedIn;
      print(' Push subscription status: $isSubscribed');
      
    } catch (e) {
      print(' Error initializing OneSignal: $e');
    }
  }
  
  // Get stored player ID
  static Future<String?> getPlayerId() async {
    if (_currentPlayerId != null && _currentPlayerId!.isNotEmpty) {
      return _currentPlayerId;
    }
    
    // Try to get from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _currentPlayerId = prefs.getString('onesignal_player_id');
    
    // If still null, try to get from OneSignal
    if (_currentPlayerId == null || _currentPlayerId!.isEmpty) {
      _currentPlayerId = OneSignal.User.pushSubscription.id;
      if (_currentPlayerId != null && _currentPlayerId!.isNotEmpty) {
        await prefs.setString('onesignal_player_id', _currentPlayerId!);
        print(' New Player ID saved: $_currentPlayerId');
      }
    }
    
    return _currentPlayerId;
  }
  
  // Get threshold values from SharedPreferences
  static Future<Map<String, double>> getThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'temp_min': prefs.getDouble(TEMP_MIN_KEY) ?? DEFAULT_TEMP_MIN,
      'temp_max': prefs.getDouble(TEMP_MAX_KEY) ?? DEFAULT_TEMP_MAX,
      'moisture_min': prefs.getDouble(MOISTURE_MIN_KEY) ?? DEFAULT_MOISTURE_MIN,
      'moisture_max': prefs.getDouble(MOISTURE_MAX_KEY) ?? DEFAULT_MOISTURE_MAX,
      'light_min': prefs.getDouble(LIGHT_MIN_KEY) ?? DEFAULT_LIGHT_MIN,
      'light_max': prefs.getDouble(LIGHT_MAX_KEY) ?? DEFAULT_LIGHT_MAX,
      'humidity_min': prefs.getDouble(HUMIDITY_MIN_KEY) ?? DEFAULT_HUMIDITY_MIN,
      'humidity_max': prefs.getDouble(HUMIDITY_MAX_KEY) ?? DEFAULT_HUMIDITY_MAX,
    };
  }
  
  // Save threshold values to SharedPreferences
  static Future<void> saveThreshold(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
  
  // Check sensor readings and send notifications if needed
  static Future<void> checkAndNotify(SensorReading reading) async {
    print(' Checking sensor readings for notifications...');
    print('Temperature: ${reading.temperature}°C');
    print('Soil Moisture: ${reading.soilMoisture}%');
    print('Light: ${reading.lightLevel} lux');
    print('Humidity: ${reading.humidity}%');
    
    final thresholds = await getThresholds();
    print(' Thresholds loaded: $thresholds');
    
    final notifications = <Map<String, dynamic>>[];
    
    // Check temperature
    if (reading.temperature < thresholds['temp_min']!) {
      print('! Temperature ${reading.temperature} is below minimum ${thresholds['temp_min']}');
      notifications.add({
        'title': ' Low Temperature Alert',
        'body': 'Temperature is ${reading.temperature.toStringAsFixed(1)}°C, below minimum ${thresholds['temp_min']}°C',
        'priority': 10,
      });
    } else if (reading.temperature > thresholds['temp_max']!) {
      print('! Temperature ${reading.temperature} is above maximum ${thresholds['temp_max']}');
      notifications.add({
        'title': ' High Temperature Alert',
        'body': 'Temperature is ${reading.temperature.toStringAsFixed(1)}°C, above maximum ${thresholds['temp_max']}°C',
        'priority': 10,
      });
    }
    
    // Check soil moisture
    final moisturePercent = reading.soilMoisture.toDouble();
    if (moisturePercent < thresholds['moisture_min']!) {
      print('! Moisture ${moisturePercent} is below minimum ${thresholds['moisture_min']}');
      notifications.add({
        'title': ' Low Soil Moisture Alert',
        'body': 'Soil moisture is ${moisturePercent.toStringAsFixed(1)}%, your plant needs water!',
        'priority': 10,
      });
    } else if (moisturePercent > thresholds['moisture_max']!) {
      print('! Moisture ${moisturePercent} is above maximum ${thresholds['moisture_max']}');
      notifications.add({
        'title': ' High Soil Moisture Alert',
        'body': 'Soil moisture is ${moisturePercent.toStringAsFixed(1)}%, might be overwatered!',
        'priority': 8,
      });
    }
    
    // Check light level
    if (reading.lightLevel < thresholds['light_min']!) {
      print('! Light ${reading.lightLevel} is below minimum ${thresholds['light_min']}');
      notifications.add({
        'title': ' Low Light Alert',
        'body': 'Light level is ${reading.lightLevel.toStringAsFixed(0)} lux, your plant needs more light!',
        'priority': 7,
      });
    } else if (reading.lightLevel > thresholds['light_max']!) {
      print('! Light ${reading.lightLevel} is above maximum ${thresholds['light_max']}');
      notifications.add({
        'title': ' High Light Alert',
        'body': 'Light level is ${reading.lightLevel.toStringAsFixed(0)} lux, might be too bright!',
        'priority': 6,
      });
    }
    
    // Check humidity
    if (reading.humidity < thresholds['humidity_min']!) {
      print('! Humidity ${reading.humidity} is below minimum ${thresholds['humidity_min']}');
      notifications.add({
        'title': ' Low Humidity Alert',
        'body': 'Humidity is ${reading.humidity.toStringAsFixed(1)}%, below minimum ${thresholds['humidity_min']}%',
        'priority': 6,
      });
    } else if (reading.humidity > thresholds['humidity_max']!) {
      print('! Humidity ${reading.humidity} is above maximum ${thresholds['humidity_max']}');
      notifications.add({
        'title': ' High Humidity Alert',
        'body': 'Humidity is ${reading.humidity.toStringAsFixed(1)}%, above maximum ${thresholds['humidity_max']}%',
        'priority': 5,
      });
    }
    
    print(' Total notifications to send: ${notifications.length}');
    
    // Send notifications with rate limiting
    for (final notification in notifications) {
      await _sendNotificationWithRateLimit(notification);
    }
  }
  
  static final Map<String, DateTime> _lastNotificationTime = {};
  
  static Future<void> _sendNotificationWithRateLimit(Map<String, dynamic> notification) async {
    print(' _sendNotificationWithRateLimit called');
    
    final key = notification['title'] as String;
    final now = DateTime.now();
    
    // Check if we've sent a notification for this type in the last hour
    if (_lastNotificationTime.containsKey(key)) {
      final lastTime = _lastNotificationTime[key]!;
      if (now.difference(lastTime).inMinutes < 60) {
        print(' Rate limited: Already sent $key within the last hour');
        return;
      }
    }
    
    // Send the notification directly
    await sendNotification(
      notification['title'] as String,
      notification['body'] as String,
      priority: notification['priority'] as int,
    );
    
    // Update last notification time
    _lastNotificationTime[key] = now;
  }
  
  // Clear rate limits (useful for testing)
  static Future<void> clearRateLimits() async {
    _lastNotificationTime.clear();
    print(' Rate limits cleared');
  }
  
  // Send notification directly using OneSignal REST API
  static Future<void> sendNotification(
    String title,
    String body, {
    int priority = 5,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print(' Attempting to send notification...');
      print('   Title: $title');
      print('   Body: $body');
      
      // Check if REST API key is set
      if (restApiKey == 'YOUR_ACTUAL_REST_API_KEY_HERE') {
        print(' REST API Key not set! Please update restApiKey in notification_service.dart');
        return;
      }
      
      // Get the player ID
      final playerId = await getPlayerId();
      
      if (playerId == null || playerId.isEmpty) {
        print(' No player ID available. Cannot send notification.');
        print('   Make sure OneSignal is properly initialized and the app has notification permissions.');
        return;
      }
      
      print(' Sending to Player ID: $playerId');
      
      // Prepare the notification payload
      final payload = {
        'app_id': appId,
        'include_player_ids': [playerId],
        'contents': {'en': body},
        'headings': {'en': title},
        'data': additionalData ?? {},
        'android_accent_color': 'FF4CAF50',
        'priority': priority,
      };
      
      print(' Payload: ${jsonEncode(payload)}');
      
      // Send notification using REST API
      final response = await http.post(
        Uri.parse(oneSignalApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $restApiKey',
        },
        body: jsonEncode(payload),
      );
      
      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(' Notification sent successfully');
        print('   Recipients: ${responseData['recipients'] ?? 'unknown'}');
        print('   ID: ${responseData['id'] ?? 'unknown'}');
      } else {
        print(' Failed to send notification');
        print('   Status: ${response.statusCode}');
        print('   Error: ${response.body}');
        
        // Try to parse error details
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['errors'] != null) {
            print('   Error details: ${errorData['errors']}');
          }
        } catch (e) {
          print('   Could not parse error response');
        }
      }
      
    } catch (e) {
      print(' Exception while sending notification: $e');
    }
  }
  
  // Send test notification
  static Future<void> sendTestNotification() async {
    print(' Sending test notification...');
    
    // Clear rate limits for testing
    await clearRateLimits();
    
    await sendNotification(
      ' Test Notification',
      'Your plant monitoring system is working correctly! Time: ${DateTime.now().toString().substring(11, 19)}',
      additionalData: {'type': 'test'},
    );
  }
  
  // Debug method to check OneSignal status
  static Future<void> debugOneSignalStatus() async {
    print(' OneSignal Debug Status:');
    
    try {
      final playerId = await getPlayerId();
      print('   Player ID: $playerId');
      
      final hasPermission = await OneSignal.Notifications.permission;
      print('   Has Permission: $hasPermission');
      
      final isSubscribed = OneSignal.User.pushSubscription.optedIn;
      print('   Is Subscribed: $isSubscribed');
      
      final subscriptionId = OneSignal.User.pushSubscription.id;
      print('   Subscription ID: $subscriptionId');
      
      final token = OneSignal.User.pushSubscription.token;
      print('   Push Token: ${token?.substring(0, 20)}...' ?? 'null');
      
      print('   App ID: $appId');
      print('   REST API Key Set: ${restApiKey != 'YOUR_ACTUAL_REST_API_KEY_HERE'}');
      
    } catch (e) {
      print(' Error checking OneSignal status: $e');
    }
  }
}