import 'package:flutter/material.dart';

class TabelleHeader extends StatelessWidget {
  const TabelleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        );

    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: style)),
          Expanded(child: Text('Team', style: style)),
          SizedBox(
            width: 32,
            child: Text('Sp', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 52,
            child: Text('Tore', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 44,
            child: Text('+/−', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 32,
            child: Text('S', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 32,
            child: Text('U', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 32,
            child: Text('N', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 44,
            child: Text('+/−', style: style, textAlign: .center),
          ),
          SizedBox(
            width: 36,
            child: Text('Pkt', style: style, textAlign: .center),
          ),
        ],
      ),
    );
  }
}