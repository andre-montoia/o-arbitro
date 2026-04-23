import 'package:flutter/material.dart';
import 'session.dart';
import 'ledger_entry.dart';
import 'spin_result.dart';
import 'roulette_result.dart';

class SessionState extends InheritedWidget {
  const SessionState({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required super.child,
  });

  final Session? session;
  final ValueChanged<Session?> onSessionChanged;

  bool get hasSession => session != null;

  static SessionState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SessionState>();
    assert(result != null, 'No SessionState found in context');
    return result!;
  }

  void startSession(Session s) => onSessionChanged(s);
  void endSession() => onSessionChanged(null);

  void addSpinResult(SpinResult result) {
    if (session == null) return;
    onSessionChanged(session!.addSpinResult(result));
  }

  void useVeto(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.useVeto(playerName));
  }

  void completeDare(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.completeDare(playerName));
  }

  void addRouletteResult(RouletteResult result) {
    if (session == null) return;
    onSessionChanged(session!.addRouletteResult(result));
  }

  void addLedgerEntry(LedgerEntry entry) {
    if (session == null) return;
    onSessionChanged(session!.addLedgerEntry(entry));
  }

  void updateLedgerEntry(int index, LedgerEntry updated) {
    if (session == null) return;
    onSessionChanged(session!.updateLedgerEntry(index, updated));
  }

  @override
  bool updateShouldNotify(SessionState oldWidget) =>
    session != oldWidget.session;
}
