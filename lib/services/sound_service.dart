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

  static const _poolSize = 4;
  final List<AudioPlayer> _pool = List.generate(_poolSize, (_) => AudioPlayer());
  int _poolIndex = 0;

  Future<void> play(GameSound sound) async {
    try {
      final player = _pool[_poolIndex % _poolSize];
      _poolIndex++;
      await player.stop();
      await player.play(AssetSource(sound.path));
    } catch (_) {}
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
  }
}