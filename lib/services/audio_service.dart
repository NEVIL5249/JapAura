import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static bool _audioEnabled = true; // <-- Add this

  static void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    if (!enabled) stop();
  }

  static Future<void> playLoop(String path) async {
    if (!_audioEnabled) return; // <-- Respect setting
    if (_isPlaying) await stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(path));
    _isPlaying = true;
  }

  static Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  static bool get isPlaying => _isPlaying;
}
