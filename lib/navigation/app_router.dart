import 'package:flutter/material.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/slots_screen.dart';
import '../ui/screens/roulette_screen.dart';
import '../ui/screens/ledger_screen.dart';
import '../ui/theme/app_colors.dart';
import '../ui/theme/app_spacing.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _index = 0;

  static const _screens = [
    LobbyScreen(),
    SlotsScreen(),
    RouletteScreen(),
    LedgerScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_index],
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
  );
}
