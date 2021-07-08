import 'package:just_audio/just_audio.dart';

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

  /*
  assets/sounds/270402__littlerobotsoundfactory__jingle-win-00.ogg
assets/sounds/270402__littlerobotsoundfactory__jingle-win-00.wav
assets/sounds/270403__littlerobotsoundfactory__jingle-lose-00.ogg
assets/sounds/270403__littlerobotsoundfactory__jingle-lose-00.wav
assets/sounds/342750__rhodesmas__coins-purchase-4.ogg
assets/sounds/342750__rhodesmas__coins-purchase-4.wav
assets/sounds/392183__dexus5__negative.ogg
assets/sounds/392183__dexus5__negative.wav
assets/sounds/404743__owlstorm__retro-video-game-sfx-fail.mp3
assets/sounds/404743__owlstorm__retro-video-game-sfx-fail.ogg
assets/sounds/404743__owlstorm__retro-video-game-sfx-fail.wav
assets/sounds/547564__eminyildirim__futuristic-alarm.ogg
assets/sounds/547564__eminyildirim__futuristic-alarm.wav
  
  */
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
    if (once)
      _audio.seek(Duration.zero);
    else {
      _audio.play();
      once = true;
    }
  }
}
