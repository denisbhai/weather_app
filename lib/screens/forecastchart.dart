import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/forecast_model.dart';

class ForecastChart extends StatelessWidget {
  final List<DailyForecast> forecast;

  const ForecastChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daily Chart",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white, // Left axis text color
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < forecast.length) {
                        return Text(
                          "${forecast[index].date.day}/${forecast[index].date.month}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        );
                      }
                      return const Text("");
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white, // Right axis text color
                          fontSize: 12,
                        ),
                      );
                    },
                  ),

                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white, // Right axis text color
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: forecast
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(e.key.toDouble(), e.value.maxTemp),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: forecast
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(e.key.toDouble(), e.value.minTemp),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
