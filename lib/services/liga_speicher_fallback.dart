import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/services/liga_speicher.dart';
import 'package:ue45x/services/liga_speicher_lokal.dart';

/// Decorator ueber [remote] (Supabase) und [lokal] (shared_preferences).
///
/// - Schreibt immer zuerst lokal (verlustfrei), dann Richtung Remote.
/// - Liefert beim Abonnieren sofort die lokale Kopie (App startet offline).
/// - Merkt fehlgeschlagene Writes als `pending` und synchronisiert sie
///   periodisch nach, sobald Supabase wieder erreichbar ist.
///
/// Annahme: nur ein Geraet traegt im Spielbetrieb ein -> Last-Write-Wins.
class LigaSpeicherFallback extends LigaSpeicher {
  final LigaSpeicher remote;
  final LigaSpeicherLokal lokal;
  final Duration reSyncIntervall;

  /// Zeigt der UI an, ob aktuell nur lokal gespeichert wird.
  final ValueNotifier<bool> istOffline = ValueNotifier<bool>(
    false,
  );

  Liga? _pending;
  Timer? _reSyncTimer;
  StreamController<Liga?>? _ausgabe;
  StreamSubscription<Liga?>? _remoteAbo;

  LigaSpeicherFallback({
    required this.remote,
    required this.lokal,
    this.reSyncIntervall = const Duration(
      seconds: 15,
    ),
  });

  void _setzeOffline(
    bool offline,
  ) {
    if (istOffline.value != offline) {
      istOffline.value = offline;
    }
  }

  @override
  Future<void> speichern(
    Liga liga,
  ) async {
    await lokal.speichern(liga);
    await _versucheRemote(liga);
    if (istOffline.value) {
      _ausgabe?.add(liga);
    }
  }

  Future<void> _versucheRemote(
    Liga liga,
  ) async {
    try {
      await remote.speichern(liga);
      _pending = null;
      _setzeOffline(false);
    } catch (_) {
      _pending = liga;
      _setzeOffline(true);
      _starteReSync();
    }
  }

  void _starteReSync() {
    if (_reSyncTimer != null) {
      return;
    }
    _reSyncTimer = Timer.periodic(
      reSyncIntervall,
      (timer) {
        final Liga? offen = _pending;
        if (offen == null) {
          timer.cancel();
          _reSyncTimer = null;
          return;
        }
        _versucheRemote(offen);
      },
    );
  }

  @override
  Stream<Liga?> aenderungen(
    String name,
  ) {
    final StreamController<Liga?> controller = StreamController<Liga?>();
    _ausgabe = controller;

    controller
      ..onListen = () {
        final Liga? kopie = lokal.letzteKopie(name);
        if (kopie != null) {
          controller.add(kopie);
        }
        _remoteAbo = remote
            .aenderungen(name)
            .listen(
              (liga) {
                _setzeOffline(false);
                if (liga != null) {
                  lokal.speichern(liga);
                }
                controller.add(liga);
              },
              onError: (Object fehler) {
                _setzeOffline(true);
                _starteReSync();
              },
            );
      }
      ..onCancel = () {
        _remoteAbo?.cancel();
        _remoteAbo = null;
      };

    return controller.stream;
  }

  void dispose() {
    _reSyncTimer?.cancel();
    _remoteAbo?.cancel();
    istOffline.dispose();
  }
}
