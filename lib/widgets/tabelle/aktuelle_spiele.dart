import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';

class AktuelleSpiele extends StatelessWidget {
  const AktuelleSpiele({
    required this.liga,
    super.key,
  });

  final Liga liga;

  Map<String, bool> _heimLinksMap() {
    final result = <String, bool>{};
    int idx = 0;
    for (final st in liga.hinrunde) {
      for (final beg in st.begegnungen) {
        result[beg.id] = idx.isEven;
        idx++;
      }
    }
    idx = 0;
    for (final st in liga.rueckrunde) {
      for (final beg in st.begegnungen) {
        result[beg.id] = idx.isEven;
        idx++;
      }
    }
    return result;
  }

  List<({Begegnung beg, SpielSlot slot})> _aktuelleGames() {
    final seen = <String>{};
    final result = <({Begegnung beg, SpielSlot slot})>[];
    for (final team in liga.teams) {
      bool gefunden = false;
      for (final spieltag in liga.alleSpieltage) {
        if (gefunden) {
          break;
        }
        for (final beg in spieltag.begegnungen) {
          if (beg.heimTeam.id == team.id || beg.gastTeam.id == team.id) {
            if (!beg.istAbgeschlossen) {
              gefunden = true;
              if (!seen.contains(beg.id)) {
                seen.add(beg.id);
                for (final slot in SpielSlot.values) {
                  final spiel = beg.spielAt(slot);
                  if (spiel == null || !spiel.istAbgeschlossen) {
                    result.add((beg: beg, slot: slot));
                    break;
                  }
                }
              }
            }
            break;
          }
        }
      }
    }
    return result;
  }

  String _spielerName(Spieler? spieler) {
    return spieler?.name ?? '–';
  }

  String _spielerNamen(List<Spieler> spieler) {
    if (spieler.isEmpty) {
      return '–';
    }
    return spieler.map((s) {
      return s.name;
    }).join(' & ');
  }

  @override
  Widget build(BuildContext context) {
    final spiele = _aktuelleGames();
    if (spiele.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final heimLinksMap = _heimLinksMap();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Text(
                'Nächste Spiele',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const Divider(height: 1),
            ...spiele.indexed.expand(
              ((int, ({Begegnung beg, SpielSlot slot})) e) {
                final idx = e.$1;
                final beg = e.$2.beg;
                final slot = e.$2.slot;
                final heimLinks = heimLinksMap[beg.id] ?? true;
                final spiel = beg.spielAt(slot);

                final linksTeamName = heimLinks
                    ? beg.heimTeam.name
                    : beg.gastTeam.name;
                final rechtsTeamName = heimLinks
                    ? beg.gastTeam.name
                    : beg.heimTeam.name;

                final String linksText;
                final String rechtsText;
                switch (spiel) {
                  case null:
                    linksText = '–';
                    rechtsText = '–';
                  case Einzel(:final heimSpieler, :final gastSpieler):
                    linksText = heimLinks
                        ? _spielerName(heimSpieler)
                        : _spielerName(gastSpieler);
                    rechtsText = heimLinks
                        ? _spielerName(gastSpieler)
                        : _spielerName(heimSpieler);
                  case Doppel(:final heimSpieler, :final gastSpieler):
                    linksText = heimLinks
                        ? _spielerNamen(heimSpieler)
                        : _spielerNamen(gastSpieler);
                    rechtsText = heimLinks
                        ? _spielerNamen(gastSpieler)
                        : _spielerNamen(heimSpieler);
                }

                return [
                  if (idx > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                linksTeamName,
                                textAlign: .right,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                slot.label,
                                textAlign: .center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                rechtsTeamName,
                                textAlign: .left,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                linksText,
                                textAlign: .right,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                'vs',
                                textAlign: .center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                rechtsText,
                                textAlign: .left,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
