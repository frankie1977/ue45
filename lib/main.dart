import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/sample_data.dart';
import 'package:ue45x/screens/liga_screen.dart';
import 'package:ue45x/screens/login_screen.dart';
import 'package:ue45x/services/ergebnis_log.dart';
import 'package:ue45x/services/liga_speicher_fallback.dart';
import 'package:ue45x/services/liga_speicher_lokal.dart';
import 'package:ue45x/services/liga_speicher_supabase.dart';

const String _supabaseUrl = 'https://xnbdjjhzijorxijffron.supabase.co';
const String _supabaseAnonKey =
    'sb_publishable_8rlkviw-eypT8ejMyize3A_lpPaxtSy';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Defensiv: schlaegt die Init offline fehl, startet die App trotzdem mit
  // dem lokalen Cache. Die eigentlichen Netzwerk-Calls fangen wir spaeter ab.
  try {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  } catch (_) {
    // Offline beim Start - weiter mit lokalem Fallback.
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  ErgebnisLog.initialisieren(
    prefs,
  );

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

  runApp(
    MyApp(
      prefs: prefs,
    ),
  );
}

TextTheme _robotoTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: GoogleFonts.roboto(fontSize: 86, fontWeight: .bold,),
    displayMedium: GoogleFonts.roboto(fontSize: 68, fontWeight: .bold,),
    displaySmall: GoogleFonts.roboto(fontSize: 58, fontWeight: .bold,),
    headlineLarge: GoogleFonts.roboto(fontSize: 48, fontWeight: .w600,),
    headlineMedium: GoogleFonts.roboto(fontSize: 42, fontWeight: .w600,),
    headlineSmall: GoogleFonts.roboto(fontSize: 34, fontWeight: .w600,),
    titleLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: .w600,),
    titleMedium: GoogleFonts.roboto(fontSize: 26, fontWeight: .w500,),
    titleSmall: GoogleFonts.roboto(fontSize: 22, fontWeight: .w500,),
    bodyLarge: GoogleFonts.roboto(fontSize: 24,),
    bodyMedium: GoogleFonts.roboto(fontSize: 24,),
    bodySmall: GoogleFonts.roboto(fontSize: 20,),
    labelLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: .w500,),
    labelMedium: GoogleFonts.roboto(fontSize: 20,),
    labelSmall: GoogleFonts.roboto(fontSize: 18,),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.prefs,
    super.key,
  });

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        textTheme: _robotoTextTheme(GoogleFonts.robotoTextTheme(),),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Color(0xFF263238),
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: _robotoTextTheme(
          GoogleFonts.robotoTextTheme(
            ThemeData(brightness: Brightness.dark,).textTheme,
          ),
        ),
      ),
      home: _AppRoot(
        prefs: prefs,
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot({
    required this.prefs,
  });

  final SharedPreferences prefs;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  
  bool _angemeldet = true;

  late final LigaSpeicherFallback _speicher = LigaSpeicherFallback(
    remote: LigaSpeicherSupabase(
      Supabase.instance.client,
    ),
    lokal: LigaSpeicherLokal(
      widget.prefs,
    ),
  );
  StreamSubscription<Liga?>? _abonnement;

  Liga? _liga;

  @override
  void initState() {
    super.initState();
    _abonnement = _speicher
        .aenderungen(
          'Ü45-Liga 2026',
        )
        .listen(
          _onLigaUpdate,
          onError: (Object fehler) {
            // Stream-Fehler darf den App-Zustand nicht zerstoeren; der
            // Fallback schaltet bereits auf Offline um.
          },
        );
  }

  void _onLigaUpdate(
    Liga? liga,
  ) {
    if (liga == null) {
      // Sample-Daten NUR seeden, wenn Supabase online bestaetigt leer ist.
      // Offline duerfen wir nichts schreiben (sonst Datenverlust-Gefahr).
      if (!_speicher.istOffline.value) {
        _speicher.speichern(
          buildSampleLiga(),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _liga = liga;
    });
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    _speicher.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!_angemeldet) {
      return LoginScreen(
        onAuthenticated: () {
          setState(() {
            _angemeldet = true;
          });
        },
      );
    }
    final Liga? liga = _liga;
    return ValueListenableBuilder<bool>(
      valueListenable: _speicher.istOffline,
      builder: (context, offline, child) {
        final Widget inhalt = liga == null
            ? Scaffold(
                body: Center(
                  child: offline
                      ? const Padding(
                          padding: EdgeInsets.all(
                            24,
                          ),
                          child: Text(
                            'Supabase nicht erreichbar und keine lokale '
                            'Kopie vorhanden.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              )
            : LigaScreen(
                speicher: _speicher,
                liga: liga,
              );
        return Column(
          children: [
            if (offline)
              const _OfflineBanner(),
            Expanded(
              child: inhalt,
            ),
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.orange.shade900,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: const [
              Icon(
                Icons.cloud_off,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  'Offline – Ergebnisse werden lokal gespeichert und '
                  'automatisch synchronisiert, sobald die Verbindung '
                  'zurück ist.',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
