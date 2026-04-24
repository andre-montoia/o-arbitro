# O Árbitro v0.5 — UX, Design & Maturity Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (or gemini-subagent-dispatch for implementation tasks). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate O Árbitro from functional to polished — fix all HIGH bugs, make slot machine and roulette feel like real casino games, add turn flow and results screen, fix veto logic, improve scoring with intensity points and streak bonuses, add persistence.

**Architecture:** All changes are isolated to existing files or new files within lib/. No new packages except `shared_preferences` for session persistence. CustomPainter extended for roulette ball. SlotReel rewritten with ListWheelScrollView. ArbitroButton converted to StatefulWidget for press animation.

**Tech Stack:** Flutter 3.x, Dart, audioplayers ^6.0.0, shared_preferences ^2.3.0

---

### Task 1: Fix SoundService — AudioPlayer pool

**Files:**
- Modify: `lib/services/sound_service.dart`

Current code creates a new `AudioPlayer` per sound — the `onPlayerComplete` dispose never fires reliably, causing accumulation.

- [ ] **Step 1: Rewrite sound_service.dart**

```dart
import 'package:audioplayers/audioplayers.dart';

enum GameSound {
  spin('sounds/spin.wav'),
  win('sounds/win.wav'),
  dareAssign('sounds/dare_assign.wav'),
  votePass('sounds/vote_pass.wav'),
  voteFail('sounds/vote_fail.wav'),
  timerTick('sounds/timer_tick.wav'),
  punishment('sounds/punishment.wav');

  const GameSound(this.path);
  final String path;
}

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _poolSize = 4;
  final List<AudioPlayer> _pool = List.generate(_poolSize, (_) => AudioPlayer());
  int _poolIndex = 0;

  Future<void> play(GameSound sound) async {
    try {
      final player = _pool[_poolIndex % _poolSize];
      _poolIndex++;
      await player.stop();
      await player.play(AssetSource(sound.path));
    } catch (_) {}
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
  }
}
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/services/sound_service.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/services/sound_service.dart
git commit -m "fix: replace per-call AudioPlayer with 4-player pool"
```

---

### Task 2: Fix ArbitroButton — real press animation

**Files:**
- Modify: `lib/ui/components/arbitro_button.dart`

Current `AnimatedScale` always stays at `1.0`. Convert to StatefulWidget with GestureDetector onTapDown/onTapUp.

- [ ] **Step 1: Rewrite ArbitroButton as StatefulWidget**

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../../services/haptic_service.dart';

enum ArbitroButtonVariant { primary, secondary, ghost, destructive }

class ArbitroButton extends StatefulWidget {
  const ArbitroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ArbitroButtonVariant.primary,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ArbitroButtonVariant variant;
  final bool fullWidth;

  @override
  State<ArbitroButton> createState() => _ArbitroButtonState();
}

