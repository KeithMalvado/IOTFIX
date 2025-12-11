import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/sensor_reading_model.dart';
import '../services/firestore_service.dart';
import '../services/mqtt_service.dart';

class DeviceProvider extends ChangeNotifier {
  final FirestoreService firestore = FirestoreService();
  final MqttManager mqttManager = MqttManager.instance;

  List<DeviceModel> devices = [];
  StreamSubscription? _fireSub;
  StreamSubscription? _mqttSub;

  // Throttle untuk prevent terlalu banyak write ke Firestore
  final Map<String, DateTime> _lastSaveTime = {};
  final Duration _saveInterval = const Duration(
    seconds: 30,
  ); // Save setiap 30 detik

  void startListen() {
    _fireSub = firestore.streamDevices().listen((list) {
      devices = list;

      // Auto connect & subscribe to all device topics
      for (var device in devices) {
        _connectAndSubscribe(device);
      }

      notifyListeners();
    });

    // Listen to MQTT messages
    _mqttSub = mqttManager.messagesStream.listen((msg) {
      _handleMqttMessage(msg);
    });
  }

  Future<void> _connectAndSubscribe(DeviceModel device) async {
    try {
      await mqttManager.connectIfNeeded(
        broker: device.broker,
        clientId: 'flutter-${device.id}',
        username: device.username,
        password: device.password,
      );

      // Subscribe to all sensor topics
      mqttManager.subscribe(device.topicSoil, broker: device.broker);
      mqttManager.subscribe(device.topicTemp, broker: device.broker);
      mqttManager.subscribe(device.topicHumidity, broker: device.broker);
      mqttManager.subscribe(device.topicLampStatus, broker: device.broker);
      mqttManager.subscribe(device.topicPumpStatus, broker: device.broker);
    } catch (e) {
      print('MQTT connect/subscribe error: $e');
    }
  }

  void _handleMqttMessage(MqttMessage msg) {
    for (int i = 0; i < devices.length; i++) {
      final device = devices[i];
      DeviceModel? updatedDevice;

      // Match topic and update corresponding sensor value
      if (msg.topic == device.topicSoil) {
        final value = _extractNumber(msg.payload);
        if (value != null) {
          updatedDevice = device.copyWith(
            soilMoisture: value,
            lastSeen: DateTime.now(),
          );
        }
      } else if (msg.topic == device.topicTemp) {
        final value = _extractNumber(msg.payload);
        if (value != null) {
          updatedDevice = device.copyWith(
            airTemperature: value,
            lastSeen: DateTime.now(),
          );
        }
      } else if (msg.topic == device.topicHumidity) {
        final value = _extractNumber(msg.payload);
        if (value != null) {
          updatedDevice = device.copyWith(
            airHumidity: value,
            lastSeen: DateTime.now(),
          );
        }
      } else if (msg.topic == device.topicLampStatus) {
        // Handle lamp status: ON, OFF, on, off
        final payload = msg.payload.toUpperCase().trim();
        if (payload == 'ON' || payload == '1') {
          updatedDevice = device.copyWith(
            lampStatus: true,
            lastSeen: DateTime.now(),
          );
        } else if (payload == 'OFF' || payload == '0') {
          updatedDevice = device.copyWith(
            lampStatus: false,
            lastSeen: DateTime.now(),
          );
        }
      } else if (msg.topic == device.topicPumpStatus) {
        // Handle pump status: ON, OFF, on, off
        final payload = msg.payload.toUpperCase().trim();
        if (payload == 'ON' || payload == '1') {
          updatedDevice = device.copyWith(
            pumpStatus: true,
            lastSeen: DateTime.now(),
          );
        } else if (payload == 'OFF' || payload == '0') {
          updatedDevice = device.copyWith(
            pumpStatus: false,
            lastSeen: DateTime.now(),
          );
        }
      }

      if (updatedDevice != null) {
        devices[i] = updatedDevice;

        // Update Firestore device status
        firestore.devices.doc(updatedDevice.id).update({
          'soilMoisture': updatedDevice.soilMoisture,
          'airTemperature': updatedDevice.airTemperature,
          'airHumidity': updatedDevice.airHumidity,
          'lampStatus': updatedDevice.lampStatus,
          'pumpStatus': updatedDevice.pumpStatus,
          'lastSeen': updatedDevice.lastSeen.toIso8601String(),
        });

        // Save to history (with throttle to prevent too many writes)
        _saveSensorReadingThrottled(updatedDevice);

        notifyListeners();
      }
    }
  }

  void _saveSensorReadingThrottled(DeviceModel device) {
    final now = DateTime.now();
    final lastSave = _lastSaveTime[device.id];

    // Only save if enough time has passed since last save
    if (lastSave == null || now.difference(lastSave) >= _saveInterval) {
      _lastSaveTime[device.id] = now;

      final reading = SensorReading(
        id: '',
        deviceId: device.id,
        airTemperature: device.airTemperature,
        airHumidity: device.airHumidity,
        soilMoisture: device.soilMoisture,
        timestamp: now,
      );

      firestore.saveSensorReading(reading).catchError((e) {
        print('Error saving sensor reading: $e');
      });
    }
  }

  double? _extractNumber(String payload) {
    try {
      return double.parse(payload.trim());
    } catch (_) {}
    try {
      final reg = RegExp(r'(-?\d+(\.\d+)?)');
      final m = reg.firstMatch(payload);
      if (m != null) return double.parse(m.group(0)!);
    } catch (_) {}
    return null;
  }

  Future<void> toggleLamp(DeviceModel device) async {
    final newStatus = !device.lampStatus;

    try {
      await mqttManager.connectIfNeeded(
        broker: device.broker,
        clientId: 'flutter-${device.id}',
        username: device.username,
        password: device.password,
      );

      final command = newStatus ? 'on' : 'off';
      await mqttManager.publish(
        device.topicLampControl,
        command,
        broker: device.broker,
      );

      // Update local state
      final index = devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        devices[index] = device.copyWith(lampStatus: newStatus);
        await firestore.updateDevice(devices[index]);
        notifyListeners();
      }
    } catch (e) {
      print('MQTT publish error (lamp): $e');
    }
  }

  Future<void> togglePump(DeviceModel device) async {
    final newStatus = !device.pumpStatus;

    try {
      await mqttManager.connectIfNeeded(
        broker: device.broker,
        clientId: 'flutter-${device.id}',
        username: device.username,
        password: device.password,
      );

      final command = newStatus ? 'on' : 'off';
      await mqttManager.publish(
        device.topicPumpControl,
        command,
        broker: device.broker,
      );

      // Update local state
      final index = devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        devices[index] = device.copyWith(pumpStatus: newStatus);
        await firestore.updateDevice(devices[index]);
        notifyListeners();
      }
    } catch (e) {
      print('MQTT publish error (pump): $e');
    }
  }

  @override
  void dispose() {
    _fireSub?.cancel();
    _mqttSub?.cancel();
    super.dispose();
  }
}
