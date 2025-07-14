import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sugapulse/progress/StreakCard.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:easy_localization/easy_localization.dart';

FirebaseService firebaseService = FirebaseService();
User? user;
bool showSpinner = false;
int sugar_streak = 0;
int bp_streak = 0;
int score = 0;

class Progress extends StatefulWidget {
  static const String id = 'progress';
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  void initState() {
    super.initState();
    user = firebaseService.getCurrentUser();
    init();
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
            'progress_title'.tr(),
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
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  StreakCard(
                    streak: sugar_streak,
                    title: 'sugar'.tr(),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  StreakCard(
                    streak: bp_streak,
                    title: 'bp'.tr(),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 500,
                width: 200,
                decoration: BoxDecoration(
                    color: Provider.of<myTheme>(context).theme
                        ? Colors.purple
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'achievements_title'.tr(),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<myTheme>(context).theme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'your_current_score'.tr(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<myTheme>(context).theme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<myTheme>(context).theme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      medalType(score),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<myTheme>(context).theme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      getScoreMessage(score),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<myTheme>(context).theme
                            ? Colors.white
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void init() async {
    setState(() {
      showSpinner = true;
    });
    int fetchedScore = await firebaseService.fetchScore(user?.email);
    int fetchedSugarStreak =
        await firebaseService.fetchSugarStreak(user?.email);
    int fetchedBPStreak = await firebaseService.fetchBPStreak(user?.email);
    //fetch and update into new vars
    setState(() {
      sugar_streak = fetchedSugarStreak;
      bp_streak = fetchedBPStreak;
      score = fetchedScore;
      showSpinner = false;
    });
  }
}

String medalType(int score) {
  if (score < 100) {
    return '🥉';
  } else if (score >= 100 && score < 500) {
    return '🥈';
  } else {
    return '🥇';
  }
}

String getScoreMessage(int score) {
  if (score < 100) {
    return "score_message_bronze".tr();
  } else if (score >= 100 && score < 500) {
    return "score_message_silver".tr();
  } else {
    return "score_message_gold".tr();
  }
}
