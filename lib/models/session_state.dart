import 'package:flutter/material.dart';
import 'session.dart';
import 'dare_state.dart';
import 'ledger_entry.dart';
import 'spin_result.dart';
import 'roulette_result.dart';
import '../data/dares.dart';

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

  // ── session lifecycle ───────────────────────────────────────────

  void startSession(Session s) => onSessionChanged(s);
  void endSession() => onSessionChanged(null);

  // ── dare lifecycle ──────────────────────────────────────────────

  void startTimer() {
    if (session == null) return;
    onSessionChanged(session!.startTimer());
  }

  void triggerVote() {
    if (session == null) return;
    onSessionChanged(session!.triggerVote());
  }

  void submitVote(String voter, bool pass) {
    if (session == null) return;
    final s1 = session!.submitVote(voter, pass);
    if (s1.currentDareState!.allVoted(s1.players.map((p) => p.name).toList())) {
      final (s2, passed) = s1.resolveDare();
      if (!passed) {
        final punishment = Dares.randomPunishment();
        final s3 = s2.assignPunishment(s1.currentDareState!.player, punishment);
        onSessionChanged(s3);
      } else {
        onSessionChanged(s2);
      }
    } else {
      onSessionChanged(s1);
    }
  }

  void completeDareAndTriggerVote() {
    if (session == null) return;
    var s = session!;
    if (s.currentDareState?.phase == DarePhase.assigned) {
      s = s.startTimer();
    }
    onSessionChanged(s.triggerVote());
  }

  void refuseDare(String playerName) {
    if (session == null) return;
    final punishment = Dares.randomPunishment();
    onSessionChanged(session!.refuseDare(playerName, punishment));
  }

  void useVeto(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.useVeto(playerName));
  }

  void completeDare(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.completeDare(playerName));
  }

  // ── spin results ────────────────────────────────────────────────

  void addSpinResult(SpinResult result) {
    if (session == null) return;
    onSessionChanged(session!.addSpinResult(result));
  }

  void addRouletteResult(RouletteResult result) {
    if (session == null) return;
    onSessionChanged(session!.addRouletteResult(result));
  }

  // ── ledger ──────────────────────────────────────────────────────

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
