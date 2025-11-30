import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/firestore_service.dart';
import '../services/mqtt_service.dart';

class DeviceProvider extends ChangeNotifier {
  final FirestoreService firestore = FirestoreService();
  final MqttManager mqttManager = MqttManager.instance;

  List<DeviceModel> devices = [];
  StreamSubscription? _fireSub;
  StreamSubscription? _mqttSub;

  void startListen() {
    _fireSub = firestore.streamDevices().listen((list) {
      devices = list;
      notifyListeners();
    });

    // listen global MQTT messages and update devices list if topic matches
    _mqttSub = mqttManager.messagesStream.listen((msg) {
      // simple matching: find device whose topic equals msg.topic or wildcard
      for (var d in devices) {
        if (d.topic == msg.topic) {
          final parsed = _extractTemp(msg.payload);
          if (parsed != null) {
            d.lastTemp = parsed;
            d.lastSeen = DateTime.now();
            // optionally push change to firestore lastTemp/lastSeen
            firestore.devices.doc(d.id).update({
              'lastTemp': d.lastTemp,
              'lastSeen': d.lastSeen.toIso8601String(),
            });
            notifyListeners();
          }
        }
      }
    });
  }

  double? _extractTemp(String payload) {
    try {
      return double.parse(payload);
    } catch (_) {}
    try {
      final reg = RegExp(r'(-?\d+(\.\d+)?)');
      final m = reg.firstMatch(payload);
      if (m != null) return double.parse(m.group(0)!);
    } catch (_) {}
    return null;
  }

  Future<void> toggleDevice(DeviceModel d) async {
    d.isOn = !d.isOn;
    await firestore.updateDevice(d);
    try {
      await mqttManager.connectIfNeeded(
        broker: d.broker,
        clientId: 'provider-${d.id}',
        username: d.username,
        password: d.password,
      );
      final cmd = d.isOn ? 'POWER_ON' : 'POWER_OFF';
      await mqttManager.publish(d.topic, cmd, broker: d.broker);
    } catch (e) {
      print('MQTT publish error: $e');
    }
  }

  @override
  void dispose() {
    _fireSub?.cancel();
    _mqttSub?.cancel();
    super.dispose();
  }
}
