# Firebase Firestore Index Requirements

## Indexes yang Diperlukan

Untuk fitur history data sensor, Anda perlu membuat composite index di Firebase Console:

### Index 1: sensor_readings Query

- **Collection**: `sensor_readings`
- **Fields**:
  1. `deviceId` (Ascending)
  2. `timestamp` (Ascending)

### Index 2: sensor_readings dengan filter timestamp

- **Collection**: `sensor_readings`
- **Fields**:
  1. `deviceId` (Ascending)
  2. `timestamp` (Descending)

## Cara Membuat Index:

1. Buka Firebase Console: https://console.firebase.google.com
2. Pilih project Anda
3. Klik **Firestore Database** di menu kiri
4. Klik tab **Indexes**
5. Klik **Create Index**
6. Isi sesuai spesifikasi di atas
7. Klik **Create**

## Atau tunggu error muncul di app:

Ketika aplikasi pertama kali query data history, Firebase akan throw error dengan link langsung untuk create index. Anda tinggal klik link tersebut.

## Collections Structure:

### devices

```
devices/{deviceId}
  - name: string
  - broker: string
  - username: string
  - password: string
  - topicSoil: string
  - topicTemp: string
  - topicHumidity: string
  - topicRelayControl: string
  - topicRelayStatus: string
  - soilMoisture: number
  - airTemperature: number
  - airHumidity: number
  - relayStatus: boolean
  - lastSeen: string (ISO8601)
```

### sensor_readings

```
sensor_readings/{readingId}
  - deviceId: string
  - airTemperature: number
  - airHumidity: number
  - soilMoisture: number
  - timestamp: string (ISO8601)
```

## Auto Cleanup (Optional)

Untuk mencegah Firestore terlalu penuh, jalankan cleanup secara berkala:

```dart
// Di provider atau background task
await firestore.cleanOldReadings(daysToKeep: 7);
```
