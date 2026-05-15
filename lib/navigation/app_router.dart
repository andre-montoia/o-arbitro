import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/session_state.dart';
import '../services/session_persistence.dart';
import '../ui/components/score_hud.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/speed_dare_screen.dart';
import '../ui/screens/never_have_i_ever_screen.dart';
import '../ui/screens/would_you_rather_screen.dart';
import '../ui/screens/truth_or_dare_wheel_screen.dart';
import '../ui/screens/most_likely_screen.dart';
import '../ui/screens/slots_screen.dart';
import '../ui/screens/roulette_screen.dart';
import '../ui/screens/ledger_screen.dart';
import '../ui/screens/theme_packs_screen.dart';
import '../ui/screens/session_history_screen.dart';
import '../ui/screens/custom_dare_creator_screen.dart';
import '../ui/theme/app_colors.dart';
import '../ui/theme/app_text_styles.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _index = 0;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final s = await SessionPersistence.load();
    if (s != null && mounted) setState(() => _session = s);
  }

  void _onSessionChanged(Session? s) {
    setState(() => _session = s);
    SessionPersistence.save(s);
  }

  @override
  Widget build(BuildContext context) {
    return SessionState(
      session: _session,
      onSessionChanged: _onSessionChanged,
      child: Scaffold(
        body: Column(
          children: [
            if (_session != null)
              ScoreHud(
                players: _session!.players,
                activePlayer: _session!.currentDareState?.player,
              ),
            Expanded(child: _buildScreen()),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A30), Color(0xFF0C0C18)],
            ),
            border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.purpleLight,
            unselectedItemColor: AppColors.textDisabled,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: AppTextStyles.caption.copyWith(
              color: AppColors.purpleLight,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Lobby'),
              BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Slots'),
              BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Roleta'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Ledger'),
              BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Mais Provável'),
              BottomNavigationBarItem(icon: Icon(Icons.flash_on_rounded), label: 'Speed Dare'),
              BottomNavigationBarItem(icon: Icon(Icons.fingerprint_rounded), label: 'Never Have'),
              BottomNavigationBarItem(icon: Icon(Icons.help_outline_rounded), label: 'Would You'),
              BottomNavigationBarItem(icon: Icon(Icons.sync_rounded), label: 'Truth/Dare'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    if (_index == 0) return const LobbyScreen();
    if (_session == null) return _LockedScreen(tabIndex: _index);
    return switch (_index) {
      1 => const SlotsScreen(),
      2 => const RouletteScreen(),
      3 => const LedgerScreen(),
      4 => const MostLikelyScreen(),
      5 => const SpeedDareScreen(playerCount: 4),
      6 => const NeverHaveIEverScreen(playerCount: 4),
      7 => const WouldYouRatherScreen(playerCount: 4),
      8 => const TruthOrDareWheelScreen(playerCount: 4),
      _ => const LobbyScreen(),
    };
  }
}

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({required this.tabIndex});
  final int tabIndex;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 16),
          Text(
            'Inicia uma sessão primeiro',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
