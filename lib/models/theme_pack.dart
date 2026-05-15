import 'package:flutter/material.dart';
import 'package:o_arbitro/models/dare.dart';

enum PackType {
  birthday,
  workParty,
  college,
  couples,
  family,
  custom,
}

class ThemePack {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final PackType type;
  final List<Dare> dares;
  final List<String> truthPrompts;
  final List<String> wouldYouRatherQuestions;

  ThemePack({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.dares,
    this.truthPrompts = const [],
    this.wouldYouRatherQuestions = const [],
  });
}

final List<ThemePack> themePacks = [
  ThemePack(
    id: 'birthday',
    name: 'Aniversário',
    description: 'Desafios especiais para festas de aniversário',
    emoji: '🎂',
    type: PackType.birthday,
    dares: [
      Dare(id: 'bd_001', text: 'Dê um abraço em quem está ao seu lado', intensity: DareIntensity.leve),
      Dare(id: 'bd_002', text: 'Faça um brinde criativo para o aniversariante', intensity: DareIntensity.leve),
      Dare(id: 'bd_003', text: 'Imite o aniversariante por 30 segundos', intensity: DareIntensity.medio),
      Dare(id: 'bd_004', text: 'Conte uma história engraçada sobre o aniversariante', intensity: DareIntensity.medio),
      Dare(id: 'bd_005', text: 'Dê um beijo no aniversariante (se permitir)', intensity: DareIntensity.forte),
    ],
    truthPrompts: [
      'Qual foi o melhor presente que você já ganhou?',
      'Qual é sua pior memória de aniversário?',
      'O que você mais deseja para o futuro?',
    ],
  ),

  ThemePack(
    id: 'work_party',
    name: 'Festa de Escritório',
    description: 'Desafios para confraternizações de trabalho',
    emoji: '💼',
    type: PackType.workParty,
    dares: [
      Dare(id: 'wp_001', text: 'Faça uma imitação do seu chefe', intensity: DareIntensity.medio),
      Dare(id: 'wp_002', text: 'Envie um e-mail formal pedindo um aumento', intensity: DareIntensity.forte),
      Dare(id: 'wp_003', text: 'Trabalhe a próxima hora sem reclamar', intensity: DareIntensity.forte),
      Dare(id: 'wp_004', text: 'Convença um colega a fazer uma dança', intensity: DareIntensity.medio),
    ],
    truthPrompts: [
      'Qual colega você gostaria que fosse seu chefe?',
      'Já dormiu durante uma reunião?',
      'Qual é o pior trabalho que você já teve?',
    ],
  ),

  ThemePack(
    id: 'college',
    name: 'Faculdade',
    description: 'Desafios para festas universitárias',
    emoji: '🎓',
    type: PackType.college,
    dares: [
      Dare(id: 'cl_001', text: 'Recite uma fórmula matemática complexa', intensity: DareIntensity.medio),
      Dare(id: 'cl_002', text: 'Faça um "trabalho em grupo" improvisado', intensity: DareIntensity.leve),
      Dare(id: 'cl_003', text: 'Imite um professor chato', intensity: DareIntensity.medio),
      Dare(id: 'cl_004', text: 'Beba um shot sem usar as mãos', intensity: DareIntensity.forte),
    ],
    truthPrompts: [
      'Já colou em uma prova?',
      'Qual é sua pior nota histórica?',
      'Já ficou com alguém da sua turma?',
    ],
  ),

  ThemePack(
    id: 'couples',
    name: 'Casal',
    description: 'Desafios românticos para casais',
    emoji: '💕',
    type: PackType.couples,
    dares: [
      Dare(id: 'cp_001', text: 'Dê um beijo de 30 segundos no seu parceiro', intensity: DareIntensity.medio),
      Dare(id: 'cp_002', text: 'Faça uma massagem no seu parceiro', intensity: DareIntensity.leve),
      Dare(id: 'cp_003', text: 'Conte o que te atraiu no seu parceiro', intensity: DareIntensity.leve),
      Dare(id: 'cp_004', text: 'Imitem um encontro romântico', intensity: DareIntensity.medio),
    ],
    truthPrompts: [
      'Qual é o momento mais romântico que vocês viveram?',
      'Já discutiram por algo bobo? O quê?',
      'O que você mais ama no seu parceiro?',
    ],
  ),
];
