import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/theme.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.sbp,
    required this.dbp,
    required this.pulse,
  });

  final int sbp;
  final int dbp;
  final int pulse;

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
              'timeframe_weekly'.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.black
                      : Colors.white),
            ),
            Text(
              '${'average_bp'.tr()} $sbp/$dbp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Text(
              '${'average_pulse'.tr()} $pulse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
