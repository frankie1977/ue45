import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/widgets/tabelle_header.dart';
import 'package:ue45x/widgets/tabelle_row.dart';

class TabelleTab extends StatelessWidget {
  const TabelleTab({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    final teams = liga.tabelle;

    return Column(
      children: [
        const TabelleHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
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
        ),
      ],
    );
  }
}
