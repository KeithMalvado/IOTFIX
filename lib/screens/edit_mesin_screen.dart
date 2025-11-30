import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';

class EditMesinScreen extends StatefulWidget {
  final DeviceModel device;
  const EditMesinScreen({super.key, required this.device});

  @override
  State<EditMesinScreen> createState() => _EditMesinScreenState();
}

class _EditMesinScreenState extends State<EditMesinScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController brokerC;
  late TextEditingController userC;
  late TextEditingController passC;
  late TextEditingController topicC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.device.name);
    brokerC = TextEditingController(text: widget.device.broker);
    userC = TextEditingController(text: widget.device.username);
    passC = TextEditingController(text: widget.device.password);
    topicC = TextEditingController(text: widget.device.topic);
  }

  @override
  void dispose() {
    nameC.dispose();
    brokerC.dispose();
    userC.dispose();
    passC.dispose();
    topicC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = Provider.of<DeviceProvider>(context, listen: false);
    final updated = DeviceModel(
      id: widget.device.id,
      name: nameC.text,
      broker: brokerC.text,
      username: userC.text,
      password: passC.text,
      topic: topicC.text,
      isOn: widget.device.isOn,
      lastTemp: widget.device.lastTemp,
      lastSeen: widget.device.lastSeen,
    );

    await prov.firestore.updateDevice(updated);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mesin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama Mesin'),
                validator: (v) => v == null || v.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: brokerC,
                decoration: const InputDecoration(labelText: 'Broker MQTT'),
              ),
              TextFormField(
                controller: userC,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                controller: topicC,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _save, child: const Text('Simpan Perubahan')),
            ],
          ),
        ),
      ),
    );
  }
}
