import 'package:flutter/material.dart';
import 'package:o_arbitro/models/dare.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';

class CustomDareCreatorScreen extends StatefulWidget {
  const CustomDareCreatorScreen({Key? key}) : super(key: key);

  @override
  State<CustomDareCreatorScreen> createState() => _CustomDareCreatorScreenState();
}

class _CustomDareCreatorScreenState extends State<CustomDareCreatorScreen> {
  final _textController = TextEditingController();
  DareIntensity _selectedIntensity = DareIntensity.leve;
  final List<Dare> _customDares = [];

  void _addDare() {
    if (_textController.text.isEmpty) return;
    HapticService.instance.light();
    setState(() {
      _customDares.add(
        Dare(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          text: _textController.text,
          intensity: _selectedIntensity,
        ),
      );
      _textController.clear();
    });
  }

  void _removeDare(int index) {
    HapticService.instance.light();
    setState(() {
      _customDares.removeAt(index);
    });
  }

  Color _getIntensityColor(DareIntensity intensity) {
    switch (intensity) {
      case DareIntensity.leve:
        return Colors.green;
      case DareIntensity.medio:
        return Colors.orange;
      case DareIntensity.forte:
        return Colors.deepOrange;
      case DareIntensity.epico:
        return Colors.red;
      case DareIntensity.castigo:
        return Colors.black;
    }
  }

  String _getIntensityLabel(DareIntensity intensity) {
    switch (intensity) {
      case DareIntensity.leve:
        return 'LEVE';
      case DareIntensity.medio:
        return 'MÉDIO';
      case DareIntensity.forte:
        return 'FORTE';
      case DareIntensity.epico:
        return 'ÉPICO';
      case DareIntensity.castigo:
        return 'CASTIGO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('✏️ Criar Desafios', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Digite um desafio personalizado...',
                      hintStyle: AppTextStyles.body.copyWith(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Intensidade:', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: DareIntensity.values.map((intensity) {
                      final isSelected = _selectedIntensity == intensity;
                      return FilterChip(
                        selected: isSelected,
                        backgroundColor: _getIntensityColor(intensity).withOpacity(0.2),
                        selectedColor: _getIntensityColor(intensity),
                        label: Text(
                          _getIntensityLabel(intensity),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onSelected: (selected) {
                          HapticService.instance.light();
                          setState(() {
                            _selectedIntensity = intensity;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ArbitroButton(
                    label: '➕ Adicionar Desafio',
                    onPressed: _addDare,
                    variant: ArbitroButtonVariant.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Desafios Criados (${_customDares.length})',
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _customDares.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum desafio criado ainda.',
                        style: AppTextStyles.body.copyWith(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _customDares.length,
                      itemBuilder: (context, index) {
                        final dare = _customDares[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getIntensityColor(dare.intensity),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dare.text,
                                      style: AppTextStyles.body,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _getIntensityLabel(dare.intensity),
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: _getIntensityColor(dare.intensity),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeDare(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
