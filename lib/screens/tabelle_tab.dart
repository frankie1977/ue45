import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/widgets/tabelle/aktuelle_spiele.dart';
import 'package:ue45x/widgets/tabelle/spieler_top_liste.dart';
import 'package:ue45x/widgets/tabelle/tabelle_header.dart';
import 'package:ue45x/widgets/tabelle/tabelle_row.dart';

class TabelleTab extends StatelessWidget {
  const TabelleTab({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    final teams = liga.tabelle;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          AktuelleSpiele(liga: liga),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const TabelleHeader(),
                  const Divider(height: 1),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: teams.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      return TabelleRow(
                        rang: index + 1,
                        team: teams[index],
                        liga: liga,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),

          SpielerTopListe(liga: liga),
        ],
      ),
    );
  }
}
