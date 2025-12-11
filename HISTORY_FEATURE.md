# 📊 Fitur Data Historis - Smart Garden IoT

## ✅ Apa yang Sudah Dibuat

### 1. **Model SensorReading**

File: `lib/models/sensor_reading_model.dart`

- Menyimpan data sensor dengan timestamp
- Fields: `airTemperature`, `airHumidity`, `soilMoisture`, `timestamp`, `deviceId`

### 2. **FirestoreService Update**

File: `lib/services/firestore_service.dart`

**Fungsi Baru:**

- `saveSensorReading()` - Simpan reading ke Firestore
- `streamSensorReadings()` - Stream real-time data history (24 jam)
- `getSensorReadings()` - Get data history sekali
- `cleanOldReadings()` - Hapus data lama (opsional)

### 3. **DeviceProvider Auto-Logging**

File: `lib/providers/device_provider.dart`

**Fitur:**

- Auto save sensor data ke Firestore setiap 30 detik
- Throttling untuk prevent spam writes
- Setiap kali MQTT terima data → update device → simpan ke history

### 4. **HomeScreen Real-Time Chart**

File: `lib/screens/home_screen.dart`

**Update:**

- Grafik menggunakan `StreamBuilder` dengan data REAL dari Firestore
- Auto-update ketika ada data baru
- Menampilkan jumlah data points
- 3 line charts untuk: Suhu, Kelembapan Udara, Kelembapan Tanah

---

## 🚀 Cara Kerja

### Flow Data History:

```
ESP32 publish MQTT
     ↓
DeviceProvider terima message
     ↓
Update DeviceModel (nilai terbaru)
     ↓
Update Firestore devices collection
     ↓
Cek throttle (30 detik interval)
     ↓
Save ke sensor_readings collection
     ↓
StreamBuilder di UI otomatis update
     ↓
Chart refresh dengan data baru
```

### Struktur Data Firestore:

**Collection: sensor_readings**

```json
{
  "deviceId": "abc123",
  "airTemperature": 28.5,
  "airHumidity": 65.3,
  "soilMoisture": 45.2,
  "timestamp": "2025-12-01T10:30:00.000Z"
}
```

---

## 📝 Setup Firebase Index

**PENTING!** Anda perlu create composite index di Firebase:

1. Jalankan aplikasi
2. Tungil error muncul dengan link create index
3. Atau baca `FIREBASE_INDEX.md` untuk manual setup

---

## 🎯 Fitur Yang Sudah Jalan:

✅ Auto-save sensor data setiap 30 detik
✅ Query data 24 jam terakhir
✅ Real-time chart update via StreamBuilder  
✅ 3 sensor lines (temp, humidity air, humidity soil)
✅ Throttling untuk optimize Firestore writes
✅ Cleanup function untuk hapus data lama

---

## 🔧 Kustomisasi:

### Ubah interval save data:

```dart
// Di device_provider.dart, line ~16
final Duration _saveInterval = const Duration(seconds: 30);
// Ganti ke Duration(minutes: 1) atau sesuai kebutuhan
```

### Ubah periode grafik:

```dart
// Di home_screen.dart, saat panggil streamSensorReadings
streamSensorReadings(device.id, hours: 24)
// Ganti hours: 12 untuk 12 jam, atau hours: 48 untuk 2 hari
```

### Cleanup otomatis data lama:

```dart
// Tambahkan di DeviceProvider atau background task
await firestore.cleanOldReadings(daysToKeep: 7);
```

---

## 📊 Data Yang Ditampilkan:

**SensorCard (Real-time):**

- Nilai terakhir langsung dari MQTT
- Update instant setiap ESP32 publish

**Chart (History):**

- Data 24 jam dari Firestore
- Update setiap 30 detik (sesuai save interval)
- StreamBuilder → auto-refresh

---

## 🐛 Troubleshooting:

**Grafik tidak muncul?**

- Tunggu ESP32 kirim data beberapa kali (minimal 30 detik)
- Check Firebase Console → sensor_readings collection
- Pastikan index sudah dibuat

**Data tidak tersimpan?**

- Check console log untuk error
- Pastikan Firestore rules allow write
- Check internet connection

**Chart lag?**

- Kurangi periode grafik (12 jam instead of 24)
- Cleanup old data
- Check Firestore usage quota

---

## 💾 Firestore Usage Estimate:

**Per device:**

- Save interval: 30 detik
- 1 hari = 2,880 documents (24 jam × 120 writes/jam)
- 1 minggu = ~20,000 documents

**Rekomendasi:**

- Cleanup data > 7 hari
- Atau increase save interval ke 1-2 menit
- Monitor Firebase usage dashboard

---

## ✨ Next Features (Opsional):

- [ ] Export data to CSV
- [ ] Push notification jika suhu/humidity diluar range
- [ ] Aggregated data (hourly average)
- [ ] Comparison chart (hari ini vs kemarin)
- [ ] Statistics (min, max, average)

---

**Made with ❤️ for IOT Smart Garden Project**
