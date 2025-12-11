import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../constants/colors.dart';

// DEPRECATED: File ini tidak dipakai lagi di HomeScreen yang baru
// Disimpan untuk backward compatibility

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text(device.name),
        subtitle: Text(
            'Temp: ${device.airTemperature} °C | Humidity: ${device.airHumidity}%'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(device.relayStatus ? Icons.power : Icons.power_off,
                  color:
                      device.relayStatus ? AppColors.lightBlue : Colors.grey),
              onPressed: onToggle,
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
                if (v == 'detail') onDetail();
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'detail', child: Text('Lihat Detail')),
                PopupMenuItem(value: 'edit', child: Text('Edit Mesin')),
                PopupMenuItem(value: 'delete', child: Text('Hapus Mesin')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
