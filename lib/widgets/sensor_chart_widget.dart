import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/sensor_reading_model.dart';

class SensorChartWidget extends StatelessWidget {
  final List<SensorReading> readings;
  final VoidCallback onRefresh;

  const SensorChartWidget({
    super.key,
    required this.readings,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          _buildChart(),
          SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grafik Sensor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '24 Jam Terakhir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB)),
          ),
          child: Text(
            '${readings.length} data',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child:
                Icon(Icons.refresh_rounded, color: Color(0xFF4CAF50), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // Calculate dynamic min/max for better scaling
    final allValues = <double>[];
    for (var reading in readings) {
      // Only add valid values (not 0, not null, reasonable range)
      if (reading.airTemperature > 0 && reading.airTemperature <= 100) {
        allValues.add(reading.airTemperature);
      }
      if (reading.airHumidity > 0 && reading.airHumidity <= 100) {
        allValues.add(reading.airHumidity);
      }
      if (reading.soilMoisture > 0 && reading.soilMoisture <= 100) {
        allValues.add(reading.soilMoisture);
      }
    }

    // If no valid values, use default range
    if (allValues.isEmpty) {
      allValues.addAll([20.0, 80.0]); // Default range
    }

    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    // Add padding to min/max for better visualization (at least 10% padding)
    var padding = (maxValue - minValue) * 0.15;
    if (padding < 5) padding = 5.0; // Minimum padding of 5

    final chartMin =
        (minValue - padding).clamp(0.0, double.infinity).toDouble();
    final chartMax =
        (maxValue + padding).clamp(chartMin + 10, 100.0).toDouble();

    // Calculate interval - aim for 5 grid lines
    var interval = ((chartMax - chartMin) / 5).ceilToDouble();
    if (interval < 1) interval = 1;
    if (interval > 20) interval = 20;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xFFE5E7EB),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: readings.length > 6
                    ? (readings.length / 6).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= readings.length || value.toInt() < 0) {
                    return SizedBox.shrink();
                  }

                  final reading = readings[value.toInt()];
                  final hour =
                      reading.timestamp.hour.toString().padLeft(2, '0');
                  final minute =
                      reading.timestamp.minute.toString().padLeft(2, '0');

                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '$hour:$minute',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
              left: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          minX: 0,
          maxX: (readings.length - 1).toDouble(),
          minY: chartMin,
          maxY: chartMax,
          lineBarsData: [
            // Temperature line
            LineChartBarData(
              spots: _buildSpots((r) => r.airTemperature, chartMin),
              isCurved: true,
              color: Color(0xFFf97316),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFFf97316).withOpacity(0.1),
              ),
            ),
            // Air Humidity line
            LineChartBarData(
              spots: _buildSpots((r) => r.airHumidity, chartMin),
              isCurved: true,
              color: Color(0xFF3b82f6),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFF3b82f6).withOpacity(0.1),
              ),
            ),
            // Soil Moisture line
            LineChartBarData(
              spots: _buildSpots((r) => r.soilMoisture, chartMin),
              isCurved: true,
              color: Color(0xFF8b5cf6),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFF8b5cf6).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots(
      double Function(SensorReading) getValue, double minY) {
    return List.generate(
      readings.length,
      (index) {
        var value = getValue(readings[index]);
        // Replace invalid values (0 or negative) with minY to prevent spikes
        if (value <= 0) {
          value = minY;
        }
        return FlSpot(index.toDouble(), value);
      },
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(Color(0xFFf97316), 'Suhu'),
        _buildLegendItem(Color(0xFF3b82f6), 'Kelembapan Udara'),
        _buildLegendItem(Color(0xFF8b5cf6), 'Kelembapan Tanah'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
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
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Menunggu Data Historis',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Data akan muncul setelah ESP32 mengirim sensor data',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
