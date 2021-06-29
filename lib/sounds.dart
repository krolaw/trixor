import 'package:just_audio/just_audio.dart';

var sound = _Sounds();

class _Sounds {
  final _MyAudio right;
  final _MyAudio wrong;

  _Sounds()
      : right =
            _MyAudio("assets/sounds/342750__rhodesmas__coins-purchase-4.wav"),
        wrong = _MyAudio("assets/sounds/392183__dexus5__negative.wav");
}

class _MyAudio {
  AudioPlayer _audio;

  _MyAudio(String path) : _audio = AudioPlayer() {
    _audio.setAsset(path);
  }

  play() {
    _audio.pause();
    _audio.seek(Duration.zero);
    _audio.play();
  }
}
