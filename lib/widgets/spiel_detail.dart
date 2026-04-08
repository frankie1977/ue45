import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/widgets/satz_picker_dialog.dart';
import 'package:ue45x/widgets/spieler_picker_dialog.dart';

class SpielDetail extends StatelessWidget {
  const SpielDetail({
    required this.slot,
    required this.spiel,
    required this.heimLinks,
    required this.linksTeam,
    required this.rechtsTeam,
    required this.onSatzGesetzt,
    required this.onSatzGeloescht,
    required this.onSpielerGeandert,
    super.key,
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
      builder: (ctx) => SpielerPickerDialog(team: team, aktuell: aktuell),
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
        onTap: () => _spielerAuswaehlen(context, team, istHeim, index, spieler),
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
          Icons.person_add_outlined,
          size: 18,
          color: theme.colorScheme.primary,
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
        final spielerKomplett = linksPlayer != null && rechtsPlayer != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            builder: (ctx) => SatzPickerDialog(
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
