import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/tisch.dart';
import 'package:ue45x/widgets/tabelle/begegnung_info.dart';

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

  ({Begegnung? beg, SpielSlot? slot, Spieltag? spieltag}) _aktivFuerTisch(
    Tisch tisch,
  ) {
    for (final st in liga.alleSpieltage) {
      for (final beg in st.begegnungen) {
        if (beg.tisch?.id != tisch.id) {
          continue;
        }
        if (beg.istAbgeschlossen) {
          continue;
        }
        for (final slot in SpielSlot.values) {
          final spiel = beg.spielAt(slot);
          if (spiel == null || !spiel.istAbgeschlossen) {
            return (beg: beg, slot: slot, spieltag: st);
          }
        }
        return (beg: beg, slot: null, spieltag: st);
      }
    }
    return (beg: null, slot: null, spieltag: null);
  }

  String _einzelName(Spieler? spieler) => spieler?.name ?? '?';

  String _doppelNamen(List<Spieler> spieler) {
    if (spieler.isEmpty) {
      return '?';
    }
    return spieler
        .map((s) {
          return s.name;
        })
        .join(' & ');
  }

  (String links, String rechts) _spielerTexte(
    Spiel? spiel,
    bool heimLinks,
  ) {
    return switch (spiel) {
      null => ('?', '?'),
      Einzel(:final heimSpieler, :final gastSpieler) =>
        heimLinks
            ? (_einzelName(heimSpieler), _einzelName(gastSpieler))
            : (_einzelName(gastSpieler), _einzelName(heimSpieler)),
      Doppel(:final heimSpieler, :final gastSpieler) =>
        heimLinks
            ? (_doppelNamen(heimSpieler), _doppelNamen(gastSpieler))
            : (_doppelNamen(gastSpieler), _doppelNamen(heimSpieler)),
    };
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (liga.tische.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final heimLinksMap = _heimLinksMap();
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.outline,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        elevation: 2,
        surfaceTintColor: Colors.lightGreen,
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
                'Aktuelle Spiele',
                style: labelStyle,
              ),
            ),
            const Divider(height: 1),
            ...liga.tische.indexed.expand(
              ((int, Tisch) entry) {
                final idx = entry.$1;
                final tisch = entry.$2;
                final (:beg, :slot, :spieltag) = _aktivFuerTisch(tisch);

                return [
                  if (idx > 0) const Divider(height: 1),
                  Padding(
                    padding: const .only(
                      left: 8,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              Chip(
                                backgroundColor: theme.colorScheme.primary,
                                shape: StadiumBorder(),
                                label: Text(
                                  tisch.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),

                              if (spieltag != null)
                                Text(
                                  'Tag ${spieltag.nummer}',
                                  style: labelStyle,
                                ),
                            ],
                          ),
                        ),
                        if (beg == null)
                          Expanded(
                            child: Text(
                              textAlign: .center,
                              '(frei)',
                              style: labelStyle,
                            ),
                          )
                        else
                          Expanded(
                            child: BegegnungInfo(
                              beg: beg,
                              slot: slot,
                              heimLinks: heimLinksMap[beg.id] ?? true,
                              spielerTexte: _spielerTexte,
                            ),
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
