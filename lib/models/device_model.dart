class DeviceModel {
  String id;
  String name;
  String broker;
  String username;
  String password;
  String topic;
  bool isOn;
  double lastTemp;
  DateTime lastSeen;

  DeviceModel({
    required this.id,
    required this.name,
    required this.broker,
    required this.username,
    required this.password,
    required this.topic,
    this.isOn = false,
    this.lastTemp = 0,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'broker': broker,
        'username': username,
        'password': password,
        'topic': topic,
        'isOn': isOn,
        'lastTemp': lastTemp,
        'lastSeen': lastSeen.toIso8601String(),
      };

  static DeviceModel fromJson(String id, Map<String, dynamic> json) {
    return DeviceModel(
      id: id,
      name: json['name'] ?? 'Unnamed',
      broker: json['broker'] ?? 'rust.bianisme.xyz',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      topic: json['topic'] ?? 'iot/${id}/temp',
      isOn: json['isOn'] ?? false,
      lastTemp: (json['lastTemp'] ?? 0).toDouble(),
      lastSeen: DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now(),
    );
  }
}
