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
            fontWeight: .bold,
          ),
          displayMedium: GoogleFonts.roboto(
            fontSize: 67,
            fontWeight: .bold,
          ),
          displaySmall: GoogleFonts.roboto(
            fontSize: 58,
            fontWeight: .bold,
          ),
          headlineLarge: GoogleFonts.roboto(
            fontSize: 48,
            fontWeight: .w600,
          ),
          headlineMedium: GoogleFonts.roboto(
            fontSize: 41,
            fontWeight: .w600,
          ),
          headlineSmall: GoogleFonts.roboto(
            fontSize: 34,
            fontWeight: .w600,
          ),
          titleLarge: GoogleFonts.roboto(
            fontSize: 31,
            fontWeight: .w600,
          ),
          titleMedium: GoogleFonts.roboto(
            fontSize: 26,
            fontWeight: .w500,
          ),
          titleSmall: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: .w500,
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
            fontWeight: .w500,
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
