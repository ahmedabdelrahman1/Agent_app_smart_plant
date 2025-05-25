class PlantDiagnosis {
  final DateTime timestamp;
  final String diseaseName;
  final double confidence;
  final double healthScore;
  final List<String> recommendations;
  final String imageUrl;
  
  PlantDiagnosis({
    required this.timestamp,
    required this.diseaseName,
    required this.confidence,
    required this.healthScore,
    required this.recommendations,
    required this.imageUrl,
  });
  
  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'healthScore': healthScore,
      'recommendations': recommendations,
      'imageUrl': imageUrl,
    };
  }
  
  // Create from Map for database retrieval
  factory PlantDiagnosis.fromMap(Map<String, dynamic> map) {
    return PlantDiagnosis(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      diseaseName: map['diseaseName'],
      confidence: map['confidence'],
      healthScore: map['healthScore'],
      recommendations: List<String>.from(map['recommendations']),
      imageUrl: map['imageUrl'],
    );
  }
}