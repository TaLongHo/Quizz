import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StudyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isDark;

  const StudyChart({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(data[index]['day'],
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['score'].toDouble())).toList(),
              isCurved: true, // Đường cong mềm mại
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.blueAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}