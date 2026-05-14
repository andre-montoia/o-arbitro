import 'package:flutter/services.dart';

/// Haptic feedback patterns for O Árbitro
/// Rich, contextual haptics that match the premium casino feel
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  // ═══════════════════════════════════════════════════════════
  // BASIC IMPACTS
  // ═══════════════════════════════════════════════════════════
  
  /// Light tap — button presses, selections
  Future<void> light() => HapticFeedback.lightImpact();
  
  /// Medium tap — card taps, toggles
  Future<void> medium() => HapticFeedback.mediumImpact();
  
  /// Heavy tap — important actions, confirmations
  Future<void> heavy() => HapticFeedback.heavyImpact();
  
  /// Selection click — small UI interactions
  Future<void> selection() => HapticFeedback.selectionClick();
  
  /// Generic vibrate
  Future<void> vibrate() => HapticFeedback.vibrate();

  // ═══════════════════════════════════════════════════════════
  // GAME-SPECIFIC PATTERNS
  // ═══════════════════════════════════════════════════════════
  
  /// Slot machine spin — building tension
  Future<void> slotSpin() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Slot machine result — satisfying stop
  Future<void> slotResult() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Roulette ball landing — anticipation release
  Future<void> rouletteLand() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Vote submitted — quick confirmation
  Future<void> voteSubmit() async {
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Veto used — dramatic, powerful
  Future<void> vetoUsed() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Dare assigned — attention-grabbing
  Future<void> dareAssigned() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  /// Success/approval — satisfying double-tap
  Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Failure/punishment — harsh, attention-grabbing
  Future<void> failure() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Streak milestone — celebratory pattern
  Future<void> streakMilestone() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
    }
    await HapticFeedback.heavyImpact();
  }

  /// Score earned — quick reward tick
  Future<void> scoreEarned() async {
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.lightImpact();
  }

  /// Turn announcement — whoosh feel
  Future<void> turnAnnounce() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.lightImpact();
  }

  /// Timer tick — subtle urgency
  Future<void> timerTick() => HapticFeedback.selectionClick();

  /// Timer urgent — last 3 seconds
  Future<void> timerUrgent() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Celebration — confetti moment
  Future<void> celebration() async {
    for (int i = 0; i < 5; i++) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 40));
    }
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
