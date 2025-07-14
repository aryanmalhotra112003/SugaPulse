import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:sugapulse/BP/stream.dart';
import 'package:sugapulse/BP/bottom_sheet.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

final FirebaseService firebaseService = FirebaseService();
User? loggedInUser;
bool showSpinner = false;

class LogBP extends StatefulWidget {
  const LogBP({super.key});
  static const String id = 'log_bp';
  @override
  State<LogBP> createState() => _LogBPState();
}

class _LogBPState extends State<LogBP> {
  @override
  void initState() {
    super.initState();
    loggedInUser = firebaseService.getCurrentUser();
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
            'your_bp_readings'.tr(),
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
          child: BPReadingsStream(),
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
                child: buildBottomSheet(context),
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
}
