import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/sugar/bottom_sheet.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:sugapulse/sugar/stream.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

final FirebaseService firebaseService = FirebaseService();
User? loggedInUser;
int avg = 0;
bool showSpinner = false;

class LogSugar extends StatefulWidget {
  const LogSugar({super.key});
  static const String id = 'log_sugar';
  @override
  State<LogSugar> createState() => _LogSugarState();
}

class _LogSugarState extends State<LogSugar> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> _getAverageSugarReading() async {
    setState(() {
      showSpinner = true;
    });
    int average = await firebaseService.calculateAverageSugarReading(
        loggedInUser!.email, 'alltime');
    setState(() {
      avg = average;
      showSpinner = false;
    });
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
            'your_sugar_readings'.tr(),
            style: TextStyle(
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: SugarReadingsStream(
            getAvg: _getAverageSugarReading,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Provider.of<myTheme>(context).theme
            ? Colors.purple
            : Colors.greenAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: buildBottomSheet(context, _getAverageSugarReading),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color:
              Provider.of<myTheme>(context).theme ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void init() async {
    loggedInUser = firebaseService.getCurrentUser();
    await _getAverageSugarReading();
  }
}
