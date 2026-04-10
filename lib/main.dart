import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ue45x/screens/liga_screen.dart';
import 'package:ue45x/screens/login_screen.dart';
import 'package:ue45x/services/liga_speicher.dart';
import 'package:window_manager/window_manager.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // if (isDesktop()) {
  //   await windowManager.ensureInitialized();
  //   final WindowOptions windowOptions = const WindowOptions(
  //     size: Size(800, 600),
  //     center: true,
  //   );
  //   windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.maximize();
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }

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
      home: const _AppRoot(),
    );
  }
}

bool isDesktop() {
  return !kIsWeb &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _angemeldet = true;
  final LigaSpeicher _speicher = LigaSpeicherStub();

  @override
  Widget build(BuildContext context) {
    if (_angemeldet) {
      return LigaScreen(speicher: _speicher,);
    }
    return LoginScreen(
      onAuthenticated: () {
        setState(() {
          _angemeldet = true;
        });
      },
    );
  }
}
