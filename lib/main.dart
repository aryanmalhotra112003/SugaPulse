import 'package:flutter/material.dart';
import 'package:sugapulse/progress/progress.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/log_sugar.dart';
import 'screens/log_bp.dart';
import 'sugar/analytics.dart';
import 'BP/analytics.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/HbA1c/hba1c.dart';
import 'theme.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('hi')],
      path: 'assets/langs',
      fallbackLocale: Locale('en'),
      child: SugaPulse(),
    ),
  );
}

class SugaPulse extends StatelessWidget {
  const SugaPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => myTheme(),
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          LogSugar.id: (context) => LogSugar(),
          LogBP.id: (context) => LogBP(),
          SugarAnalytics.id: (context) => SugarAnalytics(),
          BPAnalytics.id: (context) => BPAnalytics(),
          hba1c.id: (context) => hba1c(),
          Progress.id: (context) => Progress(),
        },
      ),
    );
  }
}
