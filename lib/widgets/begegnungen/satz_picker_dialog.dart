import 'package:flutter/material.dart';
import 'package:ue45x/model/satz.dart';

class SatzPickerDialog extends StatefulWidget {
  const SatzPickerDialog({
    required this.titel,
    required this.linksTeamName,
    required this.rechtsTeamName,
    required this.linksSpielerName,
    required this.rechtsSpielerName,
    required this.heimLinks,
    required this.onLoeschen,
    this.initialSatz,
    super.key,
  });

  final String titel;
  final String linksTeamName;
  final String rechtsTeamName;
  final String linksSpielerName;
  final String rechtsSpielerName;
  final bool heimLinks;
  final VoidCallback onLoeschen;
  final Satz? initialSatz;

  @override
  State<SatzPickerDialog> createState() => _SatzPickerDialogState();
}

class _SatzPickerDialogState extends State<SatzPickerDialog> {
  int? _linksGewaehlt;
  int? _rechtsGewaehlt;

  @override
  void initState() {
    super.initState();
    final satz = widget.initialSatz;
    if (satz != null) {
      _linksGewaehlt = widget.heimLinks ? satz.heimTore : satz.gastTore;
      _rechtsGewaehlt = widget.heimLinks ? satz.gastTore : satz.heimTore;
    }
  }

  Satz _satz(int linksTore, int rechtsTore) => widget.heimLinks
      ? Satz(heimTore: linksTore, gastTore: rechtsTore)
      : Satz(heimTore: rechtsTore, gastTore: linksTore);

  void _onLinksGeklickt(BuildContext context, int val) {
    if (val == 6) {
      Navigator.pop(context, _satz(6, 6));
    } else if (val < 7) {
      Navigator.pop(context, _satz(val, 7));
    } else {
      setState(() {
        _linksGewaehlt = 7;
        _rechtsGewaehlt = null;
      });
    }
  }

  void _onRechtsGeklickt(BuildContext context, int val) {
    if (val == 6) {
      Navigator.pop(context, _satz(6, 6));
    } else if (val < 7) {
      Navigator.pop(context, _satz(7, val));
    } else {
      setState(() {
        _rechtsGewaehlt = 7;
        _linksGewaehlt = null;
      });
    }
  }

  Widget _zahlBtn(
    BuildContext context, {
    required int val,
    required bool istLinks,
    required bool hervorgehoben,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 60,
      child: FilledButton(
        onPressed: () {
          if (istLinks) {
            _onLinksGeklickt(context, val);
          } else {
            _onRechtsGeklickt(context, val);
          }
        },
        style: FilledButton.styleFrom(
          padding: .zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: hervorgehoben
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          foregroundColor: hervorgehoben
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
        child: Text('$val'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.titel),
      contentPadding: const .fromLTRB(16, 8, 16, 16),
      content: Column(
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisSize: .min,
            crossAxisAlignment: .end,
            children: [
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    widget.linksTeamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: .bold,
                    ),
                  ),
                  Text(
                    widget.linksSpielerName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [7, 6, 5, 4, 3, 2, 1, 0].map(
                      (v) {
                        return Padding(
                          padding: const .symmetric(horizontal: 2),
                          child: _zahlBtn(
                            context,
                            val: v,
                            istLinks: true,
                            hervorgehoben: v == _linksGewaehlt,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
              SizedBox(
                width: 40,
                child: Text(
                  textAlign: .center,
                  'zu',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    widget.rechtsTeamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: .bold,
                    ),
                  ),
                  Text(
                    widget.rechtsSpielerName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [0, 1, 2, 3, 4, 5, 6, 7].map(
                      (v) {
                        return Padding(
                          padding: const .symmetric(horizontal: 2),
                          child: _zahlBtn(
                            context,
                            val: v,
                            istLinks: false,
                            hervorgehoben: v == _rechtsGewaehlt,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: widget.onLoeschen,
            child: Text(
              'Löschen',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
