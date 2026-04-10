import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/tisch.dart';
import 'package:ue45x/widgets/begegnungen/spiel_detail.dart';

class BegegnungRow extends StatefulWidget {
  const BegegnungRow({
    required this.begegnung,
    required this.heimLinks,
    required this.tische,
    required this.onBegegnungGeaendert,
    super.key,
  });

  final Begegnung begegnung;
  final bool heimLinks;
  final List<Tisch> tische;
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

  bool _hatZuwenigSpieler() {
    bool pruefeSeite({required bool istHeim}) {
      final Set<String> spielerIds = {};
      for (final slot in SpielSlot.values) {
        final spiel = widget.begegnung.spielAt(slot);
        switch (spiel) {
          case null:
            return false;
          case Einzel(:final heimSpieler, :final gastSpieler):
            final spieler = istHeim ? heimSpieler : gastSpieler;
            if (spieler == null) {
              return false;
            }
            spielerIds.add(spieler.id);
          case Doppel(:final heimSpieler, :final gastSpieler):
            final spieler = istHeim ? heimSpieler : gastSpieler;
            if (spieler.length != 2) {
              return false;
            }
            for (final s in spieler) {
              spielerIds.add(s.id);
            }
        }
      }
      return spielerIds.length < 5;
    }

    return pruefeSeite(istHeim: true) || pruefeSeite(istHeim: false);
  }

  Set<SpielSlot> _duplikatPaarungSlots() {
    final Map<String, List<SpielSlot>> paarungen = {};
    for (final slot in SpielSlot.values) {
      final spiel = widget.begegnung.spielAt(slot);
      if (spiel is! Doppel) {
        continue;
      }
      if (spiel.heimSpieler.length == 2) {
        final ids = [spiel.heimSpieler[0].id, spiel.heimSpieler[1].id]..sort();
        final key = 'heim:${ids[0]}:${ids[1]}';
        paarungen
            .putIfAbsent(key, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
      if (spiel.gastSpieler.length == 2) {
        final ids = [spiel.gastSpieler[0].id, spiel.gastSpieler[1].id]..sort();
        final key = 'gast:${ids[0]}:${ids[1]}';
        paarungen
            .putIfAbsent(key, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
    }
    final result = <SpielSlot>{};
    for (final slots in paarungen.values) {
      if (slots.length > 1) {
        result.addAll(slots);
      }
    }
    return result;
  }

  Set<SpielSlot> _zuvielDoppelSlots() {
    final Map<String, List<SpielSlot>> heim = {};
    final Map<String, List<SpielSlot>> gast = {};
    for (final slot in SpielSlot.values) {
      if (!slot.istDoppel) {
        continue;
      }
      final spiel = widget.begegnung.spielAt(slot);
      if (spiel is! Doppel) {
        continue;
      }
      for (final s in spiel.heimSpieler) {
        heim
            .putIfAbsent(s.id, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
      for (final s in spiel.gastSpieler) {
        gast
            .putIfAbsent(s.id, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
    }
    final result = <SpielSlot>{};
    for (final slots in heim.values) {
      if (slots.length > 2) {
        result.addAll(slots);
      }
    }
    for (final slots in gast.values) {
      if (slots.length > 2) {
        result.addAll(slots);
      }
    }
    return result;
  }

  Set<SpielSlot> _duplikatEinzelSpielerSlots() {
    final Map<String, List<SpielSlot>> heim = {};
    final Map<String, List<SpielSlot>> gast = {};
    for (final slot in SpielSlot.values) {
      final spiel = widget.begegnung.spielAt(slot);
      if (spiel is! Einzel) {
        continue;
      }
      if (spiel.heimSpieler != null) {
        heim
            .putIfAbsent(spiel.heimSpieler!.id, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
      if (spiel.gastSpieler != null) {
        gast
            .putIfAbsent(spiel.gastSpieler!.id, () {
              return <SpielSlot>[];
            })
            .add(slot);
      }
    }
    final result = <SpielSlot>{};
    for (final slots in heim.values) {
      if (slots.length > 1) {
        result.addAll(slots);
      }
    }
    for (final slots in gast.values) {
      if (slots.length > 1) {
        result.addAll(slots);
      }
    }
    return result;
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

  Future<void> _tischWaehlen() async {
    if (widget.tische.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erst Tische im Reiter "Tische" anlegen.'),
        ),
      );
      return;
    }
    final result = await showDialog<({Tisch? tisch})>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Tisch wählen'),
          children: [
            ...widget.tische.map((t) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(ctx, (tisch: t));
                },
                child: Text(
                  t.name,
                  style: widget.begegnung.tisch == t
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              );
            }),
            if (widget.begegnung.tisch != null) ...[
              const Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(ctx, (tisch: null));
                },
                child: Text(
                  'Kein Tisch',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
    if (result != null) {
      widget.onBegegnungGeaendert(
        widget.begegnung.mitTisch(
          result.tisch,
        ),
      );
    }
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

    final duplikatSlots = _duplikatPaarungSlots();
    final duplikatEinzelSlots = _duplikatEinzelSpielerSlots();
    final zuvielDoppelSlots = _zuvielDoppelSlots();
    final zuwenigSpielerWarnung = _hatZuwenigSpieler();

    final hatDoppelteSpielerInIrgendemSpiel = SpielSlot.values.any((slot) {
      final spiel = widget.begegnung.spielAt(slot);
      return switch (spiel) {
        Doppel(:final heimSpieler, :final gastSpieler) =>
          (heimSpieler.length == 2 && heimSpieler[0].id == heimSpieler[1].id) ||
              (gastSpieler.length == 2 &&
                  gastSpieler[0].id == gastSpieler[1].id),
        _ => false,
      };
    });
    final hatWarnung =
        duplikatSlots.isNotEmpty ||
        duplikatEinzelSlots.isNotEmpty ||
        zuvielDoppelSlots.isNotEmpty ||
        zuwenigSpielerWarnung ||
        hatDoppelteSpielerInIrgendemSpiel;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 16,
                        color: widget.begegnung.tisch == null
                            ? theme.colorScheme.outline.withValues(alpha: 0.4)
                            : theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: .end,
                    children: [
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
                ),
                Expanded(
                  child: Text(
                    rechtsName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: .bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: .end,
                    children: [
                      InkWell(
                        onTap: _tischWaehlen,
                        child: widget.begegnung.tisch == null
                            ? Text(
                                'Tisch',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Chip(
                                backgroundColor: theme.colorScheme.primary,
                                shape: StadiumBorder(),
                                label: Text(
                                  widget.begegnung.tisch!.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                      ),
                    ],
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
                onSatzGesetzt: (satzIndex, satz) {
                  _satzSetzen(slot, satzIndex, satz);
                },
                onSatzGeloescht: (satzIndex) {
                  _satzLoeschen(slot, satzIndex);
                },
                onSpielerGeandert: (neuesSpiel) {
                  _spielerSetzen(slot, neuesSpiel);
                },
                hatDoppeltePaarung: duplikatSlots.contains(slot),
                hatDuplikatEinzel: duplikatEinzelSlots.contains(slot),
                hatZuvielDoppel: zuvielDoppelSlots.contains(slot),
                hatZuwenigSpieler:
                    slot == SpielSlot.d4 && zuwenigSpielerWarnung,
              ),
            ];
          }),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 30),
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
                const SizedBox(width: 28),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
