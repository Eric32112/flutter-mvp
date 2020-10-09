import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TempoTheme {
  static ThemeData themeData = ThemeData(
      fontFamily: GoogleFonts.roboto().fontFamily,
      appBarTheme: AppBarTheme(color: Color(0xffEFE6D4)),
      textTheme: TextTheme(
          headline6: GoogleFonts.roboto(),
          headline1: GoogleFonts.roboto(),
          bodyText1: GoogleFonts.roboto(),
          button: GoogleFonts.roboto(),
          bodyText2: GoogleFonts.roboto()),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: Colors.orange,
      primarySwatch: Colors.orange,
      inputDecorationTheme: InputDecorationTheme(fillColor: inputColor));

  static final Color inputColor = Color(0xffF3D6BC);
  static final Color backgroundColor = Color(0xffEFE6D4);
  static final Color linkColor = Color(0xff2699FB);
  static final Color primaryBtnColor = Color(0xffF38D54);
  static final Color grey2 = Color(0xff4F4F4F);
  static final Color dividerColor = Color(0xffCDC9C9);
  static final Color retroOrange = Color(0xffF38D54);

  static final Color eventsColor = Color(0xffE8727E);
  static final Color reminderColor = Color(0xffC484E2);
  static final Color tasksColor = Color(0xffFC9C43);
  static final Color recommendedEventsColor = Color(0xff6C9F7B);
  static final Color recommendedTasksColor = Color(0xff7EA9E9);
}
