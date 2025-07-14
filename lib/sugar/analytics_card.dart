import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.timeFrame,
    required this.avg,
    required this.high,
    required this.low,
  });
  final String timeFrame;
  final int avg;
  final int high;
  final int low;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        color: Provider.of<myTheme>(context).theme
            ? Colors.purple.withOpacity(0.85)
            : Colors.greenAccent.withOpacity(0.7),
        // height: 80,
        child: Column(
          children: [
            Text(
              '${'timeframe'.tr()} $timeFrame',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.black
                      : Colors.white),
            ),
            Text(
              '${'average_reading'.tr()} $avg',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
            ),
            SizedBox(
              height: 7,
            ),
            Text(
              '${'dangerous_highs'.tr()} $high',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
            ),
            SizedBox(
              height: 7,
            ),
            Text(
              '${'dangerous_lows'.tr()} $low',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
