import 'dart:async';

import 'package:ue45x/model/liga.dart';

abstract class LigaSpeicher {
  Future<void> speichern(
    Liga liga,
  ) async {}

  Stream<Liga?> aenderungen(
    String name,
  ) async* {}
}
