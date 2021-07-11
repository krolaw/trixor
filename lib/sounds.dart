import 'package:just_audio/just_audio.dart';
import 'package:trixor/settings.dart';

var sound = _Sounds();

class _Sounds {
  final _MyAudio right =
      _MyAudio("assets/sounds/342750__rhodesmas__coins-purchase-4.ogg");
  final _MyAudio wrong = _MyAudio("assets/sounds/392183__dexus5__negative.ogg");
  final _MyAudio win = _MyAudio(
      "assets/sounds/270402__littlerobotsoundfactory__jingle-win-00.ogg");
  final _MyAudio lose = _MyAudio(
      "assets/sounds/270403__littlerobotsoundfactory__jingle-lose-00.ogg");
  final _MyAudio alarm =
      _MyAudio("assets/sounds/547564__eminyildirim__futuristic-alarm.ogg");
  final _MyAudio cheat =
      _MyAudio("assets/sounds/404743__owlstorm__retro-video-game-sfx-fail.ogg");
}

class _MyAudio {
  AudioPlayer _audio;
  bool once;

  _MyAudio(String path)
      : _audio = AudioPlayer(),
        once = false {
    _audio.setAsset(path);
  }

  play() {
    if (!settings.sound) return;
    if (once)
      _audio.seek(Duration.zero);
    else {
      _audio.play();
      once = true;
    }
  }
}
