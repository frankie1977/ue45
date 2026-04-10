import 'dart:convert';

import 'package:ue45x/model/liga.dart';

abstract class LigaSpeicher {
  Future<void> speichern(Liga liga,) async {
    final String json = jsonEncode(liga.toJson());
    await persistieren(json,);
  }

  Future<void> persistieren(String json,);
}

class LigaSpeicherStub extends LigaSpeicher {
  @override
  Future<void> persistieren(String json,) async {
    // TODO: json-String schreiben (Datei, Datenbank o. ä.)

    print('Speichern ----> ${json.length}');

  }
}
