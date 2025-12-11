class SensorReading {
  String id;
  String deviceId;
  double airTemperature;
  double airHumidity;
  double soilMoisture;
  DateTime timestamp;

  SensorReading({
    required this.id,
    required this.deviceId,
    required this.airTemperature,
    required this.airHumidity,
    required this.soilMoisture,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'airTemperature': airTemperature,
        'airHumidity': airHumidity,
        'soilMoisture': soilMoisture,
        'timestamp': timestamp.toIso8601String(),
      };

  static SensorReading fromJson(String id, Map<String, dynamic> json) {
    return SensorReading(
      id: id,
      deviceId: json['deviceId'] ?? '',
      airTemperature: (json['airTemperature'] ?? 0).toDouble(),
      airHumidity: (json['airHumidity'] ?? 0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
