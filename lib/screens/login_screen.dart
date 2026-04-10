import 'package:flutter/material.dart';

const String _passwort = 'ue45x';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onAuthenticated,
    super.key,
  });

  final VoidCallback onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _fehler = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pruefen() {
    if (_controller.text == _passwort) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _fehler = true;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Passwort eingeben',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 24,
              ),
              TextField(
                controller: _controller,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: _fehler ? 'Falsches Passwort' : null,
                ),
                onSubmitted: (_) {
                  _pruefen();
                },
                autofocus: true,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed: _pruefen,
                child: const Text(
                  'Anmelden',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
