import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<FlSpot> spots = [];
  String selectedPeriod = 'hari'; // hari, bulan, tahun

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    DateTime startDate = DateTime.now();

    if (selectedPeriod == 'hari') {
      startDate = DateTime.now().subtract(const Duration(days: 1));
    } else if (selectedPeriod == 'bulan') {
      startDate = DateTime.now().subtract(const Duration(days: 30));
    } else if (selectedPeriod == 'tahun') {
      startDate = DateTime.now().subtract(const Duration(days: 365));
    }

    try {
      final q = await FirebaseFirestore.instance
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .get();

      List<FlSpot> temp = [];
      int index = 0;

      // Filter data client-side jika perlu
      for (var doc in q.docs) {
        final timestamp = doc['timestamp'];
        DateTime docDate;

        if (timestamp is String) {
          docDate = DateTime.parse(timestamp);
        } else if (timestamp is Timestamp) {
          docDate = timestamp.toDate();
        } else {
          continue;
        }

        // Filter hanya data dalam range
        if (docDate.isAfter(startDate)) {
          double suhu = (doc['temperature'] ?? 0).toDouble();
          temp.add(FlSpot(index.toDouble(), suhu));
          index++;
        }
      }

      setState(() => spots = temp);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analisa Suhu")),
      body: Column(
        children: [
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => selectedPeriod = 'hari');
                    loadData();
                  },
                  child: const Text('Hari'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => selectedPeriod = 'bulan');
                    loadData();
                  },
                  child: const Text('Bulan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => selectedPeriod = 'tahun');
                    loadData();
                  },
                  child: const Text('Tahun'),
                ),
              ],
            ),
          ),
          // Chart
          Expanded(
            child: spots.isEmpty
                ? const Center(child: Text("Belum ada data pembacaan suhu"))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
