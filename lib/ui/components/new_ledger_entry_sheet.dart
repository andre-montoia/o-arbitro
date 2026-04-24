import 'package:flutter/material.dart';
import '../../models/ledger_entry.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'arbitro_input.dart';
import 'bottom_sheet_handle.dart';

enum _EntryType { aposta, previsao, pontuacao }

class NewLedgerEntrySheet extends StatefulWidget {
  const NewLedgerEntrySheet({super.key});

  @override
  State<NewLedgerEntrySheet> createState() => _NewLedgerEntrySheetState();
}

class _NewLedgerEntrySheetState extends State<NewLedgerEntrySheet> {
  _EntryType _type = _EntryType.aposta;
  final _descController = TextEditingController();
  final _consequenceController = TextEditingController();
  String? _selectedPlayer;

  @override
  void dispose() {
    _descController.dispose();
    _consequenceController.dispose();
    super.dispose();
  }

  void _submit() {
    final desc = _descController.text.trim();
    if (desc.isEmpty) return;
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    LedgerEntry entry;
    switch (_type) {
      case _EntryType.aposta:
        entry = SocialBet(
          description: desc,
          players: players,
          consequence: _consequenceController.text.trim(),
        );
      case _EntryType.previsao:
        entry = Prediction(
          description: desc,
          consequence: _consequenceController.text.trim(),
        );
      case _EntryType.pontuacao:
        entry = ScoreEntry(
          player: _selectedPlayer ?? players.first,
          source: ScoreSource.manual,
          description: desc,
        );
    }

    state.addLedgerEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: AppSpacing.md),
          Text('Nova Entrada', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _TypeChip(
                label: 'Aposta',
                selected: _type == _EntryType.aposta,
                onTap: () => setState(() => _type = _EntryType.aposta),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TypeChip(
                label: 'Previsão',
                selected: _type == _EntryType.previsao,
                onTap: () => setState(() => _type = _EntryType.previsao),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TypeChip(
                label: 'Pontuação',
                selected: _type == _EntryType.pontuacao,
                onTap: () => setState(() => _type = _EntryType.pontuacao),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ArbitroInput(
            controller: _descController,
            hint: _type == _EntryType.pontuacao
                ? 'Descrição do ponto'
                : 'Descrição da ${_type == _EntryType.aposta ? "aposta" : "previsão"}',
          ),
          if (_type != _EntryType.pontuacao) ...[
            const SizedBox(height: AppSpacing.sm),
            ArbitroInput(
              controller: _consequenceController,
              hint: 'Consequência para o perdedor',
            ),
          ],
          if (_type == _EntryType.pontuacao) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedPlayer ?? players.first,
              dropdownColor: AppColors.surface2,
              style: AppTextStyles.bodyStrong,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: players
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPlayer = v),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ArbitroButton(label: 'ADICIONAR', onPressed: _submit, fullWidth: true),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.purpleLight : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      );
}
