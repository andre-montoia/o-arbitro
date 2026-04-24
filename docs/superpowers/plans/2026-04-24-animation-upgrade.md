# Animation Upgrade — Implementation Plan
_2026-04-24_

Spec: `docs/superpowers/specs/2026-04-24-animation-upgrade-design.md`

---

## Task 1 — SlotReel widget (vertical scrolling reel)

**Files to create/edit:**
- `lib/ui/components/slot_reel.dart` (new)

**What to build:**
Create `SlotReel` — a `StatefulWidget` with `TickerProviderStateMixin`.

Constructor: `SlotReel({ required List<String> items, required int targetIndex, required Duration duration, required VoidCallback? onComplete })`

Internal state:
- `AnimationController _controller` with the given duration
- `CurvedAnimation _curved` using `Curves.decelerate`
- `ScrollController _scroll` — NOT used for scroll; instead use an `AnimatedBuilder` that maps animation value `0→1` to a scroll offset

Layout: A fixed-height (132 px) clipped `Column` with the 3 visible rows:
- Row above selected: smaller text, 30% opacity
- Selected row: full brightness, border-top and border-bottom `rgba(168,85,247,0.4)`, 44 px height
- Row below selected: smaller text, 30% opacity

The selected item shifts through the items list as the animation progresses. At `t=0`, show items from index 0. At `t=1`, show items centered on `targetIndex`. Interpolate the "current display index" as a double for smooth visual scrolling.

Expose `spin(int targetIndex)` method that resets and starts `_controller`. Call `onComplete` when done.

**Test:** No widget test needed for this component alone — covered by Task 5 UAT.

---

## Task 2 — SlotMachine widget upgrade (real reels + frame)

**Files to edit:**
- `lib/ui/components/slot_machine.dart`

**What to build:**
Replace the existing 3-box implementation with 3 `SlotReel` widgets inside a neon machine frame.

Machine frame: `Container` with `gradient: LinearGradient(#2a1a4e → #1a0a3e)`, `border: Border.all(color: AppColors.purple, width: 3)`, `borderRadius: 16`, `boxShadow: [BoxShadow(color: purpleGlow, blurRadius: 30)]`.

Reel window inside frame: dark background, `border: Border.all(color: AppColors.purpleLight, width: 2)`, `borderRadius: 8`. Contains:
- Scanline overlay: `RepaintBoundary` with a `CustomPaint` that draws `repeating-linear-gradient(0deg, transparent 3px, rgba(168,85,247,0.03) 4px)` — or just a `Opacity(0.03, child: ...)` striped box
- Horizontal highlight bar at center: `Positioned` `Container` height 2, color `AppColors.purpleLight.withOpacity(0.3)`
- `Row` of 3 `SlotReel` widgets separated by 1 px purple dividers

`spin()` method on `SlotMachineState`:
1. Determine dare result (random player, category, intensity)
2. Call `reel1.spin(playerIndex)` — after 600 ms, call `reel2.spin(categoryIndex)` — after 750 ms total, call `reel3.spin(intensityIndex)`
3. After reel3 complete (900 ms total), call `widget.onSpinComplete(DareResult(...))`

The existing `SlotMachineScreen` wires up `onSpinComplete` to show the dare result card — keep that logic unchanged.

**Dependencies:** Task 1 must be complete.

---

## Task 3 — Roulette winner explosion overlay

**Files to edit:**
- `lib/ui/screens/roulette_screen.dart`
- `lib/ui/components/roulette_wheel.dart`

**What to build:**

**In `roulette_wheel.dart`:**
Add `final void Function(String winner)? onSpinComplete;` to `RouletteWheel` constructor.
After the spin `AnimationController` completes, call `onSpinComplete(winnerName)`.

**In `roulette_screen.dart`:**
Wrap the screen body in a `Stack`. Add `_WinnerOverlay` as a `Stack` child that appears when `_winner != null`.

`_WinnerOverlay` is a private `StatefulWidget` with `SingleTickerProviderStateMixin`:
- `AnimationController` 500 ms
- Fade-in of dark scrim: `FadeTransition(opacity: _controller)`
- Scale-up of winner card: `ScaleTransition(scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut))`
- Winner card: `Container` with gold gradient background, gold border, `BoxShadow` gold glow, label "O DESTINO DECIDIU" + winner name
- Particle burst: 20 `_Particle` objects (random angle 0–360°, speed 60–120 px), drawn by `CustomPainter` in `AnimatedBuilder`. Each particle is a small circle that moves outward as animation progresses (position = `Offset.fromDirection(angle, speed * t)` from center).
- `GestureDetector` wrapping scrim → calls `widget.onDismiss()`

