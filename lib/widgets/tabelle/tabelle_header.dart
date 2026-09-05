import 'package:flutter/material.dart';
import 'package:ue45x/widgets/tabelle/tabelle_spalten.dart';

class TabelleHeader extends StatelessWidget {
  const TabelleHeader({
    this.breiteNamen = false,
    super.key,
  });

  /// Teamname belegt die halbe Breite, die Statistik-Spalten teilen sich
  /// den Rest (Anzeigemodus).
  final bool breiteNamen;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    );

    Widget spalte(
      String text,
      int flex,
    ) {
      return tabelleSpalte(
        flex: flex,
        flexibel: breiteNamen,
        kind: Text(
          text,
          style: style,
          textAlign: .center,
        ),
      );
    }

    return Padding(
      padding: const .symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: tabelleRangBreite,
            child: Text(
              '#',
              textAlign: .right,
              style: style,
            ),
          ),
          const SizedBox(
            width: tabelleRangAbstand,
          ),
          Expanded(
            flex: breiteNamen ? tabelleFlexTeam : 1,
            child: Text(
              'Team',
              style: style,
            ),
          ),
          spalte(
            'Sp',
            tabelleFlexSpiele,
          ),
          spalte(
            'Tore',
            tabelleFlexTore,
          ),
          spalte(
            '+/−',
            tabelleFlexTorDifferenz,
          ),
          spalte(
            'S',
            tabelleFlexSiege,
          ),
          spalte(
            'U',
            tabelleFlexUnentschieden,
          ),
          spalte(
            'N',
            tabelleFlexNiederlagen,
          ),
          spalte(
            '+/−',
            tabelleFlexPunkteDifferenz,
          ),
          spalte(
            '',
            tabelleFlexPunkte,
          ),
        ],
      ),
    );
  }
}
