import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE86F1C);
  static const Color creamBackground = Color(0xFFFCF9F2);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFFEEEEEE);
  static const Color surfaceCream = Color(0xFFFFF4EA);
  static const Color chakraGreen = Color(0xFF4CAF50);
  static const Color secondaryGrey = Color(0xFF888888);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: primaryOrange,
        surface: creamBackground,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: textDark),
        bodyMedium: const TextStyle(color: textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: creamBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: creamBackground,
        selectedItemColor: primaryOrange,
        unselectedItemColor: secondaryGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryOrange,
        inactiveTrackColor: primaryOrange.withOpacity(0.2),
        thumbColor: creamBackground,
        overlayColor: primaryOrange.withOpacity(0.1),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: primaryOrange,
        surface: darkBackground,
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: const TextStyle(color: textLight, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: textLight),
        bodyMedium: const TextStyle(color: textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: primaryOrange,
        unselectedItemColor: secondaryGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryOrange,
        inactiveTrackColor: primaryOrange.withOpacity(0.2),
        thumbColor: darkBackground,
        overlayColor: primaryOrange.withOpacity(0.1),
      ),
    );
  }
}
