import 'package:flutter/material.dart';
import 'package:ue45x/model/team.dart';

class FreilosRow extends StatelessWidget {
  const FreilosRow({required this.team, super.key});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
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
