import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/session.dart';
import '../../models/session_state.dart';
import '../../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'arbitro_input.dart';
import 'bottom_sheet_handle.dart';
import 'avatar_icon.dart';

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
  final List<String> _avatars = [
    'default',
    'default',
  ];
  
  final List<String> _availableAvatars = [
    'default', 'ace', 'joker', 'king', 'shadow', 'spark', 'guard', 'seer', 'gambler'
  ];

  String? _error;

  void _addPlayer() {
    if (_controllers.length >= 8) return;
    HapticService.instance.light();
    setState(() {
      _error = null;
      _controllers.add(TextEditingController());
      _avatars.add('default');
    });
  }

  void _removePlayer(int index) {
    if (_controllers.length <= 2) return;
    HapticService.instance.light();
    setState(() {
      _error = null;
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _avatars.removeAt(index);
    });
  }

  void _changeAvatar(int index) {
    final current = _avatars[index];
    final nextIdx = (_availableAvatars.indexOf(current) + 1) % _availableAvatars.length;
    HapticService.instance.selection();
    setState(() {
      _avatars[index] = _availableAvatars[nextIdx];
    });
  }

  void _confirm() {
    final names = _controllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (names.length < 2) {
      setState(() => _error = 'São necessários pelo menos 2 jogadores');
      return;
    }

    final uniqueNames = names.toSet();
    if (uniqueNames.length != names.length) {
      setState(() => _error = 'Os nomes dos jogadores devem ser únicos');
      return;
    }

    final players = <Player>[];
    for (int i = 0; i < names.length; i++) {
      players.add(Player(
        name: names[i],
        avatarId: _avatars[i],
      ));
    }
    
    final session = Session(players: players);
    SessionState.of(context).startSession(session);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            const Text('Jogadores', style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.lg),
            ...List.generate(_controllers.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _changeAvatar(i),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface3,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Center(
                            child: AvatarIcon(id: _avatars[i]),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(_error!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.danger)),
              ),
            if (_controllers.length < 8)
              TextButton.icon(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add, color: AppColors.purpleLight),
                label: Text('Adicionar jogador',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.purpleLight)),
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
}
