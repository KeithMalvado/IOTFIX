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

  final TextEditingController nameC = TextEditingController();
  final TextEditingController brokerC =
      TextEditingController(text: "rust.bianisme.xyz");
  final TextEditingController userC = TextEditingController(text: "fabian");
  final TextEditingController passC = TextEditingController(text: "010105");
  final TextEditingController topicC =
      TextEditingController(text: "iot/device/temp");

  @override
  void dispose() {
    nameC.dispose();
    brokerC.dispose();
    userC.dispose();
    passC.dispose();
    topicC.dispose();
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
        topic: topicC.text,
      );

      await prov.firestore.addDevice(newDevice);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mesin berhasil ditambahkan!'),
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
      appBar: AppBar(title: const Text("Tambah Mesin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: "Nama Mesin",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Nama mesin harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: brokerC,
                decoration: const InputDecoration(
                  labelText: "Broker MQTT",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Broker harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: userC,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Username harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Password harus diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: topicC,
                decoration: const InputDecoration(
                  labelText: "Topic",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Topic harus diisi" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDevice,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
