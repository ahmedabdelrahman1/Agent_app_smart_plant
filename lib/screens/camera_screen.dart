import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'plant_diagnosis_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  bool _processingImage = false;
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;
  
  Future<void> _takePicture() async {
    try {
      setState(() {
        _processingImage = true;
      });
      
      // Capture image using camera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (photo != null) {
        _imageFile = File(photo.path);
        
        // Upload to Supabase Storage
        await _uploadToSupabase();
        
        // Navigate to diagnosis screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDiagnosisScreen(imageFile: _imageFile!),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _processingImage = false;
      });
    }
  }
  
  Future<void> _uploadToSupabase() async {
  if (_imageFile == null) return;
  
  try {
    final fileName = 'plant_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await _imageFile!.readAsBytes();
    
    // Upload to Supabase Storage - This is working fine
    final String path = await supabase.storage
        .from('plant-images')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
    
    // Skip the database insert - just log the URL
    final String imageUrl = supabase.storage
        .from('plant-images')
        .getPublicUrl(fileName);
    
    print('Image uploaded successfully: $imageUrl');
    
    // Don't try to insert into database - table doesn't exist
    // Just continue to the diagnosis screen
    
  } catch (e) {
    print('Error uploading to Supabase: $e');
    // Don't throw - continue anyway
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Diagnosis'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: _processingImage
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Camera Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Take a clear picture of your plant leaf to analyze its health status.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera, size: 24),
                  label: Text(
                    'Capture Leaf Image',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _processingImage ? null : _takePicture,
                ),
                SizedBox(height: 10.0),
                TextButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Choose from Gallery'),
                  onPressed: _processingImage ? null : _pickFromGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _processingImage = true;
      });
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        _imageFile = File(image.path);
        
        // Upload to Supabase Storage
        await _uploadToSupabase();
        
        // Navigate to diagnosis screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDiagnosisScreen(imageFile: _imageFile!),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _processingImage = false;
      });
    }
  }
}