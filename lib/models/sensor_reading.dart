// lib/models/sensor_reading.dart
class SensorReading {
  final int id;
  final double temperature;
  final double humidity;
  final int soilMoisture;
  final int lightLevel;
  final bool pumpStatus;
  final DateTime insertedAt;

  SensorReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightLevel,
    required this.pumpStatus,
    required this.insertedAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      soilMoisture: json['soil_moisture'],
      lightLevel: json['light_level'],
      pumpStatus: json['pump_status'],
      insertedAt: DateTime.parse(json['inserted_at']),
    );
  }
}