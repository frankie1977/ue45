import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spiel.dart';

class LetzteErgebnisse extends StatelessWidget {
  const LetzteErgebnisse({
    required this.liga,
    this.viewModus = false,
    super.key,
  });

  final Liga liga;
  final bool viewModus;

  List<({Spiel spiel, SpielSlot slot, Begegnung beg})> _abgeschlosseneSpiele() {
    final result = <({Spiel spiel, SpielSlot slot, Begegnung beg})>[];
    for (final beg in liga.begegnungen) {
      for (final slot in SpielSlot.values) {
        final spiel = beg.spielAt(slot);
        if (spiel != null && spiel.istAbgeschlossen) {
          result.add((spiel: spiel, slot: slot, beg: beg,),);
        }
      }
    }
    return result.reversed.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spiele = _abgeschlosseneSpiele();

    if (spiele.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

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
                'Letzte Ergebnisse',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const Divider(height: 1,),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spiele.length,
              separatorBuilder: (BuildContext ctx, int index) {
                return const Divider(height: 1,);
              },
              itemBuilder: (BuildContext ctx, int index) {
                final (:spiel, :slot, :beg) = spiele[index];
                return _SpielRow(
                  spiel: spiel,
                  slot: slot,
                  beg: beg,
                  viewModus: viewModus,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SpielRow extends StatelessWidget {
  const _SpielRow({
    required this.spiel,
    required this.slot,
    required this.beg,
    required this.viewModus,
  });

  final Spiel spiel;
  final SpielSlot slot;
  final Begegnung beg;
  final bool viewModus;

  String _heimText() {
    return switch (spiel) {
      Einzel(:final heimSpieler) => heimSpieler?.name ?? '?',
      Doppel(:final heimSpieler) => heimSpieler.map((s) {
          return s.name;
        }).join(' & '),
    };
  }

  String _gastText() {
    return switch (spiel) {
      Einzel(:final gastSpieler) => gastSpieler?.name ?? '?',
      Doppel(:final gastSpieler) => gastSpieler.map((s) {
          return s.name;
        }).join(' & '),
    };
  }

  String _scoreText() {
    return switch (spiel) {
      Einzel(:final satz) =>
        satz != null ? '${satz.heimTore}:${satz.gastTore}' : '?',
      Doppel(:final saetze) => saetze.map((s) {
          return '${s.heimTore}:${s.gastTore}';
        }).join('  '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heimGewinnt = spiel.punkteHeim > spiel.punkteGast;
    final gastGewinnt = spiel.punkteGast > spiel.punkteHeim;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8,),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _heimText(),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: heimGewinnt ? FontWeight.bold : FontWeight.normal,
                color: heimGewinnt ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: viewModus ? 16.0 : 0.0,
            ),
            child: SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  slot.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  _scoreText(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ),
          ),
          Expanded(
            child: Text(
              _gastText(),
              textAlign: TextAlign.left,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: gastGewinnt ? FontWeight.bold : FontWeight.normal,
                color: gastGewinnt ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
