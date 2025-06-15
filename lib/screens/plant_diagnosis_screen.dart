import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class PlantDiagnosisScreen extends StatefulWidget {
  final File imageFile;
  
  const PlantDiagnosisScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _PlantDiagnosisScreenState createState() => _PlantDiagnosisScreenState();
}

class _PlantDiagnosisScreenState extends State<PlantDiagnosisScreen> {
  bool _isAnalyzing = true;
  String _diagnosisResult = '';
  List<String> _recommendations = [];
  double _healthScore = 0.0;
  String _diseaseConfidence = '';
  String? _errorMessage;
  final supabase = Supabase.instance.client;
  
  @override
  void initState() {
    super.initState();
    _analyzePlant();
  }
  
  Future<void> _analyzePlant() async {
  try {
    print('Starting plant analysis...');
    print('Image file: ${widget.imageFile.path}');
    
    // Call the Flask API
    final result = await ApiService.analyzePlantImage(widget.imageFile);
    
    print('API Result: $result');
    
    if (result['success'] == true) {
      setState(() {
        _isAnalyzing = false;
        _diagnosisResult = result['disease'];
        _healthScore = result['health_score'].toDouble();
        _diseaseConfidence = result['confidence'];
        _recommendations = List<String>.from(result['recommendations']);
      });
    } else {
      throw Exception(result['error'] ?? 'Analysis failed');
    }
  } catch (e) {
    print('Error in _analyzePlant: $e');
    setState(() {
      _isAnalyzing = false;
      _errorMessage = e.toString();
    });
  }
}
  
  Future<void> _saveDiagnosisToSupabase() async {
    try {
      await supabase.from('diagnoses').insert({
                'disease_name': _diagnosisResult,
        'confidence': _diseaseConfidence,
        'health_score': _healthScore,
        'recommendations': _recommendations,
        'analyzed_at': DateTime.now().toIso8601String(),
        'user_id': supabase.auth.currentUser?.id,
      });
    } catch (e) {
      print('Error saving to Supabase: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Health Analysis'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Analysis Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
          : _isAnalyzing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16.0),
                      Text('Analyzing plant leaf...',
                          style: TextStyle(fontSize: 16.0)),
                      SizedBox(height: 8.0),
                      Text('Our AI is checking for signs of disease',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.0),
                      
                      // Diagnosis result
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'DIAGNOSIS RESULT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _diagnosisResult,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: _diagnosisResult == 'Healthy' 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Confidence: $_diseaseConfidence',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.0),
                      
                      // Health score
                      Card(
                        elevation: 2.0,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Plant Health Score',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              LinearProgressIndicator(
                                value: _healthScore / 100,
                                minHeight: 15,
                                backgroundColor: Colors.red[100],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _healthScore > 80
                                      ? Colors.green
                                      : _healthScore > 60
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '${_healthScore.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: _healthScore > 80
                                      ? Colors.green
                                      : _healthScore > 60
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.0),
                      
                      // Recommendations
                      Text(
                        'RECOMMENDATIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ...List.generate(
                        _recommendations.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 5.0),
                                height: 8.0,
                                width: 8.0,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(_recommendations[index]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.0),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.refresh),
                              label: Text('Scan Again'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.book),
                              label: Text('Learn More'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Disease Information'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _diagnosisResult,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'This disease affects plant health by damaging leaf tissue and reducing photosynthesis.',
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Prevention Tips:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text('• Maintain proper plant spacing'),
                                          Text('• Water at the base of plants'),
                                          Text('• Remove infected material promptly'),
                                          Text('• Use disease-resistant varieties'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}