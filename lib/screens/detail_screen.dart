import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/mqtt_service.dart';
import 'edit_mesin_screen.dart';

class DetailScreen extends StatefulWidget {
  final DeviceModel device;
  const DetailScreen({super.key, required this.device});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  StreamSubscription<MqttMessage>? _sub;
  double? currentTemp;
  String lastPayload = '';
  bool subscribed = false;

  @override
  void initState() {
    super.initState();
    currentTemp = widget.device.lastTemp;
    _connectAndSubscribe();
  }

  Future<void> _connectAndSubscribe() async {
    final mgr = MqttManager.instance;
    try {
      await mgr.connectIfNeeded(
        broker: widget.device.broker,
        clientId:
            'detail-${widget.device.id}-${DateTime.now().millisecondsSinceEpoch}',
        username: widget.device.username,
        password: widget.device.password,
      );
      mgr.subscribe(widget.device.topic);
      _sub = mgr.messagesStream.listen((msg) {
        if (msg.topic == widget.device.topic) {
          setState(() {
            lastPayload = msg.payload;
            final parsed = _extractTemp(lastPayload);
            if (parsed != null) currentTemp = parsed;
          });
          FirebaseFirestore.instance.collection('readings').add({
            'deviceId': widget.device.id,
            'temperature': currentTemp ?? 0,
            'payload': lastPayload,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      });
      setState(() => subscribed = true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('MQTT error: $e')));
      }
    }
  }

  double? _extractTemp(String payload) {
    try {
      final p = double.parse(payload);
      return p;
    } catch (_) {}
    try {
      final reg = RegExp(r'(-?\d+(\.\d+)?)');
      final m = reg.firstMatch(payload);
      if (m != null) return double.parse(m.group(0)!);
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    MqttManager.instance.unsubscribe(widget.device.topic);
    super.dispose();
  }

  Future<void> _togglePower() async {
    final mgr = MqttManager.instance;
    final cmd = widget.device.isOn ? 'POWER_OFF' : 'POWER_ON';
    try {
      await mgr.publish(widget.device.topic, cmd);
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(widget.device.id)
          .update({
        'isOn': !widget.device.isOn,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Publish error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText =
        currentTemp == null ? '—' : '${currentTemp!.toStringAsFixed(1)} °C';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMesinScreen(device: widget.device),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading:
                    const Icon(Icons.thermostat_outlined, color: Colors.red),
                title: const Text('Suhu Sekarang'),
                subtitle: Text(statusText,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Last Payload'),
                subtitle:
                    Text(lastPayload.isEmpty ? 'Belum ada pesan' : lastPayload),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Toggle Power'),
              onPressed: _togglePower,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(subscribed ? Icons.pause_circle : Icons.play_circle),
              label: Text(subscribed ? 'Unsubscribe' : 'Subscribe'),
              onPressed: () {
                if (!subscribed) {
                  _connectAndSubscribe();
                } else {
                  MqttManager.instance.unsubscribe(widget.device.topic);
                  _sub?.cancel();
                  setState(() {
                    subscribed = false;
                    lastPayload = '';
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Riwayat singkat (terbaru)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('readings')
                    .where('deviceId', isEqualTo: widget.device.id)
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty)
                    return const Center(child: Text('Belum ada riwayat'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final t =
                          d['temperature']?.toString() ?? d['payload'] ?? '—';
                      final ts = d['timestamp'] ?? '';
                      return ListTile(
                        dense: true,
                        title: Text('$t °C'),
                        subtitle: Text(ts.toString()),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
