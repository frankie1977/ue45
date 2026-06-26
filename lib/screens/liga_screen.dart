import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/screens/begegnungen_tab.dart';
import 'package:ue45x/screens/tabelle_tab.dart';
import 'package:ue45x/screens/teams_tab.dart';
import 'package:ue45x/screens/tische_tab.dart';
import 'package:ue45x/services/liga_speicher.dart';
import 'package:ue45x/widgets/ergebnis_log_view.dart';
import 'package:ue45x/widgets/tabelle/aktuelle_spiele.dart';
import 'package:ue45x/widgets/tabelle/letzte_ergebnisse.dart';
import 'package:ue45x/widgets/tabelle/spieler_top_liste.dart';
import 'package:ue45x/widgets/tabelle/tabelle_header.dart';
import 'package:ue45x/widgets/tabelle/tabelle_row.dart';

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
  bool _viewModus = false;

  /// Aufgeklappte Begegnungen (per id). Liegt im Screen, damit der Zustand
  /// Tab-Wechsel und View-Modus übersteht.
  final Set<String> _expandedBegegnungIds = {};

  void _begegnungExpandToggle(String begegnungId) {
    setState(() {
      if (!_expandedBegegnungIds.remove(begegnungId)) {
        _expandedBegegnungIds.add(begegnungId);
      }
    });
  }

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

  Widget _titelMitUmschalter(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10,),
          child: Text(
            _liga.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: .bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 10,),
          child: Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.receipt_long,
                ),
                tooltip: 'Ergebnis-Log',
                onPressed: () {
                  oeffneErgebnisLog(context);
                },
              ),
              IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(
                  _viewModus ? Icons.edit : Icons.visibility,
                ),
                tooltip: _viewModus ? 'Bearbeiten' : 'Anzeigemodus',
                onPressed: () {
                  setState(() {
                    _viewModus = !_viewModus;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewModus(BuildContext context) {
    final teams = _liga.tabelle;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(1.4),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _titelMitUmschalter(context),
          const Divider(height: 1,),
          Expanded(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const SizedBox(height: 8,),
                        AktuelleSpiele(liga: _liga, viewModus: true,),
                        const SizedBox(height: 8,),
                        LetzteErgebnisse(liga: _liga, viewModus: true,),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1,),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0,),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                const TabelleHeader(),
                                const Divider(height: 1,),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: teams.length,
                                  separatorBuilder: (
                                    BuildContext ctx,
                                    int i,
                                  ) {
                                    return const Divider(height: 1,);
                                  },
                                  itemBuilder: (
                                    BuildContext ctx,
                                    int index,
                                  ) {
                                    return TabelleRow(
                                      rang: index + 1,
                                      team: teams[index],
                                      liga: _liga,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        SpielerTopListe(liga: _liga,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditModus(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.sports_soccer, size: 32,),
                    text: 'Spiele',
                  ),
                  Tab(
                    icon: Icon(Icons.groups, size: 32,),
                    text: 'Anmeldung',
                  ),
                  Tab(
                    icon: Icon(Icons.table_restaurant, size: 32,),
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
                      expandedIds: _expandedBegegnungIds,
                      onExpandToggle: _begegnungExpandToggle,
                    ),
                    TeamsTab(liga: _liga, onLigaGeaendert: _ligaGeaendert,),
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
        const VerticalDivider(width: 1,),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.7,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              _titelMitUmschalter(context),
              Expanded(
                child: TabelleTab(liga: _liga,),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: _viewModus
            ? _buildViewModus(context)
            : _buildEditModus(context),
      ),
    );
  }
}