`RouletteScreen` state:
```dart
String? _winner;

// in Stack:
if (_winner != null)
  _WinnerOverlay(
    winner: _winner!,
    onDismiss: () => setState(() => _winner = null),
  ),
```

Auto-dismiss: `_WinnerOverlay` starts a 4 s `Timer` that calls `onDismiss` if user hasn't tapped.

---

## Task 4 — Ledger dramatic entry reveal

**Files to edit:**
- `lib/ui/screens/ledger_screen.dart`
- `lib/ui/components/glass_card.dart` (add optional `glowColor` param)

**What to build:**

**AnimatedList for new entries:**
Replace `ListView.separated` with `AnimatedList` using `GlobalKey<AnimatedListState> _listKey`.

In `_LedgerScreenState`, override `didUpdateWidget` or use a listener on `SessionState` to detect when `ledgerEntries.length` increases. Call `_listKey.currentState!.insertItem(0, duration: const Duration(milliseconds: 400))`.

`itemBuilder` returns `_EntryCard` wrapped in:
```dart
SlideTransition(
  position: animation.drive(Tween(begin: const Offset(0, -0.5), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
  child: FadeTransition(opacity: animation, child: _EntryCard(...)),
)
```

**Pending bet pulse:**
In `_BetCard`, add `AnimationController _pulse` (1500 ms, repeat reverse). Use it to animate `BoxDecoration borderSide` color opacity on the `GlassCard`. Add an optional `borderAnimation` param to `GlassCard` or implement the pulsing border directly inside `_BetCard` wrapping with `AnimatedBuilder`.

Simpler approach: wrap `_BetCard`'s `GlassCard` in an `AnimatedBuilder` that rebuilds with a `Border.all(color: AppColors.gold.withOpacity(_pulse.value), width: 1.5)` overlay using a `DecoratedBox` on top.

**Resolved flash:**
In `_BetCard.didUpdateWidget`: if `oldWidget.bet.status == BetStatus.pending && widget.bet.status == BetStatus.resolved`, play a one-shot green flash animation (400 ms, then stop). Use a second `AnimationController _flash` (400 ms, not repeating) that, when played, overlays a green border glow.

---

## Task 5 — UAT test updates

**Files to edit:**
- `test/uat/user_acceptance_test.dart`

**What to add:**

1. **Roulette winner overlay test:**
```dart
testWidgets('tapping GIRAR on roulette shows winner overlay', (tester) async {
  await goToRoulette(tester);
  await tester.tap(find.text('GIRAR'));
  // Roulette spins 3500ms
  await tester.pump(const Duration(milliseconds: 3600));
  await tester.pumpAndSettle();
  // Overlay should appear
  expect(find.text('O DESTINO DECIDIU'), findsOneWidget);
});

testWidgets('tapping winner overlay dismisses it', (tester) async {
  await goToRoulette(tester);
  await tester.tap(find.text('GIRAR'));
  await tester.pump(const Duration(milliseconds: 3600));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(GestureDetector).last);
  await tester.pumpAndSettle();
  expect(find.text('O DESTINO DECIDIU'), findsNothing);
});
```

Add `goToRoulette` helper (same pattern as `goToSlots`).

2. **Slot reels test — verify items appear in reel window:**
```dart
testWidgets('slot reels show player names during spin', (tester) async {
  await goToSlots(tester);
  await tester.tap(find.text('GIRAR'));
  await tester.pump(const Duration(milliseconds: 100));
  // At least one player name visible in reel
  final sessionPlayers = ['Ana', 'Bruno'];
  expect(
    sessionPlayers.any((name) => tester.any(find.text(name))),
    isTrue,
  );
  // Complete animation
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pumpAndSettle();
  expect(find.text('ACEITAR'), findsOneWidget);
});
```

3. **Ledger animated entry test:**
```dart
testWidgets('new ledger entry slides in after adding', (tester) async {
  await goToLedger(tester);
  await tester.tap(find.text('+ NOVA ENTRADA'));
  await tester.pumpAndSettle();
  // Fill in bet details
  await tester.tap(find.text('Aposta'));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, 'Descreve a aposta'), 'Paga a conta');
  await tester.enterText(find.widgetWithText(TextField, 'O que acontece ao perdedor?'), 'Faz flexões');
  await tester.tap(find.text('ADICIONAR'));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  expect(find.text('Paga a conta'), findsOneWidget);
  expect(find.text('APOSTA'), findsOneWidget);
});
```

Add `goToLedger` helper.

---

## Execution Order

1. Task 1 — SlotReel widget
2. Task 2 — SlotMachine upgrade (depends on Task 1)
3. Task 3 — Roulette explosion overlay
4. Task 4 — Ledger dramatic reveal
5. Task 5 — UAT tests (after all widgets done)

Run `flutter analyze && flutter test test/uat/user_acceptance_test.dart` after Task 5.
