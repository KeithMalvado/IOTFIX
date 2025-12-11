import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';
import '../models/sensor_reading_model.dart';

class FirestoreService {
  final CollectionReference devices =
      FirebaseFirestore.instance.collection('devices');
  final CollectionReference sensorReadings =
      FirebaseFirestore.instance.collection('sensor_readings');

  Future<String> addDevice(DeviceModel device) async {
    final doc = await devices.add(device.toJson());
    return doc.id;
  }

  Future<void> updateDevice(DeviceModel device) async {
    await devices.doc(device.id).set(device.toJson());
  }

  Future<void> deleteDevice(String id) async {
    await devices.doc(id).delete();
  }

  Stream<List<DeviceModel>> streamDevices() {
    return devices.snapshots().map((snap) => snap.docs
        .map(
            (d) => DeviceModel.fromJson(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // Sensor History Methods
  Future<void> saveSensorReading(SensorReading reading) async {
    await sensorReadings.add(reading.toJson());
  }

  Stream<List<SensorReading>> streamSensorReadings(
    String deviceId, {
    int hours = 24,
  }) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));

    return sensorReadings
        .where('deviceId', isEqualTo: deviceId)
        .where('timestamp', isGreaterThan: cutoff.toIso8601String())
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                SensorReading.fromJson(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<SensorReading>> getSensorReadings(
    String deviceId, {
    int hours = 24,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));

    final snapshot = await sensorReadings
        .where('deviceId', isEqualTo: deviceId)
        .where('timestamp', isGreaterThan: cutoff.toIso8601String())
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs
        .map((d) =>
            SensorReading.fromJson(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  // Clean old data (optional - untuk performance)
  Future<void> cleanOldReadings({int daysToKeep = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysToKeep));

    final snapshot = await sensorReadings
        .where('timestamp', isLessThan: cutoff.toIso8601String())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