class _ArbitroButtonState extends State<ArbitroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    Widget child = GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) {
        setState(() => _pressed = false);
        HapticService.instance.selection();
        widget.onPressed?.call();
      },
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: _buildInner(),
      ),
    );

    if (isDisabled) child = Opacity(opacity: 0.5, child: child);
    if (widget.fullWidth) child = SizedBox(width: double.infinity, child: child);

    return child;
  }

  Widget _buildInner() {
    return switch (widget.variant) {
      ArbitroButtonVariant.primary     => _GradientButton(label: widget.label),
      ArbitroButtonVariant.secondary   => _SecondaryButton(label: widget.label),
      ArbitroButtonVariant.ghost       => _GhostButton(label: widget.label),
      ArbitroButtonVariant.destructive => _DestructiveButton(label: widget.label),
    };
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      gradient: AppColors.gradientPrimary,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: Text(label, style: AppTextStyles.button, textAlign: TextAlign.center),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x267C3AED),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DA855F7)),
    ),
    child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.purpleLight), textAlign: TextAlign.center),
  );
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
  );
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x26EF4444),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DEF4444)),
    ),
    child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.danger), textAlign: TextAlign.center),
  );
}
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/ui/components/arbitro_button.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/arbitro_button.dart
git commit -m "fix: ArbitroButton press animation — scale 0.95 on tap down"
```

---

### Task 3: Realistic SlotReel with ListWheelScrollView

**Files:**
- Modify: `lib/ui/components/slot_reel.dart`

Current implementation rebuilds Column every frame (inefficient). Replace with `ListWheelScrollView` and a `FixedExtentScrollController` for real physical-feeling spin.

- [ ] **Step 1: Rewrite slot_reel.dart**

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class SlotReel extends StatefulWidget {
  const SlotReel({
    super.key,
    required this.items,
    required this.duration,
    this.onComplete,
  });

  final List<String> items;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SlotReel> createState() => SlotReelState();
}

class SlotReelState extends State<SlotReel> {
  late final FixedExtentScrollController _scrollController;
  static const _itemExtent = 44.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void spin(int targetIndex) {
    final total = widget.items.length;
    // Spin at least 3 full rotations + land on target
    final extraSpins = 3 * total;
    final destination = _currentIndex + extraSpins + ((targetIndex - _currentIndex % total) + total) % total;
    _currentIndex = destination;

    _scrollController
        .animateTo(
          destination * _itemExtent,
          duration: widget.duration,
          curve: Curves.fastOutSlowIn,
        )
        .then((_) => widget.onComplete?.call());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.purpleLight.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.transparent,
            Colors.transparent,
            Colors.black,
          ],
          stops: const [0.0, 0.25, 0.75, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: _itemExtent,
          physics: const NeverScrollableScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 2.5,
          childDelegate: ListWheelChildLoopingListDelegate(
            children: widget.items.map((item) => _ReelItem(text: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _ReelItem extends StatelessWidget {
  const _ReelItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
}
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/ui/components/slot_reel.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/slot_reel.dart
git commit -m "feat: rewrite SlotReel with ListWheelScrollView for realistic spin physics"
```

---

### Task 4: Realistic SlotMachine visual — chrome frame, animated lights

**Files:**
- Modify: `lib/ui/components/slot_machine.dart`

Add chrome metallic border around reel window, animated neon border lights during spin, a decorative lever icon.

- [ ] **Step 1: Read the current file**

Read: `lib/ui/components/slot_machine.dart`

- [ ] **Step 2: Add _LightsPainter and update SlotMachine**

Add `StatefulWidget` wrapper with `AnimationController` for lights. The lights animate only while `isSpinning`. The reel window gets a metallic gradient border. A lever icon sits to the right.

Key changes:
1. Convert `SlotMachine` to `StatefulWidget` with `TickerProviderStateMixin`
2. Add `_lightsController` AnimationController (300ms repeat) that runs only when `isSpinning`
3. Wrap the reel window in a `CustomPaint` using `_ChromePainter` that draws:
   - Outer metallic frame: gradient from `Color(0xFF6B6B8A)` → `Color(0xFF2A2A3E)` → `Color(0xFF6B6B8A)` (simulates chrome)
   - Animated colored dots at corners (red, yellow, green cycling) when spinning
4. Add a lever `Icon(Icons.swipe_down_rounded)` on the right side, animated to rotate 30° when spinning

- [ ] **Step 3: Implement the changes**

Add to imports: no new packages needed.

Add `_ChromeFramePainter` CustomPainter:
```dart
class _ChromeFramePainter extends CustomPainter {
  _ChromeFramePainter({required this.lightValue, required this.isSpinning});
  final double lightValue;
  final bool isSpinning;

  static const _lightColors = [Color(0xFFFF3366), Color(0xFFFFD700), Color(0xFF33FF99), Color(0xFF6633FF)];

  @override
  void paint(Canvas canvas, Size size) {
    // Chrome outer border
    final chromePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFF8A8AAA), Color(0xFF2A2A3E), Color(0xFF8A8AAA)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, chromePaint);

    if (!isSpinning) return;

    // Animated corner lights
    final lightPaint = Paint()..style = PaintingStyle.fill;
    final positions = [
      const Offset(16, 16), Offset(size.width - 16, 16),
      Offset(16, size.height - 16), Offset(size.width - 16, size.height - 16),
    ];
    for (int i = 0; i < positions.length; i++) {
      final colorIdx = ((lightValue * _lightColors.length).floor() + i) % _lightColors.length;
      lightPaint.color = _lightColors[colorIdx].withValues(alpha: 0.8);
      canvas.drawCircle(positions[i], 5, lightPaint);
    }
  }

  @override
  bool shouldRepaint(_ChromeFramePainter old) =>
      old.lightValue != lightValue || old.isSpinning != isSpinning;
}
```

- [ ] **Step 4: Analyze**

