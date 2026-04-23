import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/session_state.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/slots_screen.dart';
import '../ui/screens/roulette_screen.dart';
import '../ui/screens/ledger_screen.dart';
import '../ui/theme/app_colors.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _index = 0;
  Session? _session;

  void _onSessionChanged(Session? s) => setState(() => _session = s);

  @override
  Widget build(BuildContext context) {
    return SessionState(
      session: _session,
      onSessionChanged: _onSessionChanged,
      child: Scaffold(
        body: _buildScreen(),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Lobby'),
              BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Slots'),
              BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Roleta'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Ledger'),
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
