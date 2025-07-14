import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/theme.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final int streak;
  const StreakCard({
    super.key,
    required this.title,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Provider.of<myTheme>(context).theme
              ? Colors.purple
              : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        height: 200,
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'streak_count'.tr(),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Text(
              streak.toString(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
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
