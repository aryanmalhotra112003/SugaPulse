import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugapulse/theme.dart';
import 'package:provider/provider.dart';

final FirebaseService firebaseService = FirebaseService();
User? loggedInUser;
String category = '';
String message = '';

class hba1c extends StatefulWidget {
  const hba1c({super.key});
  static const String id = 'hba1c_screen';
  @override
  State<hba1c> createState() => _hba1cState();
}

class _hba1cState extends State<hba1c> {
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    loggedInUser = firebaseService.getCurrentUser();
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
            'hba1c_estimation'.tr(),
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
          padding: const EdgeInsets.all(25.0),
          child: hba1c_card(
            category: category,
            message: message,
          ),
        ),
      ),
    );
  }

  String findCategory(int avg) {
    double hba1c = ((avg.toDouble() + 46.7) / 28.7);

    if (hba1c < 5.7) {
      return 'normal'.tr();
    } else if (hba1c >= 5.7 && hba1c < 6.4) {
      return 'pre_diabetic'.tr();
    } else {
      return 'diabetic'.tr();
    }
  }

  void init() async {
    setState(() {
      showSpinner = true;
    });
    if (await firebaseService.findCountOfSugarReadings(loggedInUser?.email) >
        14) {
      int avg = await firebaseService.calculateAverageSugarReading(
          loggedInUser?.email, 'alltime');
      String initCategory = findCategory(avg);
      String initMessage = findMessage(avg);
      setState(() {
        category = initCategory;
        message = initMessage;

        showSpinner = false;
      });
    } else {
      setState(() {
        message = 'need_more_readings'.tr();
        category = 'no_data_found'.tr();
        showSpinner = false;
      });
    }
  }

  String findMessage(int avg) {
    double hba1c = ((avg.toDouble() + 46.7) / 28.7);
    if (hba1c < 5.7) {
      return 'normal_message'.tr();
    } else if (hba1c >= 5.7 && hba1c < 6.4) {
      return 'pre_diabetic_message'.tr();
    } else {
      return 'diabetic_message'.tr();
    }
  }
}

class hba1c_card extends StatelessWidget {
  hba1c_card({
    required this.message,
    required this.category,
    super.key,
  });
  String message;
  String category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        height: 700,
        color: Provider.of<myTheme>(context).theme
            ? Colors.purple.withOpacity(0.5)
            : Colors.greenAccent.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text(
                'your_hba1c_category'.tr(),
                style: TextStyle(
                    fontSize: 30,
                    color: Provider.of<myTheme>(context).theme
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                category,
                style: TextStyle(
                    color: findColor(category),
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                message,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    color: Provider.of<myTheme>(context).theme
                        ? Colors.white
                        : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color findColor(String category) {
    if (category == 'normal'.tr()) {
      return Colors.green;
    } else if (category == 'pre_diabetic'.tr()) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
