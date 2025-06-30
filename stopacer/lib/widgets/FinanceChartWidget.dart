import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const FinanceChartWidget({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];

    for (var i = 0; i < chartData.length; i++) {
      final item = chartData[i];
      final pemasukan = (item['pemasukan'] as num?)?.toDouble() ?? 0.0;
      final pengeluaran = (item['pengeluaran'] as num?)?.toDouble() ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: pemasukan, color: Colors.green, width: 8),
            BarChartRodData(toY: pengeluaran, color: Colors.red, width: 8),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= chartData.length) return const SizedBox();
                  final date = chartData[index]['tanggal'];
                  return Text(
                    date.substring(5), // tampilkan MM-DD
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
