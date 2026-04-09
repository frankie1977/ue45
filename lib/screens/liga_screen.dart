import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/sample_data.dart';
import 'package:ue45x/screens/begegnungen_tab.dart';
import 'package:ue45x/screens/tabelle_tab.dart';
import 'package:ue45x/screens/teams_tab.dart';

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

  void _ligaGeaendert(Liga liga) {
    setState(() {
      _liga = liga;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: .start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TabelleTab(liga: _liga),
            ),
            const VerticalDivider(width: 1),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
