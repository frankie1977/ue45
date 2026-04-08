import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/team.dart';

class BegegnungenTab extends StatefulWidget {
  const BegegnungenTab({
    required this.liga,
    required this.onBegegnungGeaendert,
    super.key,
  });

  final Liga liga;
  final void Function(Begegnung) onBegegnungGeaendert;

  @override
  State<BegegnungenTab> createState() => _BegegnungenTabState();
}

class _BegegnungenTabState extends State<BegegnungenTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int index = 0;
    final hinrundeWidgets = widget.liga.hinrunde.map((st) {
      final w = _SpieltagSection(
        spieltag: st,
        startIndex: index,
        onBegegnungGeaendert: widget.onBegegnungGeaendert,
      );
      index += st.begegnungen.length;
      return w;
    }).toList();
    index = 0;
    final rueckrundeWidgets = widget.liga.rueckrunde.map((st) {
      final w = _SpieltagSection(
        spieltag: st,
        startIndex: index,
        onBegegnungGeaendert: widget.onBegegnungGeaendert,
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
    required this.onBegegnungGeaendert,
  });

  final Spieltag spieltag;
  final int startIndex;
  final void Function(Begegnung) onBegegnungGeaendert;

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
              onBegegnungGeaendert: onBegegnungGeaendert,
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
    required this.onBegegnungGeaendert,
  });

  final Begegnung begegnung;
  final bool heimLinks;
  final void Function(Begegnung) onBegegnungGeaendert;

  @override
  State<_BegegnungRow> createState() => _BegegnungRowState();
}

