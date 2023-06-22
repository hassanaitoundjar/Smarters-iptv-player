part of 'helpers.dart';

class MyThemApp {
  static ThemeData themeData(BuildContext context) {
    return ThemeData.dark().copyWith(
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 18.sp,
        ),
        titleSmall: GoogleFonts.roboto(
          color: kColorFontLight,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
