import 'dart:async';
import 'dart:convert';

import 'package:ue45x/model/liga.dart';

abstract class LigaSpeicher {
  Future<void> speichern(
    Liga liga,
  ) async {}

  Future<Liga?> laden(
    String name,
  ) async => null;

  Stream<Liga?> aenderungen(
    String name,
  ) async* {}
}

class LigaSpeicherStub extends LigaSpeicher {
  @override
  Future<void> speichern(
      Liga liga,
  ) async {
    // TODO: json-String schreiben (Datei, Datenbank o. ä.)

    // print('Speichern ----> ${json.length}');

    // print(json);
    // print('----');
  }
}
