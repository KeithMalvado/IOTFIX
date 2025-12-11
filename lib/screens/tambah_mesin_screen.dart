import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';

class TambahMesinScreen extends StatefulWidget {
  const TambahMesinScreen({super.key});

  @override
  State<TambahMesinScreen> createState() => _TambahMesinScreenState();
}

class _TambahMesinScreenState extends State<TambahMesinScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController nameC =
      TextEditingController(text: "Smart Garden System");
  final TextEditingController brokerC =
      TextEditingController(text: "broker.hivemq.com");
  final TextEditingController userC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  @override
  void dispose() {
    nameC.dispose();
    brokerC.dispose();
    userC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validasi form gagal')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prov = Provider.of<DeviceProvider>(context, listen: false);
      final newDevice = DeviceModel(
        id: "",
        name: nameC.text,
        broker: brokerC.text,
        username: userC.text,
        password: passC.text,
      );

      await prov.firestore.addDevice(newDevice);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error saving device: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Device IoT"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text(
                'Konfigurasi MQTT Broker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: "Nama Device",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (v) => v!.isEmpty ? "Nama device harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: brokerC,
                decoration: const InputDecoration(
                  labelText: "Broker MQTT",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud),
                  hintText: "broker.hivemq.com",
                ),
                validator: (v) => v!.isEmpty ? "Broker harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: userC,
                decoration: const InputDecoration(
                  labelText: "Username (Opsional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(
                  labelText: "Password (Opsional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MQTT Topics (Default):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('• Suhu: sensor/suhu',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• Kelembapan Udara: sensor/kelembapan',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• Kelembapan Tanah: sensor/soil',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• Kontrol Relay: kontrol/relay',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• Status Relay: status/relay',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Simpan Device",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
