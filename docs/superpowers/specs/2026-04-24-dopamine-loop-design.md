# Dopamine Loop — Design Spec
_2026-04-24_

## Overview

Transform O Árbitro from a dare generator into a social game with a complete round loop: spin → dare assigned → countdown timer → group vote → score update. Every round has a beginning, middle, and end. The group is always engaged, not just the player whose turn it is.

---

## 1. Core Round Loop

```
Spin reels → Dare card appears → Player taps ACEITAR
→ 60-second countdown (everyone watches)
→ Player says "done" OR timer expires
→ All other players vote thumbs-up / thumbs-down
→ Majority pass: +1 score, green flash, streak increments
→ Majority fail: punishment dare assigned, score unchanged
→ Dare card dismisses → GIRAR reappears
```

Refusing without a veto immediately assigns a punishment dare instead. There is no "ignore and spin again."

---

## 2. Features

### 2.1 Dare Timer
- After ACEITAR, the dare card transitions to a **timer card**
- Large countdown digits (60 → 0), ring/arc animation draining clockwise
- "FEITO" button lets player manually trigger the vote early
- When timer hits 0, vote phase starts automatically
- Timer is shown on the dare card screen — no navigation required

### 2.2 Group Vote
- When timer ends or player taps FEITO, the card transitions to **vote phase**
- Each non-active player sees a thumbs-up / thumbs-down for this dare
- Vote is tracked in `DareState.votes: Map<String, bool>`
- Majority decides: ties go to fail
- **Pass result:** +1 to player score, streak +1, green flash on HUD
- **Fail result:** punishment dare assigned immediately (same player, same screen)
- Voting UI: list of voter names + their icon. Active player cannot vote on own dare.

### 2.3 Always-Visible Score HUD
- Persistent widget between bottom nav and screen content
- Shows all players as chips: `"Ana  2 🔥"` — initials optional if name fits
- Score updates animate: number flashes gold, then settles
- On-fire badge 🔥 shown next to name when streak ≥ 3
- Veto tokens shown as small dots next to name (filled = available)
- HUD lives in `AppRouter` above `_buildScreen()`, always visible during a session

### 2.4 Public Veto Counter
- Veto tokens (2 per player at session start) shown in HUD as dots `●●` / `●○` / `○○`
- When player vetoes, their dots update immediately in HUD
- VETAR button in dare card still works as before, just now publicly visible
- No veto refills during session

### 2.5 Punishment Dares
- New static list `Dares.punishment` — 15 dares, severity between OUSADO and ÉPICO
- Assigned when: (a) player refuses without veto, (b) group votes majority fail
- Punishment dare uses same dare card UI, but with a red `CASTIGO` intensity badge
- Punishment dares cannot be vetoed (VETAR button hidden/disabled)
- Punishment dare also goes through timer → vote loop

### 2.6 Streak System
- `Player.streak: int` — increments on pass vote, resets on veto or fail vote
- `Player.isOnFire` getter: `streak >= 3`
- HUD shows 🔥 badge when `isOnFire`
- Streak reset is visible: the 🔥 disappears with a brief shake animation

### 2.7 Dare State Machine
- `DarePhase` enum: `assigned`, `timing`, `voting`, `punishment`
- `DareState` immutable class holds the active round data
- `Session.currentDareState: DareState?` — null when no round active
- `SessionState` methods manage transitions: `startTimer()`, `submitVote()`, `resolveDare()`, `assignPunishment()`

---

## 3. Data Model

### Player (additions)
```dart
final int score;       // default 0
final int streak;      // default 0
bool get isOnFire => streak >= 3;
Player addScore() => _copyWith(score: score + 1, streak: streak + 1);
Player resetStreak() => _copyWith(streak: 0);
```

### DarePhase (new enum)
```dart
enum DarePhase { assigned, timing, voting, punishment }
```

### DareState (new class)
```dart
class DareState {
  final String player;
  final String dare;
  final DareIntensity intensity;
  final bool isPunishment;
  final DarePhase phase;
  final Map<String, bool> votes; // voterName -> true/false
  final DateTime? timerStartedAt;
}
```

### Session (additions)
```dart
final DareState? currentDareState;
Session withDareState(DareState? state);
```

### SessionState (new methods)
```dart
void startTimer()           // assigned → timing
void triggerVote()          // timing → voting
void submitVote(String voter, bool pass)  // adds to votes map
void resolveDare()          // evaluates votes, updates scores, clears state
void assignPunishment(String player) // → punishment phase
void refuseDare(String player)       // no veto → punishment
```

---

## 4. Component Architecture

### New files
- `lib/models/dare_state.dart` — DareState + DarePhase
- `lib/ui/components/dare_timer_card.dart` — timer ring + FEITO button
- `lib/ui/components/dare_vote_card.dart` — per-player vote UI
- `lib/ui/components/score_hud.dart` — persistent player score strip

### Modified files
- `lib/models/player.dart` — add score, streak, isOnFire, addScore, resetStreak
- `lib/models/session.dart` — add currentDareState, withDareState
- `lib/models/session_state.dart` — add dare lifecycle methods
- `lib/data/dares.dart` — add punishment list
- `lib/ui/screens/slots_screen.dart` — wire dare state machine, replace inline dare management
- `lib/navigation/app_router.dart` — add ScoreHud above screen content

---

## 5. Punishment Dares (15 entries)
```
1. Faz 15 flexões agora mesmo sem parar
2. Imita o membro do grupo que o grupo escolher durante 2 minutos
3. Deixa o grupo escrever uma mensagem no teu telemóvel e enviar a quem quiserem
4. Mantém-te em posição de cadeira durante 90 segundos
5. Conta uma história embaraçosa verdadeira em menos de 60 segundos
6. O grupo escolhe uma palavra — tens de a usar em cada frase durante 3 rondas
7. Diz algo genuinamente bonito sobre cada pessoa na sala
8. Canta 30 segundos de uma música à escolha do grupo
9. Faz o teu melhor discurso de casamento para dois membros do grupo
10. Liga para alguém dos teus contactos e diz que tens uma confissão importante — depois desliga
11. Deixa o grupo fazer-te uma penteado durante 2 minutos
12. Fala apenas sussurrando durante as próximas 2 rondas
13. Descreve a tua vida amorosa honestamente em 60 segundos
14. O grupo escolhe uma pose — ficas assim durante 1 minuto inteiro
15. Faz 3 declarações sobre ti mesmo — o grupo vota em qual é mentira
```

---

## 6. Out of Scope
- Sound / haptics
- Persistent storage between sessions
- Roulette → Slots auto-navigation
- Online multiplayer

---

## 7. Acceptance Criteria
1. Full loop works: spin → accept → timer → vote → score update
2. Refusing without veto triggers punishment dare immediately
3. Fail vote triggers punishment dare
4. Score HUD visible on all tabs during active session
5. Veto tokens visible in HUD, update when spent
6. Streak and 🔥 badge work correctly
7. Punishment dares cannot be vetoed
8. All existing UAT tests still pass
9. `flutter analyze` reports zero errors
