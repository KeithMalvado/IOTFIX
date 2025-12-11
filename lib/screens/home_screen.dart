import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../services/firestore_service.dart';
import '../models/sensor_reading_model.dart';
import '../widgets/sensor_chart_widget.dart';
import 'tambah_mesin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<List<SensorReading>>? _chartDataFuture;

  @override
  void initState() {
    super.initState();
    Provider.of<DeviceProvider>(context, listen: false).startListen();
  }

  void _loadChartData(String deviceId) {
    setState(() {
      _chartDataFuture =
          _firestoreService.streamSensorReadings(deviceId, hours: 24).first;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DeviceProvider>(context);

    // Langsung tampilkan konten utama tanpa splash screen
    if (prov.devices.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    final device = prov.devices.first;
    final isOnline = device.isOnline;

    // Load chart data on first build
    if (_chartDataFuture == null) {
      _loadChartData(device.id);
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light gray background
      body: Column(
        children: [
          // Fixed Navbar
          _buildNavbar(),

          // Scrollable Content
          Expanded(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                // Device Status Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: _buildStatusCard(device, isOnline),
                  ),
                ),

                // Control Cards Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control Panel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildPumpCard(device, prov)),
                            SizedBox(width: 12),
                            Expanded(child: _buildLampCard(device, prov)),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildModeCard(device, prov),
                      ],
                    ),
                  ),
                ),

                // Sensor Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Text(
                          'Sensor Monitoring',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildSensorGrid(device),
                      ],
                    ),
                  ),
                ),

                // Chart Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Text(
                          'Historical Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<List<SensorReading>>(
                          future: _chartDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              );
                            }

                            final readings = snapshot.data ?? [];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SensorChartWidget(
                                readings: readings,
                                onRefresh: () => _loadChartData(device.id),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fixed Navbar
  Widget _buildNavbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Logo Placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.eco_rounded, color: Colors.white, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Agri Link',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                  letterSpacing: -0.5,
                ),
              ),
              Spacer(),
              // Settings Icon
              _buildNavIcon(Icons.settings_outlined),
              SizedBox(width: 8),
              // Notification Icon
              _buildNavIcon(Icons.notifications_outlined),
              SizedBox(width: 8),
              // Profile Icon
              _buildNavIcon(Icons.account_circle_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Color(0xFF6B7280), size: 20),
    );
  }

  // Device Status Card
  Widget _buildStatusCard(device, bool isOnline) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.eco_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Color(0xFF4CAF50) : Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pump Control Card (Compact)
  Widget _buildPumpCard(device, DeviceProvider prov) {
    final isActive = device.lampStatus;
    final isAutoMode = device.pumpMode == 'auto';

    return GestureDetector(
      onTap: isAutoMode ? null : () => prov.toggleLamp(device),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Color(0xFF4CAF50), Color(0xFF66BB6A)]
                : [Colors.white, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Color(0xFF4CAF50).withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.2)
                        : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.water_drop_rounded
                        : Icons.water_drop_outlined,
                    color: isActive
                        ? Colors.white
                        : (isAutoMode ? Color(0xFF9CA3AF) : Color(0xFF4CAF50)),
                    size: 24,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Pompa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white.withOpacity(0.9)
                        : (isAutoMode ? Color(0xFF9CA3AF) : Color(0xFF6B7280)),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isActive ? 'Menyiram' : 'Mati',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : (isAutoMode ? Color(0xFF9CA3AF) : Color(0xFF1F2937)),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (isAutoMode)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AUTO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Lamp Control Card (Compact)
  Widget _buildLampCard(device, DeviceProvider prov) {
    final isActive = device.pumpStatus;

    return GestureDetector(
      onTap: () => prov.togglePump(device),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Color(0xFFFFB800), Color(0xFFFFC933)]
                : [Colors.white, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Color(0xFFFFB800).withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.2)
                    : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? Icons.lightbulb_rounded : Icons.lightbulb_outlined,
                color: isActive ? Colors.white : Color(0xFFFFB800),
                size: 24,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Lampu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white.withOpacity(0.9)
                    : Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 4),
            Text(
              isActive ? 'Menyala' : 'Mati',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mode Control Card
  Widget _buildModeCard(device, DeviceProvider prov) {
    final isAuto = device.pumpMode == 'auto';

    return GestureDetector(
      onTap: () => prov.toggleMode(device),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAuto
                      ? [Color(0xFF3B82F6), Color(0xFF60A5FA)]
                      : [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isAuto ? Icons.auto_mode_rounded : Icons.touch_app_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atur Mode Pompa Air',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isAuto ? 'Otomatis' : 'Manual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle Switch
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAuto
                      ? [Color(0xFF3B82F6), Color(0xFF60A5FA)]
                      : [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isAuto ? 26 : 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sensor Grid 2x2
  Widget _buildSensorGrid(device) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildSensorCard(
          icon: Icons.thermostat_outlined,
          label: 'Suhu Udara',
          value: device.airTemperature,
          unit: '°C',
          color: Color(0xFFFF6B6B),
        ),
        _buildSensorCard(
          icon: Icons.water_damage_outlined,
          label: 'Kelembapan Udara',
          value: device.airHumidity,
          unit: '%',
          color: Color(0xFF4ECDC4),
        ),
        _buildSensorCard(
          icon: Icons.eco_outlined,
          label: 'Kelembapan Tanah',
          value: device.soilMoisture,
          unit: '%',
          color: Color(0xFF95E1D3),
        ),
        _buildSensorCard(
          icon: Icons.sensors_outlined,
          label: 'Status',
          value: device.isOnline ? 100 : 0,
          unit: '%',
          color: Color(0xFF4CAF50),
        ),
      ],
    );
  }

  // Individual Sensor Card (Clean Design)
  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 2),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
