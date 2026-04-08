import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/widgets/spiel_detail.dart';

class BegegnungRow extends StatefulWidget {
  const BegegnungRow({
    required this.begegnung,
    required this.heimLinks,
    required this.onBegegnungGeaendert,
    super.key,
  });

  final Begegnung begegnung;
  final bool heimLinks;
  final void Function(Begegnung) onBegegnungGeaendert;

  @override
  State<BegegnungRow> createState() => _BegegnungRowState();
}

class _BegegnungRowState extends State<BegegnungRow> {
  bool _expanded = false;

  void _satzSetzen(SpielSlot slot, int satzIndex, Satz satz) {
    final spiel = widget.begegnung.spielAt(slot);
    if (spiel == null) {
      return;
    }
    final Spiel neuesSpiel = switch (spiel) {
      Einzel(:final heimSpieler, :final gastSpieler) => Einzel(
        heimSpieler: heimSpieler,
        gastSpieler: gastSpieler,
        satz: satz,
      ),
      Doppel(:final heimSpieler, :final gastSpieler, :final saetze) => Doppel(
        heimSpieler: heimSpieler,
        gastSpieler: gastSpieler,
        saetze: _saetzeAktualisiert(saetze, satzIndex, satz),
      ),
    };
    widget.onBegegnungGeaendert(
      widget.begegnung.mitSpiel(slot, neuesSpiel),
    );
  }

  void _spielerSetzen(SpielSlot slot, Spiel neuesSpiel) {
    widget.onBegegnungGeaendert(widget.begegnung.mitSpiel(slot, neuesSpiel));
  }

  void _satzLoeschen(SpielSlot slot, int satzIndex) {
    final spiel = widget.begegnung.spielAt(slot);
    if (spiel == null) {
      return;
    }
    final Spiel neuesSpiel = switch (spiel) {
      Einzel(:final heimSpieler, :final gastSpieler) => Einzel(
        heimSpieler: heimSpieler,
        gastSpieler: gastSpieler,
      ),
      Doppel(:final heimSpieler, :final gastSpieler, :final saetze) => Doppel(
        heimSpieler: heimSpieler,
        gastSpieler: gastSpieler,
        saetze: [
          for (int k = 0; k < saetze.length; k++)
            if (k != satzIndex) saetze[k],
        ],
      ),
    };
    widget.onBegegnungGeaendert(
      widget.begegnung.mitSpiel(slot, neuesSpiel),
    );
  }

  List<Satz> _saetzeAktualisiert(List<Satz> existing, int index, Satz neu) {
    final updated = List<Satz>.from(existing);
    if (index < updated.length) {
      updated[index] = neu;
    } else {
      updated.add(neu);
    }
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = widget.begegnung.istAbgeschlossen;
    final heimLinks = widget.heimLinks;

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
    final toreLinks = heimLinks
        ? widget.begegnung.toreHeim
        : widget.begegnung.toreGast;
    final toreRechts = heimLinks
        ? widget.begegnung.toreGast
        : widget.begegnung.toreHeim;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            _expanded = !_expanded;
          }),
          child: Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: .end,
                    children: [
                      // Text(
                      //   'Begegnung',
                      //   style: theme.textTheme.bodyMedium,
                      // ),
                      Text(
                        linksName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Expanded(
                        child: Text(
                          scoreLinks == 0 && scoreRechts == 0 && !done
                              ? '–'
                              : '$scoreLinks',
                          textAlign: .right,
                          style: done
                              ? theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: .bold,
                                  color: theme.colorScheme.primary,
                                )
                              : theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                        ),
                      ),
                      Text(
                        ' : ',
                        style: done
                            ? theme.textTheme.titleSmall?.copyWith(
                                fontWeight: .bold,
                                color: theme.colorScheme.primary,
                              )
                            : theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                      ),
                      Expanded(
                        child: Text(
                          scoreLinks == 0 && scoreRechts == 0 && !done
                              ? '–'
                              : '$scoreRechts',
                          style: done
                              ? theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: .bold,
                                  color: theme.colorScheme.primary,
                                )
                              : theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                        ),
                      ),
                    ],
                  ),
                  // child: Text(
                  //   scoreLinks == 0 && scoreRechts == 0 && !done
                  //       ? '– : –'
                  //       : '$scoreLinks : $scoreRechts',
                  //   textAlign: .center,
                  //   style: done
                  //       ? theme.textTheme.titleSmall?.copyWith(
                  //           fontWeight: .bold,
                  //           color: theme.colorScheme.primary,
                  //         )
                  //       : theme.textTheme.bodyMedium?.copyWith(
                  //           color: theme.colorScheme.outline,
                  //         ),
                  // ),
                ),
                Expanded(
                  child: Text(
                    rechtsName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          ...SpielSlot.values.expand((slot) {
            return [
              const Divider(height: 1, indent: 16, endIndent: 16),
              SpielDetail(
                slot: slot,
                spiel: widget.begegnung.spielAt(slot),
                heimLinks: heimLinks,
                linksTeam: heimLinks
                    ? widget.begegnung.heimTeam
                    : widget.begegnung.gastTeam,
                rechtsTeam: heimLinks
                    ? widget.begegnung.gastTeam
                    : widget.begegnung.heimTeam,
                onSatzGesetzt: (satzIndex, satz) =>
                    _satzSetzen(slot, satzIndex, satz),
                onSatzGeloescht: (satzIndex) => _satzLoeschen(slot, satzIndex),
                onSpielerGeandert: (neuesSpiel) =>
                    _spielerSetzen(slot, neuesSpiel),
              ),
            ];
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(),
                ),
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Expanded(
                        child: Text(
                          '$toreLinks',
                          textAlign: .right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      Text(
                        ' : ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$toreRechts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
