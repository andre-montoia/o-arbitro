import 'dart:math';
import '../models/spin_result.dart';

abstract final class Dares {
  static final _random = Random();

  static List<String> get(DareCategory category, DareIntensity intensity) =>
    _content[category]![intensity]!;

  static String random(DareCategory category, DareIntensity intensity) {
    final bucket = get(category, intensity);
    return bucket[_random.nextInt(bucket.length)];
  }

  static const Map<DareCategory, Map<DareIntensity, List<String>>> _content = {
    DareCategory.social: {
      DareIntensity.casual: [
        'Envia uma mensagem de voz a alguém que não falas há 3 meses',
        'Mostra a última foto que tiraste ao grupo',
        'Lê a última mensagem que enviaste em voz alta',
        'Muda o teu nome no grupo para o que o grupo decidir durante 10 minutos',
        'Posta uma selfie nos stories agora mesmo',
      ],
      DareIntensity.ousado: [
        'Liga para um familiar e diz que tens uma surpresa — depois desliga',
        'Envia uma mensagem de "saudades" a um ex',
        'Muda a tua foto de perfil para o que o grupo escolher durante 1 hora',
        'Posta uma história embaraçosa tua nas redes sociais',
        'Envia um elogio sincero a alguém que não gostas muito',
      ],
      DareIntensity.epico: [
        'Conta o teu maior segredo ao grupo',
        'Mostra as últimas 10 pesquisas no Google',
        'Liga para alguém aleatório dos teus contactos e canta os parabéns',
        'Publica uma foto da infância envergonhosa no Instagram',
        'Envia uma declaração de amor exagerada a um amigo — a sério',
      ],
    },
    DareCategory.fisico: {
      DareIntensity.casual: [
        'Faz 10 agachamentos agora mesmo',
        'Mantém-te em equilíbrio numa perna durante 30 segundos',
        'Faz a tua melhor dança durante 15 segundos',
        'Imita um animal à escolha do grupo durante 20 segundos',
        'Faz 5 estrelinhas',
      ],
      DareIntensity.ousado: [
        'Faz 20 flexões agora mesmo',
        'Mantém a posição de prancha durante 1 minuto',
        'Anda de gatas pela sala duas vezes',
        'Imita um personagem famoso até o grupo adivinhar',
        'Faz o teu melhor moonwalk',
      ],
      DareIntensity.epico: [
        'Mantém-te em posição de cadeira durante 2 minutos',
        'Faz 30 abdominais sem parar',
        'Anda às cavalitas do jogador mais pesado do grupo',
        'Salta à corda imaginária durante 2 minutos sem parar',
        'Faz 10 burpees perfeitos',
      ],
    },
    DareCategory.mental: {
      DareIntensity.casual: [
        'Diz o alfabeto ao contrário o mais rápido que conseguires',
        'Conta uma piada que o grupo ainda não conhece',
        'Nomeia 10 capitais europeias em 20 segundos',
        'Imita a voz de um membro do grupo — eles têm de adivinhar quem',
        'Diz 5 factos aleatórios sobre ti mesmo',
      ],
      DareIntensity.ousado: [
        'Responde honestamente: qual é o teu maior arrependimento?',
        'Descreve cada pessoa do grupo com apenas um adjetivo — honestamente',
        'Qual é a coisa mais embaraçosa que já fizeste? Conta tudo',
        'Se tivesses de escolher um do grupo para namorar, quem era? Porquê?',
        'O que pensas realmente de cada pessoa nesta sala?',
      ],
      DareIntensity.epico: [
        'Conta o teu maior segredo que nunca contaste a ninguém aqui',
        'Diz uma verdade desconfortável sobre alguém na sala — com respeito',
        'Qual foi o teu pior momento de vida? Partilha com o grupo',
        'Se pudesses apagar um evento da tua vida, qual era? Porquê?',
        'Confessa algo ao grupo que nunca tiveste coragem de dizer',
      ],
    },
    DareCategory.wild: {
      DareIntensity.casual: [
        'O grupo decide o teu desafio — tens 30 segundos para aceitar ou vetar',
        'Troca de lugar com a pessoa à tua esquerda e fica assim 5 minutos',
        'Fala com sotaque escolhido pelo grupo durante 3 rondas',
        'Grita o teu nome pela janela',
        'Apresenta-te ao grupo como se fosses um personagem de série',
      ],
      DareIntensity.ousado: [
        'O grupo cria um desafio combinado — aceitas ou perdes 2 turnos',
        'Deixa o grupo desbloquear o teu telemóvel e mandar 1 mensagem a quem quiser',
        'O grupo escolhe uma música — danças sem parar até acabar',
        'Fala apenas em perguntas durante as próximas 3 rondas',
        'Troca de roupa com alguém do grupo durante 10 minutos',
      ],
      DareIntensity.epico: [
        'O grupo decide tudo — desafio livre sem limite de tempo',
        'Deixa o grupo postar algo no teu Instagram sem ver primeiro',
        'Aceitas o próximo desafio sem saber o que é — sem veto possível',
        'O grupo escreve uma mensagem e tu envias para quem eles escolherem',
        'Ficas às ordens do grupo durante as próximas 5 rondas',
      ],
    },
  };
}
