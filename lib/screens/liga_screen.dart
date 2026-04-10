import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/screens/begegnungen_tab.dart';
import 'package:ue45x/screens/tabelle_tab.dart';
import 'package:ue45x/screens/teams_tab.dart';
import 'package:ue45x/screens/tische_tab.dart';
import 'package:ue45x/services/liga_speicher.dart';

class LigaScreen extends StatefulWidget {
  const LigaScreen({
    required this.speicher,
    required this.liga,
    super.key,
  });

  final LigaSpeicher speicher;
  final Liga liga;

  @override
  State<LigaScreen> createState() => _LigaScreenState();
}

class _LigaScreenState extends State<LigaScreen> {
  late Liga _liga;

  @override
  void initState() {
    super.initState();
    _liga = widget.liga;
  }

  @override
  void didUpdateWidget(
    LigaScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liga != widget.liga) {
      setState(() {
        _liga = widget.liga;
      });
    }
  }

  void _begegnungGeaendert(Begegnung begegnung) {
    setState(() {
      final warAbgeschlossen = _liga.begegnungen.firstWhere((b) {
        return b.id == begegnung.id;
      }).istAbgeschlossen;

      Liga neueLiga = _liga.mitBegegnung(begegnung);

      final tisch = begegnung.tisch;
      if (!warAbgeschlossen && begegnung.istAbgeschlossen && tisch != null) {
        final naechste = neueLiga.begegnungen.where((b) {
          return b.tisch == null;
        }).firstOrNull;
        if (naechste != null) {
          neueLiga = neueLiga.mitBegegnung(
            naechste.mitTisch(
              tisch,
            ),
          );
        }
      }

      _liga = neueLiga;
    });
    widget.speicher.speichern(_liga);
  }

  void _ligaGeaendert(Liga liga) {
    setState(() {
      _liga = liga;
    });
    widget.speicher.speichern(_liga);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: .start,
          children: [

            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.sports_soccer, size: 32),
                        text: 'Spiele',
                      ),
                      Tab(
                        icon: Icon(Icons.groups, size: 32),
                        text: 'Anmeldung',
                      ),
                      Tab(
                        icon: Icon(Icons.table_restaurant, size: 32),
                        text: 'Tische',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        BegegnungenTab(
                          liga: _liga,
                          onBegegnungGeaendert: _begegnungGeaendert,
                        ),
                        TeamsTab(liga: _liga, onLigaGeaendert: _ligaGeaendert),
                        TischeTab(
                          liga: _liga,
                          onLigaGeaendert: _ligaGeaendert,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: .only(left: 20, top: 20, bottom: 10),
                  child: Text(
                    _liga.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: .bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2.7,
                    child: TabelleTab(liga: _liga),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
