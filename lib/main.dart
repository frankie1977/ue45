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
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          displayLarge: GoogleFonts.roboto(
            fontSize: 86,
            fontWeight: .bold,
          ),
          displayMedium: GoogleFonts.roboto(
            fontSize: 68,
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
            fontSize: 42,
            fontWeight: .w600,
          ),
          headlineSmall: GoogleFonts.roboto(
            fontSize: 34,
            fontWeight: .w600,
          ),
          titleLarge: GoogleFonts.roboto(
            fontSize: 32,
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
            fontSize: 20,
          ),
          labelLarge: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: .w500,
          ),
          labelMedium: GoogleFonts.roboto(
            fontSize: 20,
          ),
          labelSmall: GoogleFonts.roboto(
            fontSize: 18,
          ),
        ),
      ),
      home: const LigaScreen(),
    );
  }
}