Run: `dart analyze lib/ui/components/slot_machine.dart`
Fix all errors.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/components/slot_machine.dart
git commit -m "feat: SlotMachine chrome frame and animated lights during spin"
```

---

### Task 5: Realistic Roulette Wheel — ball animation + classic colors

**Files:**
- Modify: `lib/ui/components/roulette_wheel.dart`

Add a white ball that spins counter to the wheel, slows down, and clicks into the winning pocket. Change segment colors to alternating red/black (classic roulette), with a dark wood outer ring.

- [ ] **Step 1: Add ball controller to RouletteWheelState**

Add `late AnimationController _ballController` with duration 4200ms (slightly longer than wheel).
Add `late Animation<double> _ballAnimation` — ball starts at 1.5× wheel radius and spirals inward.
Ball angle = `_ballAnimation.value` (counter-clockwise = negative direction).
Ball radius = lerp from `radius * 0.92` to `radius * 0.72` as animation progresses.

- [ ] **Step 2: Update _WheelPainter colors**

Replace random color list with alternating red/black:
```dart
// In _WheelPainter, compute color per segment:
final isRed = i % 2 == 0;
paint.color = isRed ? const Color(0xFFCC0000) : const Color(0xFF1A1A1A);
```

Add an outer dark wood ring:
```dart
// Draw outer ring (dark wood) before segments
final woodPaint = Paint()
  ..color = const Color(0xFF2C1810)
  ..style = PaintingStyle.fill;
canvas.drawCircle(center, radius, woodPaint);

// Draw inner chrome ring  
final chromePaint = Paint()
  ..color = const Color(0xFF888899)
  ..style = PaintingStyle.fill;
canvas.drawCircle(center, radius * 0.94, chromePaint);

