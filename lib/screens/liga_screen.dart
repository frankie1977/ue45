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
        // appBar: AppBar(
        //   title: Text(_liga.name),
        // ),
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TabelleTab(liga: _liga),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.sports_soccer, size: 32),
                        text: 'Begegnungen',
                      ),
                      Tab(
                        icon: Icon(Icons.groups, size: 32),
                        text: 'Teams',
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