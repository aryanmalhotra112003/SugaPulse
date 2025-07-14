import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/HbA1c/hba1c.dart';
import 'package:sugapulse/progress/progress.dart';
import 'package:sugapulse/screens/log_bp.dart';
import 'package:sugapulse/screens/welcome_screen.dart';
import 'log_sugar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugapulse/components/reusable_card.dart';
import 'package:sugapulse/sugar/analytics.dart';
import 'package:sugapulse/BP/analytics.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

final _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            "app_title".tr(),
            style: TextStyle(
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
              icon: Icon(Icons.close))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              textAlign: TextAlign.center,
              'home_screen_prompt'.tr(),
              style: TextStyle(
                  fontSize: 20,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  ReusableCard(
                    title: 'log_sugar'.tr(),
                    icon: Icons.assignment,
                    op: () {
                      Navigator.pushNamed(context, LogSugar.id);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ReusableCard(
                    title: 'log_bp'.tr(),
                    icon: Icons.assignment,
                    op: () {
                      Navigator.pushNamed(context, LogBP.id);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  ReusableCard(
                    title: 'check_sugar_analytics'.tr(),
                    icon: Icons.analytics_outlined,
                    op: () {
                      Navigator.pushNamed(context, SugarAnalytics.id);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ReusableCard(
                    title: 'check_bp_analytics'.tr(),
                    icon: Icons.analytics_outlined,
                    op: () {
                      Navigator.pushNamed(context, BPAnalytics.id);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  ReusableCard(
                    title: 'progress_title'.tr(),
                    icon: Icons.emoji_events_outlined,
                    op: () {
                      Navigator.pushNamed(context, Progress.id);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ReusableCard(
                    title: 'hba1c_category_estimation'.tr(),
                    icon: Icons.water_drop_outlined,
                    op: () {
                      Navigator.pushNamed(context, hba1c.id);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  ReusableCard(
                    title: 'change_theme'.tr(),
                    icon: Icons.brightness_4_outlined,
                    op: () {
                      Provider.of<myTheme>(context, listen: false)
                          .changeTheme();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ReusableCard(
                    title: 'change_language'.tr(),
                    icon: Icons.translate,
                    op: () {
                      if (context.locale.languageCode == 'en') {
                        context.setLocale(Locale('hi'));
                      } else {
                        context.setLocale(Locale('en'));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
