class SensorReading {
  final DateTime timestamp;
  final double value;
  final String sensorType;
  final String unit;
  
  SensorReading({
    required this.timestamp,
    required this.value,
    required this.sensorType,
    required this.unit,
  });
  
  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'value': value,
      'sensorType': sensorType,
      'unit': unit,
    };
  }
  
  // Create from Map for database retrieval
  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      value: map['value'],
      sensorType: map['sensorType'],
      unit: map['unit'],
    );
  }
}