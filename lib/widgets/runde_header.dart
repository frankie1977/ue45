import 'package:flutter/material.dart';

class RundeHeader extends StatelessWidget {
  const RundeHeader({required this.titel, super.key});

  final String titel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(16, 20, 16, 4),
      child: Text(
        titel,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: .bold,
        ),
      ),
    );
  }
}
