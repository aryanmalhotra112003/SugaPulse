import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sugapulse/sugar/analytics_card.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/sugar/sugar_chart.dart';

FirebaseService firebaseService = FirebaseService();
User? user;
int allTimeAvg = 0;
int allTimeHigh = 0;
int allTimeLow = 0;
int weeklyAvg = 0;
int weeklyHigh = 0;
int weeklyLow = 0;
bool showSpinner = false;

class SugarAnalytics extends StatefulWidget {
  const SugarAnalytics({super.key});
  static const String id = 'sugar_analytics';
  @override
  State<SugarAnalytics> createState() => _SugarAnalyticsState();
}

class _SugarAnalyticsState extends State<SugarAnalytics> {
  @override
  void initState() {
    user = firebaseService.getCurrentUser();
    initAvg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor:
            Provider.of<myTheme>(context).theme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Provider.of<myTheme>(context).theme
              ? Colors.purple
              : Colors.greenAccent,
          title: Center(
            child: Text(
              'blood_sugar_analytics'.tr(),
              style: TextStyle(
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnalyticsCard(
              timeFrame: 'weekly'.tr(),
              high: weeklyHigh,
              low: weeklyLow,
              avg: weeklyAvg,
            ),
            Padding(
              padding: EdgeInsets.only(top: 70.0),
              child: Text(
                "this_weeks_readings".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Provider.of<myTheme>(context).theme
                        ? Colors.purple
                        : Colors.greenAccent),
              ),
            ),
            FutureBuilder<List<FlSpot>>(
              future: firebaseService.getWeeklySugarReadings(user?.email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Loading
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'no_data_found_week'.tr(),
                      style: TextStyle(
                          color: Provider.of<myTheme>(context).theme
                              ? Colors.white
                              : Colors.black),
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SugarChart(
                        sugarData: snapshot.data!,
                      )),
                );
              },
            ),
            AnalyticsCard(
              timeFrame: 'all_time'.tr(),
              high: allTimeHigh,
              low: allTimeLow,
              avg: allTimeAvg,
            ),
          ],
        ),
      ),
    );
  }

  void initAvg() async {
    setState(() {
      showSpinner = true;
    });
    int allTimeAverage = await firebaseService.calculateAverageSugarReading(
        user?.email, 'alltime');
    int weeklyAverage = await firebaseService.calculateAverageSugarReading(
        user?.email, 'weekly');
    int allTimeDangerHigh =
        await firebaseService.findDangerousSugarHigh(user?.email, 'alltime');
    int weeklyDangerHigh =
        await firebaseService.findDangerousSugarHigh(user?.email, 'weekly');

    int allTimeDangerLow =
        await firebaseService.findDangerousSugarLow(user?.email, 'alltime');
    int weeklyDangerLow =
        await firebaseService.findDangerousSugarLow(user?.email, 'weekly');
    setState(() {
      weeklyAvg = weeklyAverage;
      allTimeAvg = allTimeAverage;
      allTimeHigh = allTimeDangerHigh;
      weeklyHigh = weeklyDangerHigh;
      allTimeLow = allTimeDangerLow;
      weeklyLow = weeklyDangerLow;
      showSpinner = false;
    });
  }
}
