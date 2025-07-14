import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/constants.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

final FirebaseService firebaseService = FirebaseService();
Widget buildBottomSheet(BuildContext context) {
  final TextEditingController sbpController = TextEditingController();
  final TextEditingController dbpController = TextEditingController();
  final TextEditingController pulseController = TextEditingController();

  void showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Provider.of<myTheme>(context, listen: false).theme
            ? Colors.purple.withOpacity(0.9)
            : Colors.greenAccent.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'invalid_input'.tr(),
          style: TextStyle(
              color: Provider.of<myTheme>(context, listen: false).theme
                  ? Colors.white
                  : Colors.black),
        ),
        content: Text(
          'error'.tr(),
          style: TextStyle(
              fontSize: 20,
              color: Provider.of<myTheme>(context, listen: false).theme
                  ? Colors.white
                  : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ok'.tr(),
              style: TextStyle(
                  color: Provider.of<myTheme>(context, listen: false).theme
                      ? Colors.white
                      : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  bool isValidReading(String value) {
    if (value.isEmpty) return false;
    final int? numValue = int.tryParse(value);
    if (numValue == null || numValue <= 0 || numValue > 500) return false;
    return true;
  }

  return Container(
    decoration: BoxDecoration(
      color: Provider.of<myTheme>(context).theme
          ? Colors.black.withOpacity(0.4)
          : Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    height: 500,
    width: 500,
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Text(
              'add_reading'.tr(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.purple
                    : Colors.greenAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: sbpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'enter_systolic_pressure'.tr()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: dbpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'enter_diastolic_pressure'.tr()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: pulseController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'enter_pulse_rate'.tr()),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Provider.of<myTheme>(context).theme
                  ? Colors.purple
                  : Colors.greenAccent,
            ),
            onPressed: () async {
              String sbpText = sbpController.text.trim();
              String dbpText = dbpController.text.trim();
              String pulseText = pulseController.text.trim();

              if (!isValidReading(sbpText) ||
                  !isValidReading(dbpText) ||
                  !isValidReading(pulseText)) {
                showValidationError();
                return;
              }

              int sbp = int.parse(sbpText);
              int dbp = int.parse(dbpText);
              int pulse = int.parse(pulseText);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Provider.of<myTheme>(context).theme
                          ? Colors.purple
                          : Colors.greenAccent,
                    ),
                  );
                },
              );

              try {
                await firebaseService.addBPReading(
                    sbp, dbp, pulse, firebaseService.getCurrentUser()!.email);
              } catch (e) {
                print('Error adding reading: $e');
              } finally {
                Navigator.pop(context); // spinner
                Navigator.pop(context); // bottom sheet
              }
            },
            child: Text(
              'add'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Provider.of<myTheme>(context).theme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
