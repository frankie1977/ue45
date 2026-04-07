import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/team.dart';

class BegegnungenTab extends StatelessWidget {
  const BegegnungenTab({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    final hinrundeWidgets = liga.hinrunde.map((st) {
      final w = _SpieltagSection(
        spieltag: st,
        startIndex: index,
      );
      index += st.begegnungen.length;
      return w;
    }).toList();
    // Rückrunde spiegelt die Hinrunde-Indizes, damit jedes Team
    // im Rückspiel auf der entgegengesetzten Seite erscheint.
    index = 0;
    final rueckrundeWidgets = liga.rueckrunde.map((st) {
      final w = _SpieltagSection(
        spieltag: st,
        startIndex: index,
      );
      index += st.begegnungen.length;
      return w;
    }).toList();

    return ListView(
      children: [
        _RundeHeader(titel: 'Hinrunde'),
        ...hinrundeWidgets,
        _RundeHeader(titel: 'Rückrunde'),
        ...rueckrundeWidgets,
      ],
    );
  }
}

class _RundeHeader extends StatelessWidget {
  const _RundeHeader({required this.titel});

  final String titel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        4,
      ),
      child: Text(
        titel,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SpieltagSection extends StatelessWidget {
  const _SpieltagSection({
    required this.spieltag,
    required this.startIndex,
  });

  final Spieltag spieltag;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    final abgeschlossen = spieltag.begegnungen.every((b) => b.istAbgeschlossen);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Spieltag ${spieltag.nummer}',
                  ),
                ),
                if (abgeschlossen)
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    size: 18,
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
          ),
          ...spieltag.begegnungen.indexed.map(
            ((int, Begegnung) e) => _BegegnungRow(
              begegnung: e.$2,
              heimLinks: (startIndex + e.$1).isEven,
            ),
          ),
          if (spieltag.freilos != null) _FreilosRow(team: spieltag.freilos!),
          const SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }
}

class _BegegnungRow extends StatefulWidget {
  const _BegegnungRow({
    required this.begegnung,
    required this.heimLinks,
  });

  final Begegnung begegnung;
  final bool heimLinks;

  @override
  State<_BegegnungRow> createState() => _BegegnungRowState();
}

class _BegegnungRowState extends State<_BegegnungRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = widget.begegnung.istAbgeschlossen;
    final heimLinks = widget.heimLinks;

    final linksPunkte = heimLinks
        ? widget.begegnung.ligapunkteHeim
        : widget.begegnung.ligapunkteGast;
    final rechtsGewonnen = heimLinks
        ? widget.begegnung.ligapunkteGast == 2
        : widget.begegnung.ligapunkteHeim == 2;
    final linksName = heimLinks
        ? widget.begegnung.heimTeam.name
        : widget.begegnung.gastTeam.name;
    final rechtsName = heimLinks
        ? widget.begegnung.gastTeam.name
        : widget.begegnung.heimTeam.name;
    final scoreLinks = heimLinks
        ? widget.begegnung.satzpunkteHeim
        : widget.begegnung.satzpunkteGast;
    final scoreRechts = heimLinks
        ? widget.begegnung.satzpunkteGast
        : widget.begegnung.satzpunkteHeim;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    linksName,
                    textAlign: TextAlign.end,
                    style: done && linksPunkte == 2
                        ? theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : theme.textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    done ? '$scoreLinks : $scoreRechts' : '– : –',
                    textAlign: TextAlign.center,
                    style: done
                        ? theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rechtsName,
                    style: done && rechtsGewonnen
                        ? theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          ...SpielSlot.values.expand((slot) {
            final spiel = widget.begegnung.spielAt(slot);
            return [
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _SpielDetail(
                slot: slot,
                spiel: spiel,
                heimLinks: heimLinks,
              ),
            ];
          }),
          const SizedBox(
            height: 26,
          ),
        ],
      ],
    );
  }
}

class _SpielDetail extends StatelessWidget {
  const _SpielDetail({
    required this.slot,
    required this.spiel,
    required this.heimLinks,
  });

  final SpielSlot slot;
  final Spiel? spiel;
  final bool heimLinks;

  String _name(Spieler s) => s.name;

  String _doppelNames(List<Spieler> spieler) => spieler.map(_name).join(' & ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String linksNames;
    final String rechtsNames;
    final List<Satz> saetze;

    switch (spiel) {
      case null:
        linksNames = '–';
        rechtsNames = '–';
        saetze = [];
      case Einzel(:final heimSpieler, :final gastSpieler, :final satz):
        linksNames = heimLinks ? _name(heimSpieler) : _name(gastSpieler);
        rechtsNames = heimLinks ? _name(gastSpieler) : _name(heimSpieler);
        saetze = satz != null ? [satz] : [];
      case Doppel(
        :final heimSpieler,
        :final gastSpieler,
        saetze: final doppelSaetze,
      ):
        linksNames = heimLinks
            ? _doppelNames(heimSpieler)
            : _doppelNames(gastSpieler);
        rechtsNames = heimLinks
            ? _doppelNames(gastSpieler)
            : _doppelNames(heimSpieler);
        saetze = doppelSaetze;
    }

    final rowCount = saetze.isEmpty ? 1 : saetze.length;

    return Column(
      children: List.generate(rowCount, (i) {
        final satz = saetze.isEmpty ? null : saetze[i];
        final linksScore = satz != null
            ? (heimLinks ? satz.heimTore : satz.gastTore)
            : null;
        final rechtsScore = satz != null
            ? (heimLinks ? satz.gastTore : satz.heimTore)
            : null;
        final scoreText = linksScore != null
            ? '$linksScore : $rechtsScore'
            : '– : –';

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: i == 0
                    ? Text(
                        slot.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: i == 0
                    ? Text(
                        linksNames,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall,
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  scoreText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: i == 0
                    ? Text(
                        rechtsNames,
                        style: theme.textTheme.bodySmall,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FreilosRow extends StatelessWidget {
  const _FreilosRow({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            'Freilos: ${team.name}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
