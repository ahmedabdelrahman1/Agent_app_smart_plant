import 'package:flutter/material.dart';
import 'dart:io';
import 'plant_diagnosis_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  bool _processingImage = false;
  
  // This would use a camera plugin in a real app
  Future<void> _takePicture() async {
    // Simulating camera capture
    setState(() {
      _processingImage = true;
    });
    
    await Future.delayed(Duration(seconds: 2));
    
    // In a real app, this would use a camera plugin to take a picture
    setState(() {
      _processingImage = false;
      // _imageFile would be set to the captured image
    });
    
    // For demo purposes, let's pretend we took a picture and navigate to the diagnosis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDiagnosisScreen(imageFile: null),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Diagnosis'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: _processingImage
                    ? CircularProgressIndicator()
                    : Text(
                        'Camera Preview',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Take a clear picture of your plant leaf to analyze its health status.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text('Capture Leaf Image'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: _processingImage ? null : _takePicture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}