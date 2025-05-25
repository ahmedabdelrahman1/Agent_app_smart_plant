import 'package:flutter/material.dart';
import 'dart:io';

class PlantDiagnosisScreen extends StatefulWidget {
  final File? imageFile;
  
  const PlantDiagnosisScreen({Key? key, this.imageFile}) : super(key: key);

  @override
  _PlantDiagnosisScreenState createState() => _PlantDiagnosisScreenState();
}

class _PlantDiagnosisScreenState extends State<PlantDiagnosisScreen> {
  bool _isAnalyzing = true;
  String _diagnosisResult = '';
  List<String> _recommendations = [];
  double _healthScore = 0.0;
  String _diseaseConfidence = '';
  
  @override
  void initState() {
    super.initState();
    _analyzePlant();
  }
  
  Future<void> _analyzePlant() async {
    // Simulate AI analysis
    await Future.delayed(Duration(seconds: 3));
    
    // In a real app, you would send the image to your AI model
    // and receive the analysis results
    setState(() {
      _isAnalyzing = false;
      _diagnosisResult = 'Leaf Spot Disease';
      _healthScore = 65.0;
      _diseaseConfidence = '87%';
      _recommendations = [
        'Remove affected leaves and dispose of them properly',
        'Apply fungicide treatment according to package instructions',
        'Ensure proper air circulation around plants',
        'Avoid overhead watering to prevent moisture on leaves',
        'Consider increasing plant spacing to avoid disease spread'
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Health Analysis'),
      ),
      body: _isAnalyzing
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
                      child: widget.imageFile != null
                          ? Image.file(
                              widget.imageFile!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey[600],
                              ),
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
                            color: Colors.red[700],
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
                            // Navigate to a detailed information page about the disease
                            // or open a web link with more information
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Disease Information'),
                                content: Text(
                                    'This would link to detailed information about $_diagnosisResult, including causes, treatments, and prevention methods.'),
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