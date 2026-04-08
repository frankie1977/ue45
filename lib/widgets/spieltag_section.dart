import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/widgets/begegnung_row.dart';
import 'package:ue45x/widgets/freilos_row.dart';

class SpieltagSection extends StatelessWidget {
  const SpieltagSection({
    required this.spieltag,
    required this.startIndex,
    required this.onBegegnungGeaendert,
    super.key,
  });

  final Spieltag spieltag;
  final int startIndex;
  final void Function(Begegnung) onBegegnungGeaendert;

  @override
  Widget build(BuildContext context) {
    final abgeschlossen = spieltag.begegnungen.every((b) => b.istAbgeschlossen);

    return Card(
      elevation: 3,
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
            ((int, Begegnung) e) => BegegnungRow(
              begegnung: e.$2,
              heimLinks: (startIndex + e.$1).isEven,
              onBegegnungGeaendert: onBegegnungGeaendert,
            ),
          ),
          if (spieltag.freilos != null) FreilosRow(team: spieltag.freilos!),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
