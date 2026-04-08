import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/sample_data.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/screens/begegnungen_tab.dart';
import 'package:ue45x/screens/tabelle_tab.dart';
import 'package:ue45x/screens/teams_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
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

class LigaScreen extends StatefulWidget {
  const LigaScreen({super.key});

  @override
  State<LigaScreen> createState() => _LigaScreenState();
}

class _LigaScreenState extends State<LigaScreen> {
  Liga _liga = buildSampleLiga();

  void _begegnungGeaendert(Begegnung begegnung) {
    setState(() {
      _liga = _liga.mitBegegnung(begegnung);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_liga.name),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.groups, size: 32),
                text: 'Teams',
              ),
              Tab(
                icon: Icon(Icons.sports_soccer, size: 32),
                text: 'Begegnungen',
              ),
              Tab(
                icon: Icon(Icons.leaderboard, size: 32),
                text: 'Tabelle',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TeamsTab(liga: _liga),
            BegegnungenTab(
              liga: _liga,
              onBegegnungGeaendert: _begegnungGeaendert,
            ),
            TabelleTab(liga: _liga),
          ],
        ),
      ),
    );
  }
}
