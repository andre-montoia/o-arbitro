import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/session.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'arbitro_input.dart';
import 'bottom_sheet_handle.dart';

class PlayerSetupSheet extends StatefulWidget {
  const PlayerSetupSheet({super.key});

  @override
  State<PlayerSetupSheet> createState() => _PlayerSetupSheetState();
}

class _PlayerSetupSheetState extends State<PlayerSetupSheet> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addPlayer() {
    if (_controllers.length >= 8) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _confirm() {
    final names = _controllers
      .map((c) => c.text.trim())
      .where((n) => n.isNotEmpty)
      .toList();
    if (names.length < 2) return;
    final players = names.map((n) => Player(name: n)).toList();
    final session = Session(players: players);
    SessionState.of(context).startSession(session);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BottomSheetHandle(),
        const SizedBox(height: AppSpacing.md),
        Text('Jogadores', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_controllers.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: ArbitroInput(
                  controller: _controllers[i],
                  hint: 'Nome do jogador ${i + 1}',
                ),
              ),
              if (_controllers.length > 2) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => _removePlayer(i),
                  child: const Icon(Icons.remove_circle_outline,
                    color: AppColors.danger),
                ),
              ],
            ],
          ),
        )),
        if (_controllers.length < 8)
          TextButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add, color: AppColors.purpleLight),
            label: Text('Adicionar jogador',
              style: AppTextStyles.body.copyWith(color: AppColors.purpleLight)),
          ),
        const SizedBox(height: AppSpacing.lg),
        ArbitroButton(
          label: 'INICIAR SESSÃO',
          onPressed: _confirm,
          fullWidth: true,
        ),
      ],
    ),
  );
}
