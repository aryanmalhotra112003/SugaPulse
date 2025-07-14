import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/components/banner.dart';
import 'package:sugapulse/firebase_service.dart';
import 'package:sugapulse/screens/log_sugar.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/theme.dart';

final FirebaseService firebaseService = FirebaseService();

class Tile extends StatelessWidget {
  const Tile(
      {required this.dateTime,
      super.key,
      required this.reading,
      required this.id,
      required this.getAvg});
  final int reading;
  final DateTime dateTime;
  final Function getAvg;
  final String id;

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat.yMd().format(dateTime);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Provider.of<myTheme>(context).theme
            ? Colors.white.withOpacity(0.2)
            : Colors.black,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '${'date'.tr()} $formattedDate ${'time'.tr()} $formattedTime',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      final navigator =
                          Navigator.of(context, rootNavigator: true);
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // Prevents closing while loading
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
                        await firebaseService.deleteSugarReading(
                            id, firebaseService.getCurrentUser()!.email);
                        await firebaseService.decreaseSugarScore(
                            firebaseService.getCurrentUser()!.email);

                        await getAvg();
                      } catch (e) {
                        showBanner(context, false);
                      } finally {
                        navigator.pop();
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$reading ${'mg_dl'.tr()}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                getIconOnAvg(reading, avg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Icon getIconOnAvg(int reading, int avg) {
  if (reading > avg) {
    return Icon(
      Icons.keyboard_arrow_up,
      size: 50,
      color: Colors.greenAccent,
    );
  } else if (reading < avg) {
    return Icon(
      Icons.keyboard_arrow_down,
      size: 50,
      color: Colors.red,
    );
  } else {
    return Icon(
      Icons.drag_handle,
      size: 50,
      color: Colors.amber,
    );
  }
}
