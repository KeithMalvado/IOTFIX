import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';

class FirestoreService {
  final CollectionReference devices =
      FirebaseFirestore.instance.collection('devices');

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
}
