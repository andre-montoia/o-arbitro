import 'package:audioplayers/audioplayers.dart';

enum GameSound {
  spin('sounds/spin.wav'),
  win('sounds/win.wav'),
  dareAssign('sounds/dare_assign.wav'),
  votePass('sounds/vote_pass.wav'),
  voteFail('sounds/vote_fail.wav'),
  timerTick('sounds/timer_tick.wav'),
  punishment('sounds/punishment.wav');

  const GameSound(this.path);
  final String path;
}

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  Future<void> play(GameSound sound) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(sound.path));
      // Dispose after finished to avoid memory leaks
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      // Ignore audio errors in background
    }
  }
}
