import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:tugasku/pages/onboarding/on_boarding_page.dart';
import 'package:intl/date_symbol_data_local.dart';

int introduction = 0;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
  await initIntroduction();
  runApp(MyApp());
}

Future initIntroduction() async{
  final prefs = await SharedPreferences.getInstance();

  int? intro = prefs.getInt('introduction');
  if (intro != null && intro == 1){
    return introduction = 1;
  }
  prefs.setInt('introduction', 1);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      ),
      title: 'TugasKu',
      debugShowCheckedModeBanner: false,
      home: introduction == 0 
        ? OnBoardingPage() 
        : LoginPage(),
    );
  }
}