// Then draw segments at radius * 0.92
```

- [ ] **Step 3: Draw ball in AnimatedBuilder**

In `build()`, after the wheel Transform.rotate, add a second `AnimatedBuilder` for `_ballController`:
```dart
AnimatedBuilder(
  animation: _ballController,
  builder: (context, _) {
    if (!_ballController.isAnimating && !_ballController.isCompleted) {
      return const SizedBox.shrink();
    }
    final t = _ballController.value;
    final ballAngle = -_ballAnimation.value * 2.5; // counter-rotate
    final ballRadius = lerpDouble(130.0, 95.0, t)!;
    final cx = 140 + ballRadius * cos(ballAngle);
    final cy = 140 + ballRadius * sin(ballAngle);
    return Positioned(
      left: cx - 6,
      top: cy - 6,
      child: Container(
        width: 12, height: 12,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
  },
),
```

Wrap the whole build output in a `Stack` so the ball can be `Positioned` over the wheel.

- [ ] **Step 4: Trigger both controllers in spin()**

```dart
void spin() {
  if (_controller.isAnimating) return;
  // ... existing winner calculation ...
  _controller.forward(from: 0);
  _ballAnimation = Tween<double>(begin: 0, end: totalRotation * 1.05)
      .animate(CurvedAnimation(parent: _ballController, curve: Curves.easeOutCubic));
  _ballController.forward(from: 0);
}
```

- [ ] **Step 5: Analyze**

Run: `dart analyze lib/ui/components/roulette_wheel.dart`
Fix all errors.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/components/roulette_wheel.dart
git commit -m "feat: roulette ball animation, classic red/black segments, wood outer ring"
```

---

### Task 6: Dare results screen — celebration between vote and next spin

**Files:**
- Create: `lib/ui/components/dare_result_overlay.dart`
- Modify: `lib/ui/screens/slots_screen.dart`
- Modify: `lib/models/dare_state.dart` (add `resolved` phase)
- Modify: `lib/models/session.dart` (add resolveToResult() method)
- Modify: `lib/models/session_state.dart` (update submitVote to go to resolved, not clear)

**New DarePhase:**
```dart
enum DarePhase { assigned, timing, voting, resolved, punishment }
```

**New Session method:**
```dart
Session resolveToResult(bool passed) {
  return _copyWith(
    dareState: currentDareState!.copyWith(
      phase: DarePhase.resolved,
      // Store result in a new field:
    ),
  );
}
```

Add `bool? resolvedPassed` field to DareState.

**Update session_state.dart submitVote:** After allVoted, instead of calling resolveDare() immediately:
```dart
final (s2, passed) = s1.resolveDare(); // still resolves score
final s3 = s2.withDareState(
  s1.currentDareState!.copyWith(phase: DarePhase.resolved, resolvedPassed: passed)
);
onSessionChanged(s3);
```

Add `void dismissResult()` to SessionState:
```dart
void dismissResult() {
  if (session == null) return;
  final ds = session!.currentDareState;
  if (ds == null || ds.phase != DarePhase.resolved) return;
  if (ds.resolvedPassed == false) {
    final punishment = Dares.randomPunishment();
    onSessionChanged(session!.assignPunishment(ds.player, punishment));
  } else {
    onSessionChanged(session!.withDareState(null));
  }
}
```

**dare_result_overlay.dart:**
```dart
// StatelessWidget shown when phase == DarePhase.resolved
// Shows: big ✅ or ❌, player name, "APROVADO!" or "REPROVADO!"
// Vote breakdown: X ✅ Y ❌
// CONTINUAR button calls SessionState.of(context).dismissResult()
// Animated with ScaleTransition elasticOut (same pattern as roulette winner overlay)
```

**slots_screen.dart:** Add case for DarePhase.resolved → show DareResultOverlay.

- [ ] **Step 1: Add resolvedPassed to DareState, add resolved phase**
- [ ] **Step 2: Update Session.resolveDare to preserve dareState in resolved phase**
- [ ] **Step 3: Update SessionState.submitVote and add dismissResult()**
- [ ] **Step 4: Create dare_result_overlay.dart**
- [ ] **Step 5: Wire into slots_screen.dart**
- [ ] **Step 6: Analyze all changed files**
- [ ] **Step 7: Commit**

```bash
git add lib/models/dare_state.dart lib/models/session.dart lib/models/session_state.dart \
        lib/ui/components/dare_result_overlay.dart lib/ui/screens/slots_screen.dart
git commit -m "feat: dare result phase with celebration overlay before returning to spin"
```

---

### Task 7: Fix veto mechanic + turn announcement

**Files:**
- Modify: `lib/ui/screens/slots_screen.dart`

Two fixes:
1. "RECUSAR" button should only be enabled if `player.canVeto`. Rename to "VETAR" and use `session!.useVeto(player)` to consume a token and clear the dare (no punishment — that's the point of a veto).
2. Before spinning, show a brief "É A VEZ DE [PLAYER]!" announcement for 1.5s, then auto-spin.

**Turn announcement:**
```dart
// In _handleSpin():
final nextPlayer = _pickNextPlayer(); // round-robin from session.players
setState(() => _announcedPlayer = nextPlayer);
await Future.delayed(const Duration(milliseconds: 1500));
if (!mounted) return;
setState(() => _announcedPlayer = null);
_doSpin(nextPlayer);
```

Show an `AnimatedSwitcher` at the top of the screen: when `_announcedPlayer != null`, show a centered text overlay "É A VEZ DE\n[NAME]!" with ScaleTransition.

**Veto button:**
```dart
// Replace RECUSAR button with:
ArbitroButton(
  label: 'VETAR (${player.vetoTokens})',
  variant: ArbitroButtonVariant.ghost,
  onPressed: player.canVeto
      ? () {
          SoundService.instance.play(GameSound.votePass);
          HapticService.instance.medium();
          SessionState.of(context).useVeto(playerName);
        }
      : null,
)
```

- [ ] **Step 1: Add _currentPlayerIndex tracking and _announcedPlayer state**
- [ ] **Step 2: Add turn announcement AnimatedSwitcher overlay**
- [ ] **Step 3: Replace RECUSAR with VETAR using canVeto**
- [ ] **Step 4: Analyze**
- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/slots_screen.dart
git commit -m "feat: turn announcement overlay + fix veto mechanic (uses token, no punishment)"
```

---

### Task 8: Intensity-based scoring + streak bonuses

**Files:**
- Modify: `lib/models/player.dart`
- Modify: `lib/models/session.dart`
- Modify: `lib/models/spin_result.dart` (check DareIntensity values)

**Scoring rules:**
- DareIntensity.casual → +100 points
- DareIntensity.ousado → +250 points
- DareIntensity.epico → +500 points
- Punishment completed → +50 points (consolation)

**Streak bonuses:**
- streak == 3 → award +1 free veto token (bonus, `player.earnVeto()`)
- streak == 5 → next dare is forced Épico, worth triple (flag on session: `jackpotPending`)

**Player changes:**
```dart
Player addScore(int points) => _copyWith(
  score: score + points,
  daresCompleted: daresCompleted + 1,
  streak: streak + 1,
);
Player earnVeto() => _copyWith(vetoTokens: vetoTokens + 1);
```

**Session.resolveDare:** Look up dare intensity from currentDareState.intensity string to compute points.

```dart
int _pointsForIntensity(String intensity) => switch (intensity) {
  'CASUAL'  => 100,
  'OUSADO'  => 250,
  'ÉPICO'   => 500,
  'CASTIGO' => 50,
  _         => 100,
};
```

After `addScore(points)`, check streak:
```dart
if (updatedPlayer.streak == 3) updatedPlayer = updatedPlayer.earnVeto();
```

- [ ] **Step 1: Update Player.addScore to take points parameter**
- [ ] **Step 2: Add Player.earnVeto()**
- [ ] **Step 3: Update Session.resolveDare with _pointsForIntensity**
- [ ] **Step 4: Add streak bonus award at streak == 3**
- [ ] **Step 5: Analyze all files**
- [ ] **Step 6: Commit**

```bash
git add lib/models/player.dart lib/models/session.dart
git commit -m "feat: intensity-based scoring (100/250/500pts) and streak veto bonus at 3"
```

---

### Task 9: Session persistence with shared_preferences

**Files:**
- Modify: `pubspec.yaml` (add shared_preferences ^2.3.0)
- Create: `lib/services/session_persistence.dart`
- Modify: `lib/navigation/app_router.dart`
- Modify: `lib/models/session.dart` (add toJson/fromJson)
- Modify: `lib/models/player.dart` (add toJson/fromJson)

**Player serialization:**
```dart
Map<String, dynamic> toJson() => {
  'name': name,
  'vetoTokens': vetoTokens,
  'daresCompleted': daresCompleted,
  'score': score,
  'streak': streak,
};

factory Player.fromJson(Map<String, dynamic> j) => Player(
  name: j['name'] as String,
  vetoTokens: j['vetoTokens'] as int? ?? 2,
  daresCompleted: j['daresCompleted'] as int? ?? 0,
  score: j['score'] as int? ?? 0,
  streak: j['streak'] as int? ?? 0,
);
```

**Session serialization:** Only persist `players` and `ledgerEntries` (not currentDareState — mid-dare state is not worth restoring). LedgerEntry already has toJson if it does; if not, add it.

**SessionPersistence:**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/player.dart';

class SessionPersistence {
  static const _key = 'session_v1';

  static Future<void> save(Session? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_key);
      return;
    }
    final json = jsonEncode({
      'players': session.players.map((p) => p.toJson()).toList(),
    });
    await prefs.setString(_key, json);
  }

  static Future<Session?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final players = (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
      if (players.length < 2) return null;
      return Session(players: players);
    } catch (_) {
      return null;
    }
  }
}
```

**AppRouter:** In `initState`, call `SessionPersistence.load()`. In `_onSessionChanged`, call `SessionPersistence.save(s)` asynchronously.

- [ ] **Step 1: Add shared_preferences to pubspec.yaml, run flutter pub get**
- [ ] **Step 2: Add toJson/fromJson to Player**
- [ ] **Step 3: Create session_persistence.dart**
- [ ] **Step 4: Wire into AppRouter (load on init, save on change)**
- [ ] **Step 5: Analyze**
- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/models/player.dart lib/services/session_persistence.dart lib/navigation/app_router.dart
git commit -m "feat: session persistence with shared_preferences — restores players on relaunch"
```

---

### Task 10: Roulette overlay — persist result, manual dismiss

**Files:**
- Modify: `lib/ui/screens/roulette_screen.dart`

The current `_WinnerOverlay` auto-dismisses after 4s. Change it to:
1. Require a tap to dismiss
2. After dismissal, show `_lastWinner` as a persistent banner above the wheel: "Última volta: [NAME]"

```dart
// Remove: Timer(const Duration(seconds: 4), () => setState(() => _showOverlay = false));
// Replace with: no auto-dismiss; overlay stays until tapped

// In _WinnerOverlay, wrap in GestureDetector:
GestureDetector(
  onTap: onDismiss,
  child: ... // existing overlay widget
)

// Add _lastWinner String? state:
String? _lastWinner;

// In _onResult:
setState(() {
  _winner = winner;
  _lastWinner = winner;
  _showOverlay = true;
});

// Above the wheel in build():
if (_lastWinner != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      'Última volta: $_lastWinner',
      style: AppTextStyles.body.copyWith(color: AppColors.gold),
    ),
  ),
```

- [ ] **Step 1: Remove auto-dismiss Timer**
- [ ] **Step 2: Add onTap dismiss to overlay**
- [ ] **Step 3: Add _lastWinner persistent banner**
- [ ] **Step 4: Analyze**
- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/roulette_screen.dart
git commit -m "fix: roulette overlay requires tap to dismiss, shows last winner persistently"
```

---

### Task 11: Empty states + defensive guards

**Files:**
- Modify: `lib/ui/screens/roulette_screen.dart`
- Modify: `lib/ui/screens/slots_screen.dart`
- Modify: `lib/data/dares.dart`

**Empty state widget (inline):**
```dart
// In roulette_screen.dart and slots_screen.dart, if players.isEmpty:
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.group_off_rounded, color: AppColors.textDisabled, size: 48),
      const SizedBox(height: 16),
      Text('Inicia uma sessão primeiro', style: AppTextStyles.body),
    ],
  ),
)
```

**Dares guard:**
```dart
// In Dares.random():
static String random(DareCategory category, DareIntensity intensity) {
  final bucket = get(category, intensity);
  if (bucket.isEmpty) return 'Improvisa um desafio!';
  return bucket[_random.nextInt(bucket.length)];
}
```

**DareTimerCard FEITO fix:** Cancel `_ticker` inside FEITO onPressed before calling onTimerEnd:
```dart
onPressed: () {
  _ticker.cancel();
  _controller.stop();
  widget.onTimerEnd?.call();
},
```

- [ ] **Step 1: Add empty state to roulette_screen and slots_screen**
- [ ] **Step 2: Add bucket guard to Dares.random**
- [ ] **Step 3: Fix DareTimerCard FEITO ticker cancel**
- [ ] **Step 4: Analyze all**
- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/roulette_screen.dart lib/ui/screens/slots_screen.dart \
        lib/data/dares.dart lib/ui/components/dare_timer_card.dart
git commit -m "fix: empty states, dares bucket guard, dare timer ticker cancel on FEITO"
```

---

### Task 12: Final analyze + full test suite + release APK v0.5.0

**Files:**
- Modify: `test/uat/user_acceptance_test.dart` (update any broken tests)
- Modify: `test/models/session_test.dart` (update for new addScore(points) signature)

- [ ] **Step 1: Run full analyze**

Run: `dart analyze`
Expected: 0 errors. Fix any errors found.

- [ ] **Step 2: Run full test suite**

Run: `flutter test --no-pub`
Fix any failures (likely session_test.dart Player.addScore signature change).

- [ ] **Step 3: Build release APK**

Run: `flutter build apk --release --no-pub`
Expected: Built build/app/outputs/flutter-apk/app-release.apk

- [ ] **Step 4: Final commit and tag**

```bash
git add -A
git commit -m "chore: v0.5.0 — realistic casino UI, dare results, persistence, scoring overhaul"
git tag v0.5.0
git push origin master --tags
```

- [ ] **Step 5: Create GitHub Release**

```bash
gh release create v0.5.0 build/app/outputs/flutter-apk/app-release.apk \
  --title "v0.5.0 — Casino Polish, Dare Results & Persistence" \
  --notes "## v0.5.0

### Casino Realism
- SlotReel: ListWheelScrollView with real physics and fade edges
- SlotMachine: Chrome frame + animated neon lights during spin
- Roulette: White ball animation, classic red/black segments, wood outer ring

### Game Loop
- Dare Result overlay (APROVADO/REPROVADO) before returning to spin
- Turn announcement: shows whose turn it is before spinning
- Veto mechanic fixed: uses token, no punishment (RECUSAR = veto)

### Scoring
- Intensity-based points: Casual=100, Ousado=250, Épico=500
- Streak bonus: 3-dare streak earns a free veto token

### Persistence
- Session restored on app relaunch via shared_preferences

### Fixes
- AudioPlayer pool (no more memory leak)
- ArbitroButton real press animation (scale 0.95)
- Roulette overlay: manual dismiss + persistent last winner
- Empty states on all game screens
- Dare timer ticker cancelled on FEITO"
```
