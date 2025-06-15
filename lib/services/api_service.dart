import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your Flask server URL
  static const String baseUrl = 'http://192.168.1.4:5000';
  
  static Future<Map<String, dynamic>> analyzePlantImage(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      
      // Make API request
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
}