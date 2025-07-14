import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

class SugarChart extends StatelessWidget {
  final List<FlSpot> sugarData;

  const SugarChart({required this.sugarData, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1.5, // Adjust chart size
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(), // Show sugar values
                      style: TextStyle(
                          fontSize: 12,
                          color: Provider.of<myTheme>(context).theme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        value.toInt().toString(), // Show sugar values
                        style: TextStyle(
                            fontSize: 12,
                            color: Provider.of<myTheme>(context).theme
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      // Convert milliseconds to DateTime
                      DateTime date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());

                      // // Get the list of x-axis values (timestamps in milliseconds) you want to display
                      List<int> validTimestamps =
                          sugarData.map((e) => e.x.toInt()).toList();

                      // Only show labels for actual recorded dates
                      if (validTimestamps.contains(value.toInt())) {
                        String formattedDate = DateFormat('d MMM').format(date);

                        return Text(
                          formattedDate,
                          style: TextStyle(
                              fontSize: 12,
                              color: Provider.of<myTheme>(context).theme
                                  ? Colors.white
                                  : Colors.black),
                        );
                      }

                      return SizedBox
                          .shrink(); // Hide in-between decimal values
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                      color: Provider.of<myTheme>(context).theme
                          ? Colors.white
                          : Colors.black)),
              lineBarsData: [
                LineChartBarData(
                  spots: sugarData,
                  isCurved: true,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.purple
                      : Colors.greenAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                      show: true,
                      color: Provider.of<myTheme>(context).theme
                          ? Colors.purple.withOpacity(0.3)
                          : Colors.greenAccent.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
        Text(
          'blood_sugar'.tr(),
          style: TextStyle(
              color: Provider.of<myTheme>(context).theme
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.3)),
        ),
      ],
    );
  }
}
