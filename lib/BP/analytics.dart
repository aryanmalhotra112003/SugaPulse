import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sugapulse/BP/bp_chart.dart';
import 'package:sugapulse/BP/analytics_card.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/firebase_service.dart';

FirebaseService firebaseService = FirebaseService();
User? user;
int sbpAvg = 0;
int dbpAvg = 0;
int pulseAvg = 0;
bool showSpinner = false;

class BPAnalytics extends StatefulWidget {
  const BPAnalytics({super.key});
  static const String id = 'bp_analytics';
  @override
  State<BPAnalytics> createState() => _BPAnalyticsState();
}

class _BPAnalyticsState extends State<BPAnalytics> {
  @override
  void initState() {
    user = firebaseService.getCurrentUser();
    super.initState();
    initAvg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<myTheme>(context).theme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Provider.of<myTheme>(context).theme
            ? Colors.purple
            : Colors.greenAccent,
        title: Center(
          child: Text(
            'blood_pressure_analytics'.tr(),
            style: TextStyle(
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FutureBuilder<List<FlSpot>>(
                future: firebaseService.getWeeklySBP(user?.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator()); // Loading
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

                  return BPChart(
                    desc: 'systolic_bp'.tr(),
                    data: snapshot.data!,
                    c: Provider.of<myTheme>(context).theme
                        ? Colors.amber
                        : Colors.yellow,
                  );
                },
              ),
              FutureBuilder<List<FlSpot>>(
                future: firebaseService.getWeeklyDBP(user?.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator()); // Loading
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                      'no_data_found_week'.tr(),
                      style: TextStyle(
                          color: Provider.of<myTheme>(context).theme
                              ? Colors.white
                              : Colors.black),
                    ));
                  }

                  return BPChart(
                    desc: 'diastolic_bp'.tr(),
                    data: snapshot.data!,
                    c: Colors.pinkAccent,
                  );
                },
              ),
              FutureBuilder<List<FlSpot>>(
                future: firebaseService.getWeeklyPulse(user?.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator()); // Loading
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                      'no_data_found_week'.tr(),
                      style: TextStyle(
                          color: Provider.of<myTheme>(context).theme
                              ? Colors.white
                              : Colors.black),
                    ));
                  }

                  return BPChart(
                    desc: 'pulse'.tr(),
                    data: snapshot.data!,
                    c: Colors.redAccent,
                  );
                },
              ),
              AnalyticsCard(
                sbp: sbpAvg,
                dbp: dbpAvg,
                pulse: pulseAvg,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initAvg() async {
    setState(() {
      showSpinner = true;
    });

    try {
      int count = await firebaseService.findCountOfBPReadings(user?.email);

      if (count > 0) {
        Map<String, int> bpReadings =
            await firebaseService.calculateAverageBPReading(user?.email);

        setState(() {
          sbpAvg = bpReadings['sbp'] ?? 0;
          dbpAvg = bpReadings['dbp'] ?? 0;
          pulseAvg = bpReadings['pulse'] ?? 0;
        });
      } else {
        setState(() {
          sbpAvg = 0;
          dbpAvg = 0;
          pulseAvg = 0;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }
}
