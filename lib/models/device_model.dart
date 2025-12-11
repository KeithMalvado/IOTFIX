class DeviceModel {
  String id;
  String name;
  String broker;
  String username;
  String password;

  // MQTT Topics
  String topicSoil; // sensor/soil
  String topicTemp; // sensor/suhu
  String topicHumidity; // sensor/kelembapan
  String topicLampControl; // kontrol/relay2 (lampu)
  String topicLampStatus; // status/relay2 (lampu)
  String topicPumpControl; // kontrol/relay (pompa)
  String topicPumpStatus; // status/relay (pompa)
  String topicModeControl; // kontrol/mode
  String topicModeStatus; // status/mode

  // Sensor Data
  double soilMoisture; // Kelembapan tanah (%)
  double airTemperature; // Suhu udara (°C)
  double airHumidity; // Kelembapan udara (%)
  bool lampStatus; // Status lampu (ON/OFF)
  bool pumpStatus; // Status pompa (ON/OFF)
  String pumpMode; // Mode pompa: "manual" atau "auto"

  DateTime lastSeen;

  DeviceModel({
    required this.id,
    required this.name,
    required this.broker,
    required this.username,
    required this.password,
    this.topicSoil = 'sensor/soil',
    this.topicTemp = 'sensor/suhu',
    this.topicHumidity = 'sensor/kelembapan',
    this.topicLampControl = 'kontrol/relay2',
    this.topicLampStatus = 'status/relay2',
    this.topicPumpControl = 'kontrol/relay',
    this.topicPumpStatus = 'status/relay',
    this.topicModeControl = 'kontrol/mode',
    this.topicModeStatus = 'status/mode',
    this.soilMoisture = 0,
    this.airTemperature = 0,
    this.airHumidity = 0,
    this.lampStatus = false,
    this.pumpStatus = false,
    this.pumpMode = 'manual',
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  // Helper method untuk cek status online
  bool get isOnline {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    // Device dianggap online jika ada update dalam 60 detik terakhir
    return difference.inSeconds < 60;
  }

  // CopyWith method untuk update state
  DeviceModel copyWith({
    String? name,
    String? broker,
    String? username,
    String? password,
    String? topicSoil,
    String? topicTemp,
    String? topicHumidity,
    String? topicLampControl,
    String? topicLampStatus,
    String? topicPumpControl,
    String? topicPumpStatus,
    String? topicModeControl,
    String? topicModeStatus,
    double? soilMoisture,
    double? airTemperature,
    double? airHumidity,
    bool? lampStatus,
    bool? pumpStatus,
    String? pumpMode,
    DateTime? lastSeen,
  }) {
    return DeviceModel(
      id: id,
      name: name ?? this.name,
      broker: broker ?? this.broker,
      username: username ?? this.username,
      password: password ?? this.password,
      topicSoil: topicSoil ?? this.topicSoil,
      topicTemp: topicTemp ?? this.topicTemp,
      topicHumidity: topicHumidity ?? this.topicHumidity,
      topicLampControl: topicLampControl ?? this.topicLampControl,
      topicLampStatus: topicLampStatus ?? this.topicLampStatus,
      topicPumpControl: topicPumpControl ?? this.topicPumpControl,
      topicPumpStatus: topicPumpStatus ?? this.topicPumpStatus,
      topicModeControl: topicModeControl ?? this.topicModeControl,
      topicModeStatus: topicModeStatus ?? this.topicModeStatus,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      airTemperature: airTemperature ?? this.airTemperature,
      airHumidity: airHumidity ?? this.airHumidity,
      lampStatus: lampStatus ?? this.lampStatus,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      pumpMode: pumpMode ?? this.pumpMode,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'broker': broker,
        'username': username,
        'password': password,
        'topicSoil': topicSoil,
        'topicTemp': topicTemp,
        'topicHumidity': topicHumidity,
        'topicLampControl': topicLampControl,
        'topicLampStatus': topicLampStatus,
        'topicPumpControl': topicPumpControl,
        'topicPumpStatus': topicPumpStatus,
        'topicModeControl': topicModeControl,
        'topicModeStatus': topicModeStatus,
        'soilMoisture': soilMoisture,
        'airTemperature': airTemperature,
        'airHumidity': airHumidity,
        'lampStatus': lampStatus,
        'pumpStatus': pumpStatus,
        'pumpMode': pumpMode,
        'lastSeen': lastSeen.toIso8601String(),
      };

  static DeviceModel fromJson(String id, Map<String, dynamic> json) {
    return DeviceModel(
      id: id,
      name: json['name'] ?? 'Smart Garden System',
      broker: json['broker'] ?? 'broker.hivemq.com',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      topicSoil: json['topicSoil'] ?? 'sensor/soil',
      topicTemp: json['topicTemp'] ?? 'sensor/suhu',
      topicHumidity: json['topicHumidity'] ?? 'sensor/kelembapan',
      topicLampControl: json['topicLampControl'] ?? 'kontrol/relay2',
      topicLampStatus: json['topicLampStatus'] ?? 'status/relay2',
      topicPumpControl: json['topicPumpControl'] ?? 'kontrol/relay',
      topicPumpStatus: json['topicPumpStatus'] ?? 'status/relay',
      topicModeControl: json['topicModeControl'] ?? 'kontrol/mode',
      topicModeStatus: json['topicModeStatus'] ?? 'status/mode',
      soilMoisture: (json['soilMoisture'] ?? 0).toDouble(),
      airTemperature: (json['airTemperature'] ?? 0).toDouble(),
      airHumidity: (json['airHumidity'] ?? 0).toDouble(),
      lampStatus: json['lampStatus'] ?? false,
      pumpStatus: json['pumpStatus'] ?? false,
      pumpMode: json['pumpMode'] ?? 'manual',
      lastSeen: DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now(),
    );
  }
}
