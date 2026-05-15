import 'package:o_arbitro/models/would_you_rather.dart';

final List<WouldYouRatherQuestion> wouldYouRatherQuestions = [
  // Social
  WouldYouRatherQuestion(
    id: 'wr_001',
    category: 'Social',
    optionA: WouldYouRatherOption(text: 'Ter 100 amigos falsos', emoji: '🤥'),
    optionB: WouldYouRatherOption(text: 'Ter 1 amigo verdadeiro', emoji: '💎'),
  ),
  WouldYouRatherQuestion(
    id: 'wr_002',
    category: 'Romance',
    optionA: WouldYouRatherOption(text: 'Namorar o ex do seu melhor amigo', emoji: '💔'),
    optionB: WouldYouRatherOption(text: 'Nunca namorar na vida', emoji: '🚫'),
  ),

  // Lifestyle
  WouldYouRatherQuestion(
    id: 'wr_003',
    category: 'Lifestyle',
    optionA: WouldYouRatherOption(text: 'Viver sem internet', emoji: '📵'),
    optionB: WouldYouRatherOption(text: 'Viver sem banho por um mês', emoji: '🛁'),
  ),
  WouldYouRatherQuestion(
    id: 'wr_004',
    category: 'Comida',
    optionA: WouldYouRatherOption(text: 'Comer apenas pizza pelo resto da vida', emoji: '🍕'),
    optionB: WouldYouRatherOption(text: 'Comer apenas salada pelo resto da vida', emoji: '🥗'),
  ),

  // Chaotic
  WouldYouRatherQuestion(
    id: 'wr_005',
    category: 'Caos',
    optionA: WouldYouRatherOption(text: 'Andar de cueca na rua', emoji: '🩲'),
    optionB: WouldYouRatherOption(text: 'Cantar no metrô', emoji: '🚇'),
  ),
  WouldYouRatherQuestion(
    id: 'wr_006',
    category: 'Trabalho',
    optionA: WouldYouRatherOption(text: 'Trabalhar aos sábados', emoji: '💼'),
    optionB: WouldYouRatherOption(text: 'Acordar 5h todo dia', emoji: '⏰'),
  ),

  // Party
  WouldYouRatherQuestion(
    id: 'wr_007',
    category: 'Festa',
    optionA: WouldYouRatherOption(text: 'Ser o DJ da festa', emoji: '🎧'),
    optionB: WouldYouRatherOption(text: 'Ser o garçom da festa', emoji: '🍻'),
  ),
  WouldYouRatherQuestion(
    id: 'wr_008',
    category: 'Coragem',
    optionA: WouldYouRatherOption(text: 'Pular de paraquedas', emoji: '🪂'),
    optionB: WouldYouRatherOption(text: 'Entrar em uma jaula com leões', emoji: '🦁'),
  ),
];
