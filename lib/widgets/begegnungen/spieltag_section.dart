import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/tisch.dart';
import 'package:ue45x/widgets/begegnungen/begegnung_row.dart';
import 'package:ue45x/widgets/begegnungen/freilos_row.dart';

class SpieltagSection extends StatelessWidget {
  const SpieltagSection({
    required this.spieltag,
    required this.startIndex,
    required this.tische,
    required this.onBegegnungGeaendert,
    this.istAktiv = false,
    super.key,
  });

  final Spieltag spieltag;
  final int startIndex;
  final List<Tisch> tische;
  final void Function(Begegnung) onBegegnungGeaendert;
  final bool istAktiv;

  @override
  Widget build(BuildContext context) {
    final abgeschlossen = spieltag.begegnungen.every((b) {
      return b.istAbgeschlossen;
    });

    return Card(
      elevation: istAktiv ? 4 : null,
      margin: const .symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const .fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text('Spieltag ${spieltag.nummer}'),
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
          const Divider(height: 1),
          ...spieltag.begegnungen.indexed.map(
            ((int, Begegnung) e) {
              return BegegnungRow(
                begegnung: e.$2,
                heimLinks: (startIndex + e.$1).isEven,
                tische: tische,
                onBegegnungGeaendert: onBegegnungGeaendert,
              );
            },
          ),
          if (spieltag.freilos != null) FreilosRow(team: spieltag.freilos!),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
