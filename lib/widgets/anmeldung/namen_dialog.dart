import 'package:flutter/material.dart';

class NamenDialog extends StatefulWidget {
  const NamenDialog({
    required this.titel,
    required this.initialText,
    required this.bestaetigenText,
    super.key,
  });

  final String titel;
  final String initialText;
  final String bestaetigenText;

  @override
  State<NamenDialog> createState() => _NamenDialogState();
}

class _NamenDialogState extends State<NamenDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bestaetigen() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Teamname'),
        textCapitalization: .words,
        onSubmitted: (_) {
          _bestaetigen();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _bestaetigen,
          child: Text(widget.bestaetigenText),
        ),
      ],
    );
  }
}