class _BegegnungRowState extends State<_BegegnungRow> {
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
          onTap: () => setState(() {
                _expanded = !_expanded;
              }),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    scoreLinks == 0 && scoreRechts == 0 && !done
                        ? '– : –'
                        : '$scoreLinks : $scoreRechts',
                    textAlign: TextAlign.center,
                    style: done
                        ? theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                          )
                        : theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rechtsName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _SpielDetail(
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
                onSatzGeloescht: (satzIndex) =>
                    _satzLoeschen(slot, satzIndex),
                onSpielerGeandert: (neuesSpiel) =>
                    _spielerSetzen(slot, neuesSpiel),
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
    required this.linksTeam,
    required this.rechtsTeam,
    required this.onSatzGesetzt,
    required this.onSatzGeloescht,
    required this.onSpielerGeandert,
  });

  final SpielSlot slot;
  final Spiel? spiel;
  final bool heimLinks;
  final Team linksTeam;
  final Team rechtsTeam;
  final void Function(int satzIndex, Satz satz) onSatzGesetzt;
  final void Function(int satzIndex) onSatzGeloescht;
  final void Function(Spiel neuesSpiel) onSpielerGeandert;

  Spiel _spielerAktualisieren(bool istHeim, int index, Spieler ausgewaehlt) {
    switch (spiel) {
      case null:
        return slot.istDoppel
            ? Doppel(
                heimSpieler: istHeim ? [ausgewaehlt] : [],
                gastSpieler: istHeim ? [] : [ausgewaehlt],
              )
            : Einzel(
                heimSpieler: istHeim ? ausgewaehlt : null,
                gastSpieler: istHeim ? null : ausgewaehlt,
              );
      case Einzel(:final heimSpieler, :final gastSpieler, :final satz):
        return Einzel(
          heimSpieler: istHeim ? ausgewaehlt : heimSpieler,
          gastSpieler: istHeim ? gastSpieler : ausgewaehlt,
          satz: satz,
        );
      case Doppel(:final heimSpieler, :final gastSpieler, :final saetze):
        final heim = List<Spieler>.from(heimSpieler);
        final gast = List<Spieler>.from(gastSpieler);
        final liste = istHeim ? heim : gast;
        if (index < liste.length) {
          liste[index] = ausgewaehlt;
        } else {
          liste.add(ausgewaehlt);
        }
        return Doppel(
          heimSpieler: heim,
          gastSpieler: gast,
          saetze: saetze,
        );
    }
  }

  Future<void> _spielerAuswaehlen(
    BuildContext context,
    Team team,
    bool istHeim,
    int index,
    Spieler? aktuell,
  ) async {
    final picked = await showDialog<Spieler>(
      context: context,
      builder: (ctx) => _SpielerPickerDialog(team: team, aktuell: aktuell),
    );
    if (picked != null) {
      onSpielerGeandert(_spielerAktualisieren(istHeim, index, picked));
    }
  }

  Widget _spielerWidget(
    BuildContext context, {
    required Spieler? spieler,
    required Team team,
    required bool istHeim,
    required int index,
    required TextAlign align,
  }) {
    final theme = Theme.of(context);
    if (spieler != null) {
      return InkWell(
        onTap: () =>
            _spielerAuswaehlen(context, team, istHeim, index, spieler),
        borderRadius: BorderRadius.circular(4),
        child: Text(
          spieler.name,
          textAlign: align,
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    return Align(
      alignment:
          align == TextAlign.end ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onTap: () => _spielerAuswaehlen(context, team, istHeim, index, null),
        borderRadius: BorderRadius.circular(12),
        child: Icon(
          Icons.add_circle_outline,
          size: 18,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Satz> saetze = switch (spiel) {
      null => [],
      Einzel(:final satz) => satz != null ? [satz] : [],
      Doppel(:final saetze) => saetze,
    };

    String seitenNames(List<Spieler> spieler) =>
        spieler.map((s) => s.name).join(' & ');

    final linksSpielerAll = switch (spiel) {
      null => '–',
      Einzel(:final heimSpieler, :final gastSpieler) =>
        (heimLinks ? heimSpieler : gastSpieler)?.name ?? '–',
      Doppel(:final heimSpieler, :final gastSpieler) =>
        seitenNames(heimLinks ? heimSpieler : gastSpieler),
    };

    final rechtsSpielerAll = switch (spiel) {
      null => '–',
      Einzel(:final heimSpieler, :final gastSpieler) =>
        (heimLinks ? gastSpieler : heimSpieler)?.name ?? '–',
      Doppel(:final heimSpieler, :final gastSpieler) =>
        seitenNames(heimLinks ? gastSpieler : heimSpieler),
    };

    final rowCount = slot.istDoppel ? 2 : 1;

    return Column(
      children: List.generate(rowCount, (i) {
        final Spieler? heimPlayer;
        final Spieler? gastPlayer;
        switch (spiel) {
          case null:
            heimPlayer = null;
            gastPlayer = null;
          case Einzel(:final heimSpieler, :final gastSpieler):
            heimPlayer = heimSpieler;
            gastPlayer = gastSpieler;
          case Doppel(:final heimSpieler, :final gastSpieler):
            heimPlayer = i < heimSpieler.length ? heimSpieler[i] : null;
            gastPlayer = i < gastSpieler.length ? gastSpieler[i] : null;
        }

        final linksPlayer = heimLinks ? heimPlayer : gastPlayer;
        final rechtsPlayer = heimLinks ? gastPlayer : heimPlayer;
        final linksIstHeim = heimLinks;

        final satz = i < saetze.length ? saetze[i] : null;
        final linksScore = satz != null
            ? (heimLinks ? satz.heimTore : satz.gastTore)
            : null;
        final rechtsScore = satz != null
            ? (heimLinks ? satz.gastTore : satz.heimTore)
            : null;
        final scoreText =
            linksScore != null ? '$linksScore : $rechtsScore' : '– : –';
        final titelSuffix = slot.istDoppel ? ' – Satz ${i + 1}' : '';
        final spielerKomplett =
            linksPlayer != null && rechtsPlayer != null;

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
                child: _spielerWidget(
                  context,
                  spieler: linksPlayer,
                  team: linksTeam,
                  istHeim: linksIstHeim,
                  index: i,
                  align: TextAlign.end,
                ),
              ),
              SizedBox(
                width: 80,
                child: spielerKomplett && i <= saetze.length
                    ? InkWell(
                        onTap: () async {
                          bool loeschen = false;
                          final picked = await showDialog<Satz>(
                            context: context,
                            builder: (ctx) => _SatzPickerDialog(
                              titel: '${slot.label}$titelSuffix',
                              linksTeamName: linksTeam.name,
                              rechtsTeamName: rechtsTeam.name,
                              linksSpielerName: linksSpielerAll,
                              rechtsSpielerName: rechtsSpielerAll,
                              heimLinks: heimLinks,
                              onLoeschen: () {
                                loeschen = true;
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                          if (loeschen) {
                            onSatzGeloescht(i);
                          } else if (picked != null) {
                            onSatzGesetzt(i, picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            scoreText,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: satz != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        scoreText,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
              ),
              Expanded(
                child: _spielerWidget(
                  context,
                  spieler: rechtsPlayer,
                  team: rechtsTeam,
                  istHeim: !linksIstHeim,
                  index: i,
                  align: TextAlign.start,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SatzPickerDialog extends StatefulWidget {
  const _SatzPickerDialog({
    required this.titel,
    required this.linksTeamName,
    required this.rechtsTeamName,
    required this.linksSpielerName,
    required this.rechtsSpielerName,
    required this.heimLinks,
    required this.onLoeschen,
  });

  final String titel;
  final String linksTeamName;
  final String rechtsTeamName;
  final String linksSpielerName;
  final String rechtsSpielerName;
  final bool heimLinks;
  final VoidCallback onLoeschen;

  @override
  State<_SatzPickerDialog> createState() => _SatzPickerDialogState();
}

class _SatzPickerDialogState extends State<_SatzPickerDialog> {
  // true = links hat 7 gewählt, false = rechts hat 7, null = nichts
  bool? _siebenLinks;

  Satz _satz(int linksTore, int rechtsTore) => widget.heimLinks
      ? Satz(heimTore: linksTore, gastTore: rechtsTore)
      : Satz(heimTore: rechtsTore, gastTore: linksTore);

  void _onLinksGeklickt(BuildContext context, int val) {
    if (val == 6) {
      Navigator.pop(context, _satz(6, 6));
    } else if (val < 7) {
      Navigator.pop(context, _satz(val, 7));
    } else {
      setState(() => _siebenLinks = true);
    }
  }

  void _onRechtsGeklickt(BuildContext context, int val) {
    if (val == 6) {
      Navigator.pop(context, _satz(6, 6));
    } else if (val < 7) {
      Navigator.pop(context, _satz(7, val));
    } else {
      setState(() => _siebenLinks = false);
    }
  }

  Widget _zahlBtn(
    BuildContext context, {
    required int val,
    required bool istLinks,
    required bool hervorgehoben,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 56,
      child: FilledButton(
        onPressed: () => istLinks
            ? _onLinksGeklickt(context, val)
            : _onRechtsGeklickt(context, val),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: hervorgehoben
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          foregroundColor: hervorgehoben
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
        child: Text('$val'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return AlertDialog(
      title: Text(widget.titel),
      contentPadding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Text(
                    widget.linksTeamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.linksSpielerName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [7, 6, 5, 4, 3, 2, 1, 0]
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _zahlBtn(
                              context,
                              val: v,
                              istLinks: true,
                              hervorgehoben: v == 7 && _siebenLinks == true,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    widget.rechtsTeamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.rechtsSpielerName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [0, 1, 2, 3, 4, 5, 6, 7]
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _zahlBtn(
                              context,
                              val: v,
                              istLinks: false,
                              hervorgehoben: v == 7 && _siebenLinks == false,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: widget.onLoeschen,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Löschen'),
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
            ),
          ),
        ],
      ),
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

class _SpielerPickerDialog extends StatelessWidget {
  const _SpielerPickerDialog({required this.team, this.aktuell});

  final Team team;
  final Spieler? aktuell;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(team.name),
      children: team.spieler
          .map(
            (s) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, s),
              child: Text(
                s.name,
                style: s.id == aktuell?.id
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
