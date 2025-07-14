import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/firebase_service.dart';

final FirebaseService firebaseService = FirebaseService();
void showBanner(BuildContext context, bool status) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Text(
          status
              ? '${'welcome_message'.tr()} ${firebaseService.getCurrentUser()?.email}'
              : 'failure_message'.tr(),
          style: TextStyle(color: status ? Colors.black : Colors.white)),
      backgroundColor: status ? Colors.white : Colors.black,
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text("dismiss".tr(),
              style: TextStyle(color: status ? Colors.black : Colors.white)),
        ),
      ],
    ),
  );
}
