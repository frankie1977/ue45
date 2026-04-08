import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ue45x/screens/liga_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          displayLarge: GoogleFonts.roboto(
            fontSize: 86,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: GoogleFonts.roboto(
            fontSize: 67,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: GoogleFonts.roboto(
            fontSize: 58,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: GoogleFonts.roboto(
            fontSize: 48,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: GoogleFonts.roboto(
            fontSize: 41,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: GoogleFonts.roboto(
            fontSize: 34,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.roboto(
            fontSize: 31,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.roboto(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: GoogleFonts.roboto(
            fontSize: 24,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 22,
          ),
          bodySmall: GoogleFonts.roboto(
            fontSize: 19,
          ),
          labelLarge: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: GoogleFonts.roboto(
            fontSize: 19,
          ),
          labelSmall: GoogleFonts.roboto(
            fontSize: 17,
          ),
        ),
      ),
      home: const LigaScreen(),
    );
  }
}
