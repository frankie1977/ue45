import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/team.dart';

class TeamsTab extends StatelessWidget {
  const TeamsTab({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: liga.teams.length,
      itemBuilder: (BuildContext context, int index) {
        return _TeamCard(team: liga.teams[index]);
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6,),
      child: ExpansionTile(
        leading: const Icon(Icons.groups),
        title: Text(
          team.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('${team.spieler.length} Spieler'),
        children: team.spieler
            .map(
              (s) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(
                  s.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
